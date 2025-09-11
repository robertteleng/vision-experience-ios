////
//  MainViewModel.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import Combine
import AVFoundation

class MainViewModel: ObservableObject {
    @Published var selectedIllness: Illness?
    @Published var filterEnabled: Bool = true
    @Published var centralFocus: Double = 0.5
    @Published var isCardboardMode: Bool = false

    // Ajustes específicos por filtro
    @Published var cataractsSettings: CataractsSettings = .defaults
    @Published var glaucomaSettings: GlaucomaSettings = .defaults
    @Published var macularDegenerationSettings: MacularDegenerationSettings = .defaults
    @Published var tunnelVisionSettings: TunnelVisionSettings = .defaults

    // ✅ AÑADIDO: Para saber en qué pantalla estamos
    @Published var currentRoute: AppRoute = .splash

    // Wrapper de ajustes según la enfermedad seleccionada
    var currentIllnessSettings: IllnessSettings? {
        guard let type = selectedIllness?.filterType else { return nil }
        switch type {
        case .cataracts:
            return .cataracts(cataractsSettings)
        case .glaucoma:
            return .glaucoma(glaucomaSettings)
        case .macularDegeneration:
            return .macular(macularDegenerationSettings)
        case .tunnelVision:
            return .tunnel(tunnelVisionSettings)
        }
    }

    @ObservedObject var speechService: SpeechRecognitionService
    private var cancellables = Set<AnyCancellable>()
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // Control de cooldown para comandos
    private var lastCommandTime: Date = Date.distantPast
    private let commandCooldown: TimeInterval = 1.5 // Reducido para mejor UX
    
    var navigateToIllnessList: (() -> Void)?

    init(speechService: SpeechRecognitionService = SpeechRecognitionService()) {
        self.speechService = speechService
        setupSpeechRecognitionBinding()
        requestSpeechAuthorization()
    }
    
    private func requestSpeechAuthorization() {
        speechService.requestAuthorization { authorized in
            if authorized {
                print("✅ Speech recognition authorized")
            } else {
                print("❌ Speech recognition not authorized")
            }
        }
    }

    private func setupSpeechRecognitionBinding() {
        speechService.$lastCommand
            .receive(on: DispatchQueue.main)
            .sink { [weak self] command in
                guard let self = self, !command.isEmpty else { return }
                self.processVoiceCommand(command.lowercased())
            }
            .store(in: &cancellables)
        
        speechService.$error
            .compactMap { $0 }
            .sink { error in
                print("🚨 Speech recognition error: \(error)")
            }
            .store(in: &cancellables)
    }
    
