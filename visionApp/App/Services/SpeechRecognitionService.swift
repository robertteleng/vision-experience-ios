//
//  SpeechRecognitionService.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  Service to manage continuous speech recognition with multilingual support (en/es),
//  safe start/stop, and SwiftUI-friendly state updates.
//

import Foundation
import Speech
import Combine
import AVFoundation

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
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

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
                }
            }
        }
    }

    private func publishError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = message
        }
    }
}
