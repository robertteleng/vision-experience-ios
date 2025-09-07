//
//  GlobalViewModel.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import Combine
import AVFoundation

class MainViewModel: NSObject, ObservableObject {
    @Published var selectedIllness: Illness?
    @Published var filterEnabled: Bool = true
    @Published var centralFocus: Double = 0.5
    @Published var isCardboardMode: Bool = false

    // Control global de reconocimiento
    @Published var isSpeechEnabled: Bool = true {
        didSet {
            if isSpeechEnabled {
                speechService.startRecognition()
            } else {
                speechService.stopRecognition()
            }
        }
    }

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

    var navigateToIllnessList: (() -> Void)?

    init(speechService: SpeechRecognitionService = SpeechRecognitionService()) {
        self.speechService = speechService
        super.init()
        // Idioma por defecto: español, con fallback inglés
        self.speechService.setPreferredLocales(primary: "es-ES", secondary: "en-US")
        setupSpeechRecognitionBinding()
        // Arrancar si está habilitado
        if isSpeechEnabled {
            self.speechService.requestAuthorization { [weak self] ok in
                if ok { self?.speechService.startRecognition() }
            }
        }
    }

    private func setupSpeechRecognitionBinding() {
        speechService.$lastCommand
            .receive(on: DispatchQueue.main)
            .sink { [weak self] command in
                guard let self = self else { return }
                let lowercased = command.lowercased()
                guard !lowercased.isEmpty else { return }

                if lowercased.contains("volver") || lowercased.contains("atrás") || lowercased.contains("atras") || lowercased.contains("back") || lowercased.contains("go back") {
                    self.navigateToIllnessList?()
                    self.speak("Volviendo a la selección de enfermedad")
                    return
                }
                if lowercased.contains("cataracts") || lowercased.contains("cataratas") {
                    self.selectedIllness = Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts)
                    self.speak("Filtro de cataratas activado")
                } else if lowercased.contains("glaucoma") {
                    self.selectedIllness = Illness(name: "Glaucoma", description: "Simula visión con glaucoma.", filterType: .glaucoma)
                    self.speak("Filtro de glaucoma activado")
                } else if lowercased.contains("macular") || lowercased.contains("degeneración macular") || lowercased.contains("degeneracion macular") {
                    self.selectedIllness = Illness(name: "Macular Degeneration", description: "Simula degeneración macular.", filterType: .macularDegeneration)
                    self.speak("Filtro de degeneración macular activado")
                } else if lowercased.contains("tunnel vision") || lowercased.contains("visión de túnel") || lowercased.contains("vision de tunel") || lowercased.contains("tunel") {
                    self.selectedIllness = Illness(name: "Tunnel Vision", description: "Simula visión en túnel.", filterType: .tunnelVision)
                    self.speak("Filtro de visión en túnel activado")
                }
            }
            .store(in: &cancellables)
    }

    // Coordina TTS con el reconocimiento para evitar auto-transcripción
    func speak(_ text: String) {
        // Pausar reconocimiento mientras habla
        speechService.pauseRecognition()

        let utterance = AVSpeechUtterance(string: text)
        // Ajustar idioma del TTS según preferencias del sistema (o forzar es-ES si quieres)
        if let lang = Locale.preferredLanguages.first {
            utterance.voice = AVSpeechSynthesisVoice(language: lang)
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        synthesizer.speak(utterance)

        // Mantener el sintetizador vivo con una clave de puntero estable
        objc_setAssociatedObject(self, &AssociatedKeys.synthKey, synthesizer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private enum AssociatedKeys {
    // Use a static stored variable as a unique token; its address is a stable key.
    static var synthKey: UInt8 = 0
}

extension MainViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        objc_setAssociatedObject(self, &AssociatedKeys.synthKey, nil, .OBJC_ASSOCIATION_ASSIGN)
        if isSpeechEnabled {
            speechService.resumeRecognition()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        objc_setAssociatedObject(self, &AssociatedKeys.synthKey, nil, .OBJC_ASSOCIATION_ASSIGN)
        if isSpeechEnabled {
            speechService.resumeRecognition()
        }
    }
}