    // ✅ MEJORADO: Extracción de comandos con más contexto
    private func extractValidCommand(from text: String) -> String? {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Comandos organizados por contexto
        let allCommands: [(keywords: [String], command: String, contexts: [AppRoute])] = [
            // Comandos de navegación (disponibles en todas las pantallas)
            (["atrás", "volver", "back", "go back"], "atras", [.camera, .illnessList]),
            (["lista", "menu", "list", "enfermedades"], "lista", [.camera]),
            (["cámara", "camera"], "camera", [.illnessList]),
            
            // Comandos de enfermedades (útiles en lista Y cámara)
            (["cataratas", "cataracts"], "cataratas", [.illnessList, .camera]),
            (["glaucoma"], "glaucoma", [.illnessList, .camera]),
            (["macular", "degeneración macular"], "macular", [.illnessList, .camera]),
            (["túnel", "tunel", "tunnel", "visión de túnel"], "tunel", [.illnessList, .camera]),
            
            // Comandos de control (solo en cámara)
            (["más", "aumentar", "increase", "more", "stronger"], "mas", [.camera]),
            (["menos", "disminuir", "decrease", "less", "weaker"], "menos", [.camera]),
            (["activar", "encender", "enable", "on"], "activar", [.camera]),
            (["desactivar", "apagar", "disable", "off"], "desactivar", [.camera]),
            (["realidad virtual", "vr", "cardboard", "gafas"], "vr", [.camera]),
            (["salir vr", "exit vr", "quit vr"], "salir_vr", [.camera]),
            
            // Comandos de ayuda (disponibles siempre)
            (["ayuda", "help", "comandos"], "ayuda", [.illnessList, .camera])
        ]
        
        // Filtrar comandos válidos para el contexto actual
        let validCommandsForContext = allCommands.filter { command in
            command.contexts.contains(currentRoute)
        }
        
        // Buscar el comando más específico
        for (keywords, command, _) in validCommandsForContext {
            for keyword in keywords {
                if cleanText.contains(keyword) {
                    // Verificar que no es parte de una conversación muy larga
                    let words = cleanText.components(separatedBy: " ")
                    if words.count <= 12 {
                        return command
                    }
                    
                    // O si la palabra clave está cerca del final
                    if let range = cleanText.range(of: keyword) {
                        let afterKeyword = cleanText[range.upperBound...]
                        if afterKeyword.count <= 20 {
                            return command
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    private func processVoiceCommand(_ fullText: String) {
        print("🎤 Raw text: '\(fullText)' in context: \(currentRoute)")
        
        // Verificar cooldown
        let now = Date()
        guard now.timeIntervalSince(lastCommandTime) > commandCooldown else {
            print("⏰ Command cooldown active")
            return
        }
        
        // Extraer comando válido
        guard let command = extractValidCommand(from: fullText) else {
            print("❌ No valid command found for context \(currentRoute)")
            return
        }
        
        print("✅ Executing command: '\(command)' in context: \(currentRoute)")
        lastCommandTime = now
        
        // Ejecutar comando
        executeCommand(command)
    }
    
    // ✅ MEJORADO: Comandos contextuales
    private func executeCommand(_ command: String) {
        switch command {
        // Navegación
        case "atras":
            if currentRoute == .camera {
                navigateToIllnessList?()
                speak("Volviendo")
            }
            provideFeedback()
            
        case "lista":
            if currentRoute == .camera {
                navigateToIllnessList?()
                speak("Lista de enfermedades")
            }
            provideFeedback()
            
        case "camera":
            if currentRoute == .illnessList && selectedIllness != nil {
                // MainView manejará la navegación automáticamente
                speak("Abriendo cámara")
            }
            provideFeedback()
            
        // Control de intensidad (solo en cámara)
        case "mas":
            if currentRoute == .camera {
                let oldValue = centralFocus
                centralFocus = min(1.0, centralFocus + 0.3)
                if centralFocus > oldValue {
                    speak("Más intenso")
                    provideFeedback()
                }
            }
            
        case "menos":
            if currentRoute == .camera {
                let oldValue = centralFocus
                centralFocus = max(0.0, centralFocus - 0.3)
                if centralFocus < oldValue {
                    speak("Menos intenso")
                    provideFeedback()
                }
            }
            
        case "activar":
            if currentRoute == .camera && !filterEnabled {
                filterEnabled = true
                speak("Filtro activado")
                provideFeedback()
            }
            
        case "desactivar":
            if currentRoute == .camera && filterEnabled {
                filterEnabled = false
                speak("Filtro desactivado")
                provideFeedback()
            }
            
        case "vr":
            if currentRoute == .camera && !isCardboardMode {
                isCardboardMode = true
                speak("Modo realidad virtual")
                provideFeedback()
            }
            
        case "salir_vr":
            if currentRoute == .camera && isCardboardMode {
                isCardboardMode = false
                speak("Saliendo del modo VR")
                provideFeedback()
            }
            
        // Comandos de ayuda contextual
        case "ayuda":
            let helpText = getContextualHelp()
            speak(helpText)
            
        // Enfermedades (funcionan en lista y cámara)
        case "cataratas":
            selectedIllness = Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts)
            speak("Cataratas")
            provideFeedback()
            
        case "glaucoma":
            selectedIllness = Illness(name: "Glaucoma", description: "Simula visión con glaucoma.", filterType: .glaucoma)
            speak("Glaucoma")
            provideFeedback()
            
        case "macular":
            selectedIllness = Illness(name: "Macular Degeneration", description: "Simula degeneración macular.", filterType: .macularDegeneration)
            speak("Degeneración macular")
            provideFeedback()
            
        case "tunel":
            selectedIllness = Illness(name: "Tunnel Vision", description: "Simula visión en túnel.", filterType: .tunnelVision)
            speak("Visión túnel")
            provideFeedback()
            
        default:
            print("⚠️ Unknown command: \(command)")
        }
    }
    
    // ✅ NUEVO: Ayuda contextual
    private func getContextualHelp() -> String {
        switch currentRoute {
        case .illnessList:
            return "Di: cataratas, glaucoma, macular, túnel para seleccionar una enfermedad"
        case .camera:
            return "Di: cataratas, glaucoma, macular, túnel, más, menos, activar, desactivar, realidad virtual, atrás"
        case .splash:
            return "Espera a que cargue la aplicación"
        }
    }
    
    private func speak(_ text: String) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        utterance.rate = 0.6
        utterance.volume = 0.8
        utterance.pitchMultiplier = 1.0
        
        speechSynthesizer.speak(utterance)
        print("🔊 Speaking: '\(text)'")
    }
    
    private func provideFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // ✅ MEJORADO: Métodos públicos con logging
    func startSpeechRecognition() {
        guard !speechService.isListening else { return }
        speechService.startRecognition()
        print("🎤 Speech recognition started globally")
    }
    
    func stopSpeechRecognition() {
        guard speechService.isListening else { return }
        speechService.stopRecognition()
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        print("🛑 Speech recognition stopped globally")
    }
    
    func toggleSpeechRecognition() {
        if speechService.isListening {
            stopSpeechRecognition()
        } else {
            startSpeechRecognition()
        }
    }
    
    // ✅ NUEVO: Actualizar contexto actual
    func updateCurrentRoute(_ route: AppRoute) {
        currentRoute = route
        print("📍 Current route updated to: \(route)")
    }
    
    func testVoiceCommand(_ command: String) {
        print("🧪 Testing command: '\(command)'")
        processVoiceCommand(command)
    }
    
    deinit {
        speechService.stopRecognition()
        speechSynthesizer.stopSpeaking(at: .immediate)
        cancellables.forEach { $0.cancel() }
    }
}
