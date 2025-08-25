//
//  GlobalViewModel.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import Combine
import AVFoundation


class GlobalViewModel: ObservableObject {
    @Published var selectedIllness: Illness?
    @Published var filterEnabled: Bool = true
    @Published var centralFocus: Double = 0.5
    @Published var isCardboardMode: Bool = false

    @ObservedObject var speechService: SpeechRecognitionService
    private var cancellables = Set<AnyCancellable>()

    init(speechService: SpeechRecognitionService = SpeechRecognitionService()) {
        self.speechService = speechService
        setupSpeechRecognitionBinding()
    }

    private func setupSpeechRecognitionBinding() {
        speechService.$lastCommand
            .receive(on: DispatchQueue.main)
            .sink { [weak self] command in
                guard let self = self else { return }
                // Navigation and illness selection voice commands
                if command.contains("cataracts") {
                    self.selectedIllness = Illness(name: "Cataracts", description: "Simulates cataracts vision.", filterType: .cataracts)
                    // Navegación: usa AppRouter en la vista principal
                    self.speak("Cataracts filter activated")
                } else if command.contains("glaucoma") {
                    self.selectedIllness = Illness(name: "Glaucoma", description: "Simulates glaucoma vision.", filterType: .glaucoma)
                    // Navegación: usa AppRouter en la vista principal
                    self.speak("Glaucoma filter activated")
                } else if command.contains("macular") {
                    self.selectedIllness = Illness(name: "Macular Degeneration", description: "Simulates macular degeneration vision.", filterType: .macularDegeneration)
                    // Navegación: usa AppRouter en la vista principal
                    self.speak("Macular degeneration filter activated")
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
