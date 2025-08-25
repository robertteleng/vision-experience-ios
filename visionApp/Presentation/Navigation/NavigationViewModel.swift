import SwiftUI
import Combine
import AVFoundation

enum AppScreen {
    case splash, illnessList, camera
}

class NavigationViewModel: ObservableObject {
    @Published var currentView: AppScreen = .splash
    @Published var selectedIllness: Illness?
    @Published var filterEnabled: Bool = true
    @Published var centralFocus: Double = 0.5

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
                    self.currentView = .camera
                    self.speak("Cataracts filter activated")
                } else if command.contains("glaucoma") {
                    self.selectedIllness = Illness(name: "Glaucoma", description: "Simulates glaucoma vision.", filterType: .glaucoma)
                    self.currentView = .camera
                    self.speak("Glaucoma filter activated")
                } else if command.contains("macular") {
                    self.selectedIllness = Illness(name: "Macular Degeneration", description: "Simulates macular degeneration vision.", filterType: .macularDegeneration)
                    self.currentView = .camera
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
