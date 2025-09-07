//
//  SpeechRecognitionService.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
<<<<<<< HEAD
//  Service to manage continuous speech recognition with multilingual support (en/es),
//  safe start/stop, and SwiftUI-friendly state updates.
//
=======
>>>>>>> illness-filters-temp

import Foundation
import Speech
import Combine
import AVFoundation

<<<<<<< HEAD
class SpeechRecognitionService: NSObject, ObservableObject {
    // Public observable state
    @Published var lastCommand: String = ""
    @Published var isAuthorized: Bool = false
    @Published var isRunning: Bool = false
    @Published var errorMessage: String?

    // Configuration
    private(set) var localeIdentifier: String = Locale.current.identifier // e.g., "en-US", "es-ES"
    private var shouldContinueListening: Bool = false

    // Apple Speech + Audio
    private var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
=======
final class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var lastCommand: String = ""
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isAuthorized: Bool = false

    // Idiomas soportados: primario español y secundario inglés
    private(set) var primaryLocaleID: String = "es-ES"
    private(set) var secondaryLocaleID: String = "en-US"

    private var speechRecognizer: SFSpeechRecognizer?
>>>>>>> illness-filters-temp
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

<<<<<<< HEAD
    // Combine
    private var cancellables = Set<AnyCancellable>()

    // Throttling partial results to avoid spamming UI
    private var lastUpdateTime: TimeInterval = 0
    private let minUpdateInterval: TimeInterval = 0.25

    // MARK: - Authorization
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        // Request both speech and microphone permissions
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self = self else { return }
            let authorized = (authStatus == .authorized)
            DispatchQueue.main.async {
                self.isAuthorized = authorized
                completion?(authorized)
            }
        }
    }

    // MARK: - Language
    func setLanguage(_ identifier: String) {
        // Restart if running
        let wasRunning = isRunning
        stopRecognition()
        localeIdentifier = identifier
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: identifier))
        if wasRunning { startRecognition() }
    }

    // Convenience helpers
    func useEnglishUS() { setLanguage("en-US") }
    func useSpanishES() { setLanguage("es-ES") }

    // MARK: - Control
    func startRecognition(language identifier: String? = nil) {
        if let id = identifier { setLanguage(id) }

        // Ensure permission first
        if !isAuthorized {
            requestAuthorization { [weak self] ok in
                guard let self = self else { return }
                if ok { self.internalStart() } else { self.publishError("Speech not authorized") }
            }
        } else {
            internalStart()
        }
    }

    func stopRecognition() {
        shouldContinueListening = false
        guard isRunning else { return }

        audioEngine.stop()
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        isRunning = false
    }

    // MARK: - Internals
    private func internalStart() {
        // If already running, reset cleanly
        if isRunning { stopRecognition() }

        shouldContinueListening = true
        do {
            try configureAudioSession()
            try startEngineAndTask()
            isRunning = true
        } catch {
            publishError(error.localizedDescription)
            isRunning = false
        }
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        // Use playAndRecord to allow TTS feedback while listening; duck others to reduce background audio
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startEngineAndTask() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { throw NSError(domain: "Speech", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create recognition request"]) }
        recognitionRequest.shouldReportPartialResults = true
        // Prefer on-device if available for responsiveness, but let the system decide
        if #available(iOS 13.0, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        // Create or update recognizer with current locale
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw NSError(domain: "Speech", code: -2, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer unavailable for locale \(localeIdentifier)"])
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        lastUpdateTime = 0
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let now = CFAbsoluteTimeGetCurrent()
                let command = result.bestTranscription.formattedString.lowercased()
                if now - self.lastUpdateTime > self.minUpdateInterval || result.isFinal {
                    DispatchQueue.main.async {
                        self.lastCommand = command
                    }
                    self.lastUpdateTime = now
                }
                if result.isFinal {
                    // Restart to keep continuous listening
                    self.restartIfNeeded()
                }
            }

            if let error = error {
                // Auto-recover on errors if we should continue
                self.publishError(error.localizedDescription)
                self.restartIfNeeded(delay: 0.6)
            }
        }
    }

    private func restartIfNeeded(delay: TimeInterval = 0.2) {
        guard shouldContinueListening else { return }
        // Restart recognition task while keeping the engine running for smoother UX
        recognitionTask?.cancel()
        recognitionTask = nil

        // Recreate request and task after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = self.recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            if #available(iOS 13.0, *) { recognitionRequest.requiresOnDeviceRecognition = false }

            guard let speechRecognizer = self.speechRecognizer, speechRecognizer.isAvailable else { return }
            self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                if let result = result {
                    let now = CFAbsoluteTimeGetCurrent()
                    let command = result.bestTranscription.formattedString.lowercased()
                    if now - self.lastUpdateTime > self.minUpdateInterval || result.isFinal {
                        DispatchQueue.main.async { self.lastCommand = command }
                        self.lastUpdateTime = now
                    }
                    if result.isFinal { self.restartIfNeeded() }
                }
                if let error = error {
                    self.publishError(error.localizedDescription)
                    self.restartIfNeeded(delay: 0.8)
=======
    // Fallback control
    private var usingPrimaryLocale: Bool = true
    private var noUsefulResultTimer: Timer?
    private let fallbackTimeout: TimeInterval = 4.0 // segundos sin comandos útiles => probar el otro idioma

    // Palabras clave mínimas para considerar “resultado útil”
    // Se puede ampliar según tus necesidades
    private let keywordsES: [String] = [
        "volver", "atrás", "atras", "cataratas", "glaucoma", "macular", "degeneración macular", "degeneracion macular", "visión de túnel", "vision de tunel", "tunel"
    ]
    private let keywordsEN: [String] = [
        "back", "go back", "cataracts", "glaucoma", "macular", "tunnel vision"
    ]

    // MARK: - Authorization

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            let speechAuth = (authStatus == .authorized)

            // iOS 17+: Use AVAudioApplication
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { micGranted in
                    DispatchQueue.main.async {
                        let granted = speechAuth && micGranted
                        self?.isAuthorized = granted
                        completion(granted)
                    }
                }
            } else {
                // iOS < 17: Fallback to AVAudioSession
                AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
                    DispatchQueue.main.async {
                        let granted = speechAuth && micGranted
                        self?.isAuthorized = granted
                        completion(granted)
                    }
>>>>>>> illness-filters-temp
                }
            }
        }
    }

