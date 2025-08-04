//
//  ContentView.swift
//  visionApp
//
//  Main user interface logic, state management and navigation for the app.
//  Implements MVVM principles: views are separated, state is handled by NavigationViewModel.
//  Includes voice command processing and basic AR/Camera simulation.
//

import SwiftUI
import AVFoundation
import Speech

// MARK: - Main Entry Point and App Navigation

struct ContentView: View {
    @StateObject private var navigationViewModel = NavigationViewModel()
    @State private var isCardboardMode = false

    var body: some View {
        NavigationView {
            VStack {
                // Render the main screens based on the navigation state
                switch navigationViewModel.currentView {
                case .splash:
                    SplashView(navigationViewModel: navigationViewModel)
                case .illnessList:
                    IllnessListView(navigationViewModel: navigationViewModel)
                case .camera:
                    CameraView(navigationViewModel: navigationViewModel)
                }

                // Show the Cardboard button only in the illness list screen
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
            // Request speech recognition authorization when the app launches
            navigationViewModel.setupSpeech()
        }
    }
}

// MARK: - Navigation Screens Enumeration

enum AppScreen {
    case splash, illnessList, camera
}

// MARK: - Central Navigation and State ViewModel

class NavigationViewModel: ObservableObject {
    @Published var currentView: AppScreen = .splash
    @Published var selectedIllness: String?
    @Published var filterEnabled: Bool = true
    @Published var centralFocus: Double = 0.5

    // Speech recognition dependencies
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // Request permission for speech recognition
    func setupSpeech() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus != .authorized {
                print("Speech recognition not authorized.")
            }
        }
    }

    // Start processing voice commands
    func startVoiceRecognition() {
        try? startRecording()
    }

    // Stop processing voice commands
    func stopVoiceRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    // Begin recording and interpret recognized voice commands
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

                // Navigation and illness selection voice commands
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

                // Additional navigation commands
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
                    default: break
                    }
                } else if command.contains("next") {
                    switch self.currentView {
                    case .splash:
                        self.currentView = .illnessList
                    case .illnessList:
                        self.currentView = .camera
                    default: break
                    }
                }

                // Filter control voice commands
                else if command.contains("enable filter") {
                    self.filterEnabled = true
                    self.speak("Filter enabled")
                } else if command.contains("disable filter") {
                    self.filterEnabled = false
                    self.speak("Filter disabled")
                }

                // Filter severity/central focus control
                else if command.contains("increase severity") {
                    self.centralFocus = min(self.centralFocus + 0.1, 1.0)
                    self.speak("Severity increased")
                } else if command.contains("decrease severity") {
                    self.centralFocus = max(self.centralFocus - 0.1, 0.1)
                    self.speak("Severity decreased")
                }
            }

            // End recognition session if necessary
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // Install audio tap to capture live microphone input
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    // Speak a message aloud for accessibility/confirmation
    private func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

// MARK: - Splash Screen with Lottie Animation and Logo

struct SplashView: View {
    var navigationViewModel: NavigationViewModel
    @State private var animate = false

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                // Lottie animation centered on the screen
                LottieView(animationName: "eyeAnimation", loopMode: .loop)
                    .frame(width: 200, height: 200)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeIn(duration: 1.0), value: animate)

                Spacer()

                // Logo centered at the bottom (should exist in bundle)
                if let path = Bundle.main.path(forResource: "logo", ofType: "png"),
                   let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .opacity(0.8)
                        .padding(.bottom, 30)
                }
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

// MARK: - List of Illnesses with Back Navigation

struct IllnessListView: View {
    var navigationViewModel: NavigationViewModel
    let illnesses = ["Cataracts", "Glaucoma", "Macular Degeneration"]

    var body: some View {
        VStack {
            // Manual back button at the top-left
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
            // List of illnesses, tap to go to camera view with corresponding filter
            List(illnesses, id: \.self) { illness in
                Button(action: {
                    navigationViewModel.selectedIllness = illness
                    navigationViewModel.currentView = .camera
                }) {
                    Text(illness)
                }
            }
            .navigationTitle("Illness List")
        }
    }
}

// MARK: - Camera Simulation View with Filter Controls

struct CameraView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    @State private var isLandscape = UIDevice.current.orientation.isLandscape

    var body: some View {
        ZStack {
            if isLandscape {
                VStack {
                    // Camera title and selected illness display
                    Text("Camera View")
                        .font(.title)
                    if let illness = navigationViewModel.selectedIllness {
                        Text("Selected: \(illness)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    // Camera preview (placeholder rectangle) with optional filter overlay
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

                    // Central vision severity slider and UI icons
                    VStack {
                        Slider(value: $navigationViewModel.centralFocus, in: 0.1...1.0)
                            .padding()
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

                    // Floating control bar: enable/disable filter and back button
                    HStack(spacing: 30) {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            navigationViewModel.filterEnabled.toggle()
                        }) {
                            Image(systemName: navigationViewModel.filterEnabled ? "eye.slash.circle.fill" : "eye.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(navigationViewModel.filterEnabled ? .red : .green)
                        }
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
                // If not in landscape, show a prompt to rotate the device
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
        // Listen to device orientation changes and update layout
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            let orientation = UIDevice.current.orientation
            if orientation.isValidInterfaceOrientation {
                isLandscape = orientation.isLandscape
            }
        }
    }
}

// MARK: - Visual Filter Overlay for Each Illness

struct ColorOverlay: View {
    let illness: String
    var centralFocus: Double = 0.5

    // Compute overlay color/gradient based on selected illness
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
        // Special radial effect for glaucoma, solid overlay for others
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

// MARK: - Lottie Animation Wrapper for Splash Screen

import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        // Load and configure the Lottie animation
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
