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
    
    // ✅ AÑADIDO: Speech synthesizer reutilizable
    private let speechSynthesizer = AVSpeechSynthesizer()

    var navigateToIllnessList: (() -> Void)?

    init(speechService: SpeechRecognitionService = SpeechRecognitionService()) {
        self.speechService = speechService
        setupSpeechRecognitionBinding()
        requestSpeechAuthorization()
    }
    
    // ✅ AÑADIDO: Solicitar permisos al inicializar
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
        
        // ✅ AÑADIDO: Observar errores del speech service
        speechService.$error
            .compactMap { $0 }
            .sink { error in
                print("🚨 Speech recognition error: \(error)")
            }
            .store(in: &cancellables)
    }
    
    // ✅ MEJORADO: Función separada para procesar comandos con más opciones
    private func processVoiceCommand(_ command: String) {
        print("🎤 Processing voice command: \(command)")
        
        // Comando para volver atrás (español e inglés)
        if command.contains("volver") || command.contains("atrás") || command.contains("back") || command.contains("go back") {
            navigateToIllnessList?()
            speak("Volviendo a la selección de enfermedad")
            provideFeedback()
            return
        }
        
        // ✅ AÑADIDO: Comandos para controlar intensidad
        if command.contains("aumentar") || command.contains("más") || command.contains("increase") || command.contains("more") || command.contains("stronger") {
            centralFocus = min(1.0, centralFocus + 0.2)
            speak("Intensidad aumentada")
            provideFeedback()
            return
        }
        
        if command.contains("disminuir") || command.contains("menos") || command.contains("decrease") || command.contains("less") || command.contains("weaker") {
            centralFocus = max(0.0, centralFocus - 0.2)
            speak("Intensidad reducida")
            provideFeedback()
            return
        }
        
        // ✅ AÑADIDO: Comandos para activar/desactivar filtros
        if command.contains("activar filtro") || command.contains("enable filter") || command.contains("encender") {
            filterEnabled = true
            speak("Filtro activado")
            provideFeedback()
            return
        }
        
        if command.contains("desactivar filtro") || command.contains("disable filter") || command.contains("apagar") {
            filterEnabled = false
            speak("Filtro desactivado")
            provideFeedback()
            return
        }
        
        // ✅ AÑADIDO: Comando para salir del modo VR
        if command.contains("salir") || command.contains("exit") || command.contains("stop vr") || command.contains("quit") {
            isCardboardMode = false
            speak("Saliendo del modo realidad virtual")
            provideFeedback()
            return
        }
        
        // ✅ AÑADIDO: Comando para ayuda
        if command.contains("ayuda") || command.contains("help") || command.contains("comandos") {
            speak("Puedes decir: cataratas, glaucoma, macular, túnel, aumentar, disminuir, activar filtro, desactivar filtro, salir, volver")
            return
        }
        
        // Comandos para cambiar enfermedad
        if command.contains("cataracts") || command.contains("cataratas") {
            selectedIllness = Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts)
            speak("Filtro de cataratas activado")
            provideFeedback()
        } else if command.contains("glaucoma") {
            selectedIllness = Illness(name: "Glaucoma", description: "Simula visión con glaucoma.", filterType: .glaucoma)
            speak("Filtro de glaucoma activado")
            provideFeedback()
        } else if command.contains("macular") || command.contains("degeneración macular") {
            selectedIllness = Illness(name: "Macular Degeneration", description: "Simula degeneración macular.", filterType: .macularDegeneration)
            speak("Filtro de degeneración macular activado")
            provideFeedback()
        } else if command.contains("tunnel vision") || command.contains("visión de túnel") || command.contains("vision de tunel") || command.contains("túnel") || command.contains("tunel") {
            selectedIllness = Illness(name: "Tunnel Vision", description: "Simula visión en túnel.", filterType: .tunnelVision)
            speak("Filtro de visión en túnel activado")
            provideFeedback()
        }
    }
    
    // ✅ AÑADIDO: Feedback háptico para confirmar comandos
    private func provideFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func speak(_ text: String) {
        // ✅ MEJORADO: Cancelar speech anterior antes de hablar
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES") // Español
        utterance.rate = 0.5 // Velocidad media
        utterance.volume = 0.8 // Volumen alto pero no máximo
        
        speechSynthesizer.speak(utterance)
    }
    
    // ✅ AÑADIDO: Métodos públicos para controlar speech recognition
    func startSpeechRecognition() {
        speechService.startRecognition()
    }
    
    func stopSpeechRecognition() {
        speechService.stopRecognition()
    }
    
    func toggleSpeechRecognition() {
        if speechService.isListening {
            speechService.stopRecognition()
        } else {
            speechService.startRecognition()
        }
    }
    
    // ✅ AÑADIDO: Cleanup al destruir
    deinit {
        speechService.stopRecognition()
        speechSynthesizer.stopSpeaking(at: .immediate)
        cancellables.forEach { $0.cancel() }
    }
}

