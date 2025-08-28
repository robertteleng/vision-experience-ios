//
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
                // Diabetic Retinopathy
                } else if lowercased.contains("retinopathy") || lowercased.contains("retinopatía") || lowercased.contains("diabetic") || lowercased.contains("diabética") {
                    self.selectedIllness = Illness(name: "Diabetic Retinopathy", description: "Simula retinopatía diabética.", filterType: .diabeticRetinopathy)
                    self.speak("Filtro de retinopatía diabética activado")
                // Color Blindness (Deuteranopia)
                } else if lowercased.contains("deuteranopia") || lowercased.contains("deuteranopia") || lowercased.contains("color blindness") || lowercased.contains("daltonismo") {
                    self.selectedIllness = Illness(name: "Color Blindness (Deuteranopia)", description: "Simula deuteranopia.", filterType: .deuteranopia)
                    self.speak("Filtro de deuteranopia activado")
                // Astigmatism
                } else if lowercased.contains("astigmatism") || lowercased.contains("astigmatismo") {
                    self.selectedIllness = Illness(name: "Astigmatism", description: "Simula astigmatismo.", filterType: .astigmatism)
                    self.speak("Filtro de astigmatismo activado")
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
