//
//  SpeechRecognitionViewModel.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import Combine
import AVFoundation

protocol SpeechRecognitionDelegate: AnyObject {
    func speechRecognition(didDetectCommand command: VoiceCommand)
}

enum VoiceCommand {
    case selectIllness(IllnessFilterType)
    case increaseIntensity
    case decreaseIntensity
    case enableFilter
    case disableFilter
    case enableVR
    case disableVR
    case navigateBack
    case requestHelp
}

class SpeechRecognitionViewModel: ObservableObject {
    @Published var isListening: Bool = false
    @Published var lastDetectedText: String = ""
    @Published var currentContext: AppRoute = .splash
    @Published var error: String?
    
    weak var delegate: SpeechRecognitionDelegate?
    
    private let speechService: SpeechRecognitionService
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var cancellables = Set<AnyCancellable>()
    
    // Control de estabilización
    private var lastProcessedText: String = ""
    private var textStabilizationTimer: Timer?
    private let stabilizationDelay: TimeInterval = 1.5
    
    // Control de cooldown
    private var lastCommandTime: Date = Date.distantPast
    private let commandCooldown: TimeInterval = 2.0
    
    init(speechService: SpeechRecognitionService = SpeechRecognitionService()) {
        self.speechService = speechService
        setupBindings()
        requestAuthorization()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        speechService.$isListening
            .receive(on: DispatchQueue.main)
            .assign(to: \.isListening, on: self)
            .store(in: &cancellables)
        
        speechService.$error
            .receive(on: DispatchQueue.main)
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
        
        speechService.$lastCommand
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastDetectedText, on: self)
            .store(in: &cancellables)
        