<<<<<<< HEAD
    private func publishError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = message
        }
=======
    // MARK: - Locale management

    func setPreferredLocales(primary: String, secondary: String) {
        primaryLocaleID = primary
        secondaryLocaleID = secondary
        // Si está corriendo, reiniciamos con el nuevo idioma principal
        if isRunning {
            restart(withPrimary: true)
        }
    }

    // MARK: - Public control

    func startRecognition() {
        guard !isRunning else { return }
        guard isAuthorized else {
            requestAuthorization { [weak self] ok in
                if ok { self?.startRecognition() }
            }
            return
        }
        usingPrimaryLocale = true
        do {
            try startRecording(localeID: primaryLocaleID)
            isRunning = true
            scheduleFallbackTimer()
        } catch {
            stopRecognition()
        }
    }

    func stopRecognition() {
        invalidateFallbackTimer()

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isRunning = false
    }

    func pauseRecognition() {
        stopRecognition()
    }

    func resumeRecognition() {
        startRecognition()
    }

    // MARK: - Private

    private func startRecording(localeID: String) throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        // Configurar recognizer para el idioma solicitado
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeID))

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw NSError(domain: "Speech", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available for \(localeID)"])
        }

        // Sesión de audio para reconocer y permitir TTS
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord,
                                     mode: .measurement,
                                     options: [.duckOthers, .mixWithOthers, .defaultToSpeaker, .allowBluetoothHFP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let transcript = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.lastCommand = transcript
                }
                // Si detectamos keywords, reseteamos el temporizador de fallback
                if self.containsKeywords(in: transcript, localeID: localeID) {
                    self.scheduleFallbackTimer()
                }

                if result.isFinal {
                    // Reiniciar para mantener la sesión viva y reconsiderar idioma
                    self.restart(withPrimary: true) // siempre volvemos a primario tras un final
                }
            }

            if let _ = error {
                // Error: reiniciar tras breve retardo usando el idioma primario
                self.restart(withPrimary: true, delay: 0.3)
            }
        }
    }

    private func containsKeywords(in text: String, localeID: String) -> Bool {
        let lower = text.lowercased()
        if localeID.hasPrefix("es") {
            return keywordsES.contains(where: { lower.contains($0) })
        } else {
            return keywordsEN.contains(where: { lower.contains($0) })
        }
    }

    private func scheduleFallbackTimer() {
        invalidateFallbackTimer()
        noUsefulResultTimer = Timer.scheduledTimer(withTimeInterval: fallbackTimeout, repeats: false) { [weak self] _ in
            guard let self = self, self.isRunning else { return }
            // Si no hemos visto keywords en el tiempo dado, probamos el otro idioma
            self.toggleLanguageAndRestart()
        }
        RunLoop.main.add(noUsefulResultTimer!, forMode: .common)
    }

    private func invalidateFallbackTimer() {
        noUsefulResultTimer?.invalidate()
        noUsefulResultTimer = nil
    }

    private func toggleLanguageAndRestart() {
        usingPrimaryLocale.toggle()
        restart(withPrimary: usingPrimaryLocale)
    }

    private func restart(withPrimary usePrimary: Bool, delay: TimeInterval = 0.0) {
        stopRecognition()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            do {
                let locale = usePrimary ? self.primaryLocaleID : self.secondaryLocaleID
                try self.startRecording(localeID: locale)
                self.isRunning = true
                self.scheduleFallbackTimer()
            } catch {
                self.isRunning = false
            }
        }
>>>>>>> illness-filters-temp
    }
}
