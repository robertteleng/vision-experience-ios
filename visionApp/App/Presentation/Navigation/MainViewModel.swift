//
//  GlobalViewModel.swift
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

    // CI tuning (Cataracts) — exposed for live tweaking
    @Published var cataractsBloomIntensityBase: Double = CIConfig.shared.cataractsBloomIntensityBase {
        didSet { CIConfig.shared.cataractsBloomIntensityBase = cataractsBloomIntensityBase }
    }
    @Published var cataractsBloomIntensityScale: Double = CIConfig.shared.cataractsBloomIntensityScale {
        didSet { CIConfig.shared.cataractsBloomIntensityScale = cataractsBloomIntensityScale }
    }
    @Published var cataractsBloomRadiusBase: Double = CIConfig.shared.cataractsBloomRadiusBase {
        didSet { CIConfig.shared.cataractsBloomRadiusBase = cataractsBloomRadiusBase }
    }
    @Published var cataractsBloomRadiusScale: Double = CIConfig.shared.cataractsBloomRadiusScale {
        didSet { CIConfig.shared.cataractsBloomRadiusScale = cataractsBloomRadiusScale }
    }
    @Published var cataractsDesaturationMax: Double = CIConfig.shared.cataractsDesaturationMax {
        didSet { CIConfig.shared.cataractsDesaturationMax = cataractsDesaturationMax }
    }
    @Published var cataractsContrastDropMax: Double = CIConfig.shared.cataractsContrastDropMax {
        didSet { CIConfig.shared.cataractsContrastDropMax = cataractsContrastDropMax }
    }

    @ObservedObject var speechService: SpeechRecognitionService
    private var cancellables = Set<AnyCancellable>()

    var navigateToIllnessList: (() -> Void)?

    init(speechService: SpeechRecognitionService = SpeechRecognitionService()) {
        self.speechService = speechService
        setupSpeechRecognitionBinding()
    }

    private func setupSpeechRecognitionBinding() {
        speechService.$lastCommand
            .receive(on: DispatchQueue.main)
            .sink { [weak self] command in
                guard let self = self else { return }
                let lowercased = command.lowercased()
                // Comando para volver atrás (español e inglés)
                if lowercased.contains("volver") || lowercased.contains("atrás") || lowercased.contains("back") || lowercased.contains("go back") {
                    self.navigateToIllnessList?()
                    self.speak("Volviendo a la selección de enfermedad")
                    return
                }
                // Cataracts
                if lowercased.contains("cataracts") || lowercased.contains("cataratas") {
                    self.selectedIllness = Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts)
                    self.speak("Filtro de cataratas activado")
                // Glaucoma
                } else if lowercased.contains("glaucoma") {
                    self.selectedIllness = Illness(name: "Glaucoma", description: "Simula visión con glaucoma.", filterType: .glaucoma)
                    self.speak("Filtro de glaucoma activado")
                // Macular Degeneration
                } else if lowercased.contains("macular") || lowercased.contains("degeneración macular") {
                    self.selectedIllness = Illness(name: "Macular Degeneration", description: "Simula degeneración macular.", filterType: .macularDegeneration)
                    self.speak("Filtro de degeneración macular activado")
                }
            }
            .store(in: &cancellables)
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