        // ✅ UPDATED: Usar callback en lugar de Combine para evitar duplicación
        speechService.onCommand = { [weak self] text in
            DispatchQueue.main.async {
                self?.handleIncomingText(text.lowercased())
            }
        }
    }
    
    private func requestAuthorization() {
        speechService.requestAuthorization { [weak self] authorized in
            if authorized {
                print("✅ Speech recognition authorized")
            } else {
                print("❌ Speech recognition not authorized")
                self?.error = "Speech recognition not authorized"
            }
        }
    }
    
    // MARK: - Public Methods
    
    func startListening() {
        speechService.startRecognition()
        print("🎤 Speech recognition started")
    }
    
    func stopListening() {
        speechService.stopRecognition()
        textStabilizationTimer?.invalidate()
        speechSynthesizer.stopSpeaking(at: .immediate)
        print("🛑 Speech recognition stopped")
    }
    
    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }
    
    func updateContext(_ context: AppRoute) {
        currentContext = context
        lastProcessedText = ""
        textStabilizationTimer?.invalidate()
        print("📍 Speech context updated to: \(context)")
    }
    
    func simulateCommand(_ text: String) {
        print("🧪 Simulating command: '\(text)'")
        lastCommandTime = Date.distantPast
        lastProcessedText = ""
        processStabilizedText(text.lowercased())
    }
    
    // MARK: - Text Processing
    
    private func handleIncomingText(_ text: String) {
        print("📥 Incoming: '\(text)'")
        lastDetectedText = text
        
        textStabilizationTimer?.invalidate()
        textStabilizationTimer = Timer.scheduledTimer(withTimeInterval: stabilizationDelay, repeats: false) { [weak self] _ in
            self?.processStabilizedText(text)
        }
    }
    
    private func processStabilizedText(_ text: String) {
        print("⏳ Processing stabilized: '\(text)'")
        
        guard text != lastProcessedText else {
            print("🔄 Skipping repeated text")
            return
        }
        lastProcessedText = text
        
        let now = Date()
        guard now.timeIntervalSince(lastCommandTime) > commandCooldown else {
            print("⏰ Cooldown active")
            return
        }
        
        guard let command = extractCommand(from: text) else {
            return
        }
        
        print("🚀 Executing: \(command)")
        lastCommandTime = now
        
        delegate?.speechRecognition(didDetectCommand: command)
        provideFeedback(for: command)
    }
    
    private func extractCommand(from text: String) -> VoiceCommand? {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = cleanText.components(separatedBy: " ").filter { !$0.isEmpty }
        
        print("🔍 Analyzing: '\(cleanText)' (\(words.count) words) in \(currentContext)")
        
        // Definir comandos válidos por contexto
        let commandMap: [(pattern: String, command: VoiceCommand, contexts: [AppRoute])] = [
            // Enfermedades
            ("cataratas", .selectIllness(.cataracts), [.illnessList, .camera]),
            ("cataracts", .selectIllness(.cataracts), [.illnessList, .camera]),
            ("glaucoma", .selectIllness(.glaucoma), [.illnessList, .camera]),
            ("macular", .selectIllness(.macularDegeneration), [.illnessList, .camera]),
            ("túnel", .selectIllness(.tunnelVision), [.illnessList, .camera]),
            ("tunel", .selectIllness(.tunnelVision), [.illnessList, .camera]),
            ("tunnel", .selectIllness(.tunnelVision), [.illnessList, .camera]),
            
            // Control de intensidad
            ("más", .increaseIntensity, [.camera]),
            ("menos", .decreaseIntensity, [.camera]),
            
            // Control de filtros
            ("activar", .enableFilter, [.camera]),
            ("desactivar", .disableFilter, [.camera]),
            
            // Navegación
            ("volver", .navigateBack, [.camera]),
            ("back", .navigateBack, [.camera]),
            
            // VR
            ("cardboard", .enableVR, [.camera]),
            ("realidad", .enableVR, [.camera]),
            
            // Ayuda
            ("ayuda", .requestHelp, [.illnessList, .camera])
        ]
        
        // Buscar comando válido (prioridad a última palabra)
        let validCommands = commandMap.filter { $0.contexts.contains(currentContext) }
        
        // Estrategia 1: Última palabra
        for i in stride(from: words.count - 1, through: 0, by: -1) {
            let word = words[i]
            if let match = validCommands.first(where: { $0.pattern == word }) {
                print("✅ Found in last words: '\(word)'")
                return match.command
            }
        }
        
        // Estrategia 2: Cualquier palabra
        for word in words {
            if let match = validCommands.first(where: { $0.pattern == word }) {
                print("✅ Found anywhere: '\(word)'")
                return match.command
            }
        }
        
        // Estrategia 3: Texto completo (para comandos cortos)
        if words.count <= 2 {
            if let match = validCommands.first(where: { $0.pattern == cleanText }) {
                print("✅ Full text match: '\(cleanText)'")
                return match.command
            }
        }
        
        print("❌ No command found in: '\(cleanText)'")
        return nil
    }
    
    // MARK: - Feedback
    
    private func provideFeedback(for command: VoiceCommand) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let feedbackText = getFeedbackText(for: command)
        speak(feedbackText)
    }
    
    private func getFeedbackText(for command: VoiceCommand) -> String {
        switch command {
        case .selectIllness(let type):
            switch type {
            case .cataracts: return "Cataratas"
            case .glaucoma: return "Glaucoma"
            case .macularDegeneration: return "Degeneración macular"
            case .tunnelVision: return "Visión túnel"
            case .hemianopsia: return "Hemianopsia"
            }
        case .increaseIntensity: return "Más intenso"
        case .decreaseIntensity: return "Menos intenso"
        case .enableFilter: return "Filtro activado"
        case .disableFilter: return "Filtro desactivado"
        case .enableVR: return "Modo VR"
        case .disableVR: return "Saliendo de VR"
        case .navigateBack: return "Volviendo"
        case .requestHelp: return getContextualHelp()
        }
    }
    
    private func getContextualHelp() -> String {
        switch currentContext {
        case .illnessList:
            return "Di: cataratas, glaucoma, macular, túnel"
        case .camera:
            return "Di: cataratas, glaucoma, macular, túnel, más, menos, activar, desactivar, volver"
        case .splash:
            return "Espera a que cargue"
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
        
        speechSynthesizer.speak(utterance)
        print("🔊 Speaking: '\(text)'")
    }
    
    deinit {
        stopListening()
        textStabilizationTimer?.invalidate()
        cancellables.forEach { $0.cancel() }
    }
}
