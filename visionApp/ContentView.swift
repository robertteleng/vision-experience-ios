import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    @StateObject private var navigationViewModel = NavigationViewModel()
    @State private var showCardboard = false
    @State private var isCardboardMode = false

    var body: some View {
        NavigationView {
            VStack {
                switch navigationViewModel.currentView {
                case .splash:
                    SplashView(navigationViewModel: navigationViewModel)
                case .illnessList:
                    IllnessListView(navigationViewModel: navigationViewModel)
                case .camera:
                    CameraView(navigationViewModel: navigationViewModel)
                }

                if navigationViewModel.currentView != .camera && navigationViewModel.currentView != .splash {
                    Button(action: {
                        isCardboardMode.toggle()
                        if isCardboardMode {
                            navigationViewModel.startVoiceRecognition()
                        } else {
                            navigationViewModel.stopVoiceRecognition()
                        }
                    }) {
                        Image(systemName: "eyeglasses")
                            .resizable()
                            .frame(width: 24, height: 16)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(isCardboardMode ? 1.0 : 0.3))
                            )
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            navigationViewModel.setupSpeech()
        }
    }
}

enum AppScreen {
    case splash, illnessList, camera
}

class NavigationViewModel: ObservableObject {
    @Published var currentView: AppScreen = .splash
    @Published var selectedIllness: String?
    @Published var filterEnabled: Bool = true
    @Published var centralFocus: Double = 0.5

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func setupSpeech() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus != .authorized {
                print("Speech recognition not authorized.")
            }
        }
    }

    func startVoiceRecognition() {
        try? startRecording()
    }

    private func startRecording() throws {
        recognitionTask?.cancel()
        self.recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let command = result.bestTranscription.formattedString.lowercased()
                if command.contains("cataracts") {
                    self.selectedIllness = "Cataracts"
                    self.currentView = .camera
                    self.speak("Cataracts filter activated")
                    return
                } else if command.contains("glaucoma") {
                    self.selectedIllness = "Glaucoma"
                    self.currentView = .camera
                    self.speak("Glaucoma filter activated")
                    return
                } else if command.contains("macular") {
                    self.selectedIllness = "Macular Degeneration"
                    self.currentView = .camera
                    self.speak("Macular Degeneration filter activated")
                    return
                }
                if command.contains("list") {
                    self.currentView = .illnessList
                } else if command.contains("camera") {
                    self.currentView = .camera
                } else if command.contains("splash") {
                    self.currentView = .splash
                } else if command.contains("back") {
                    switch self.currentView {
                    case .camera:
                        self.currentView = .illnessList
                    case .illnessList:
                        self.currentView = .splash
                    default:
                        break
                    }
                } else if command.contains("next") {
                    switch self.currentView {
                    case .splash:
                        self.currentView = .illnessList
                    case .illnessList:
                        self.currentView = .camera
                    default:
                        break
                    }
                } else if command.contains("enable filter") {
                    self.filterEnabled = true
                    self.speak("Filter enabled")
                } else if command.contains("disable filter") {
                    self.filterEnabled = false
                    self.speak("Filter disabled")
                } else if command.contains("increase severity") {
                    self.centralFocus = min(self.centralFocus + 0.1, 1.0)
                    self.speak("Severity increased")
                } else if command.contains("decrease severity") {
                    self.centralFocus = max(self.centralFocus - 0.1, 0.1)
                    self.speak("Severity decreased")
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopVoiceRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    private func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

import SwiftUI

struct SplashView: View {
    var navigationViewModel: NavigationViewModel
    @State private var animate = false

    var body: some View {
        
        ZStack {
            VStack {
                Spacer()
                // Animación centrada verticalmente
                LottieView(animationName: "eyeAnimation", loopMode: .loop)
                    .frame(width: 200, height: 200)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeIn(duration: 1.0), value: animate)
                
                Spacer()
                
                
                // Logo en la parte inferior centrado
                Image("logo", bundle: .main)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 80, height: 80)
                    .opacity(0.8)
                    .padding(.bottom, 30)
                
            }
        }
        .onAppear {
            animate = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                navigationViewModel.currentView = .illnessList
            }
        }
    }
}

struct IllnessListView: View {
    var navigationViewModel: NavigationViewModel

    let illnesses = ["Cataracts", "Glaucoma", "Macular Degeneration"]

    var body: some View {
        VStack {
            // Back button at the top-left
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    navigationViewModel.currentView = .splash
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                        .padding()
                }
                Spacer()
            }

            // Illness list
            List(illnesses, id: \.self) { illness in
                Button(action: {
                    navigationViewModel.selectedIllness = illness
                    navigationViewModel.currentView = .camera
                }) {
                    Text(illness)
                }
            }
            .navigationTitle("Illness List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Camera") {
                        navigationViewModel.currentView = .camera
                    }
                }
            }
        }
    }
}

struct CameraView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    @State private var isLandscape = UIDevice.current.orientation.isLandscape

    var body: some View {
        ZStack {
            if isLandscape {
                VStack {
                    Text("Camera View")
                        .font(.title)

                    if let illness = navigationViewModel.selectedIllness {
                        Text("Selected: \(illness)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 300)

                        if navigationViewModel.filterEnabled, let illness = navigationViewModel.selectedIllness {
                            ColorOverlay(illness: illness, centralFocus: navigationViewModel.centralFocus)
                                .frame(height: 300)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: illness)
                        }
                    }

                    VStack {
                        // Slider para ajustar visión central
                        Slider(value: $navigationViewModel.centralFocus, in: 0.1...1.0)
                            .padding()

                        // Iconos semitransparentes
                        HStack(spacing: 30) {
                            Image(systemName: "eye")
                            Image(systemName: "exclamationmark.circle")
                            Image(systemName: "gearshape")
                        }
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.bottom)
                    }

                    Spacer()

                    HStack(spacing: 30) {
                        // Botón de filtro
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            navigationViewModel.filterEnabled.toggle()
                        }) {
                            Image(systemName: navigationViewModel.filterEnabled ? "eye.slash.circle.fill" : "eye.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(navigationViewModel.filterEnabled ? .red : .green)
                        }

                        // Botón de retroceso
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            navigationViewModel.currentView = .illnessList
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.bottom)
                }
                .padding()
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "iphone.landscape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    Text("Please rotate your device")
                        .font(.title2)
                        .padding()
                    Spacer()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            let orientation = UIDevice.current.orientation
            if orientation.isValidInterfaceOrientation {
                isLandscape = orientation.isLandscape
            }
        }
    }
}

struct ColorOverlay: View {
    let illness: String
    var centralFocus: Double = 0.5

    var overlayColor: Color {
        switch illness.lowercased() {
        case "cataracts":
            return Color.white.opacity(0.6)
        case "glaucoma":
            return Color.black.opacity(0.5)
        case "macular degeneration":
            return Color.yellow.opacity(0.4)
        default:
            return Color.clear
        }
    }

    var body: some View {
        if illness.lowercased() == "glaucoma" {
            RadialGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                center: .center,
                startRadius: CGFloat(centralFocus * 50),
                endRadius: CGFloat(centralFocus * 200)
            )
            .blendMode(.multiply)
        } else {
            Rectangle()
                .fill(overlayColor)
                .blendMode(.multiply)
        }
    }
}


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode

    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        animationView.animation = LottieAnimation.named(animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
