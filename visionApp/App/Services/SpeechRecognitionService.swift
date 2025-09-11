//
//  SpeechRecognitionService.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import Foundation
import Speech
import AVFoundation
import Combine

class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var lastCommand: String = ""
    @Published var isListening: Bool = false
    @Published var error: String?

    var onCommand: ((String) -> Void)?
    var continuousListening: Bool = true

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // ✅ ESTRATEGIA MEJORADA: Reset solo cuando sea necesario
    private var commandProcessedTimer: Timer?
    private var lastProcessedText: String = ""
    private let maxAcceptableLength: Int = 100 // Más generoso
    private let resetDelayAfterCommand: TimeInterval = 3.0 // Reset solo después de procesar comando

    override init() {
        super.init()
        setupSpeechRecognizer()
    }

    private func setupSpeechRecognizer() {
        guard let speechRecognizer = speechRecognizer else {
            error = "Speech recognition not available for this locale"
            return
        }
        speechRecognizer.delegate = self
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var speechOK = false
        var micOK = false

        group.enter()
        SFSpeechRecognizer.requestAuthorization { status in
            speechOK = (status == .authorized)
            group.leave()
        }

        group.enter()
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                micOK = granted
                group.leave()
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                micOK = granted
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if !speechOK { self.error = "Speech recognition not authorized" }
            if !micOK { self.error = "Microphone not authorized" }
            completion(speechOK && micOK)
        }
    }

    func toggleRecognition() {
        isListening ? stopRecognition() : startRecognition()
    }

    func startRecognition() {
        guard !isListening else { return }

        guard speechRecognizer?.isAvailable == true else {
            error = "Speech recognition not available"
            return
        }

        requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            guard granted else { return }
            do {
                try self.startRecording()
                self.isListening = true
                self.error = nil
                print("🎤 Speech recognition started")
            } catch {
                self.error = "Failed to start recording: \(error.localizedDescription)"
                print("❌ Failed to start speech recognition: \(error)")
            }
        }
    }

    func stopRecognition() {
        guard isListening || recognitionTask != nil || audioEngine.isRunning else { return }

        recognitionTask?.cancel()
        recognitionTask = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }
        let inputNode = audioEngine.inputNode
        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        commandProcessedTimer?.invalidate()
        commandProcessedTimer = nil

        isListening = false
        lastCommand = ""
        lastProcessedText = ""
        print("🛑 Speech recognition stopped")
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker, .allowBluetoothHFP, .allowBluetoothA2DP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        try configureAudioSession()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechRecognition", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode

        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0 else {
            throw NSError(domain: "SpeechRecognition", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid audio format"])
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        createRecognitionTask()
    }

    private func createRecognitionTask() {
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    // ✅ MEJORADO: Solo log errores importantes, no spam
                    let errorDescription = error.localizedDescription
                    if !errorDescription.contains("No speech detected") {
                        print("❌ Recognition error: \(errorDescription)")
                        self.error = "Recognition error: \(errorDescription)"
                    }
                    
                    // ✅ MEJORADO: Restart más inteligente
                    if self.continuousListening && !errorDescription.contains("No speech detected") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if self.isListening {
                                self.restartTaskKeepingEngineRunning()
                            }
                        }
                    }
                    return
                }

                if let result = result {
                    let command = result.bestTranscription.formattedString.lowercased()
                    self.lastCommand = command
                    
                    // ✅ ESTRATEGIA NUEVA: Solo reset si el texto es extremadamente largo
                    if command.count > self.maxAcceptableLength {
                        print("⚠️ Text too long (\(command.count) chars), resetting")
                        self.scheduleSmartReset()
                        return
                    }
                    
                    // ✅ NUEVO: Procesar comando inmediatamente si es final o contiene comando válido
                    let shouldProcess = result.isFinal || self.containsValidCommand(command)
                    
                    if shouldProcess {
                        // Evitar procesar el mismo texto dos veces
                        if command != self.lastProcessedText {
                            print("🗣️ Processing command: \(command)")
                            self.onCommand?(command)
                            self.lastProcessedText = command
                            
                            // ✅ NUEVO: Reset inteligente solo después de procesar comando exitoso
                            self.scheduleSmartReset()
                        }
                    }

                    // Restart en resultado final solo si es necesario
                    if result.isFinal && self.continuousListening {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.isListening {
                                self.restartTaskKeepingEngineRunning()
                            }
                        }
                    }
                }
            }
        }
    }

    // ✅ NUEVO: Reset inteligente que no interfiere con el recognition normal
    private func scheduleSmartReset() {
        commandProcessedTimer?.invalidate()
        commandProcessedTimer = Timer.scheduledTimer(withTimeInterval: resetDelayAfterCommand, repeats: false) { [weak self] _ in
            guard let self = self, self.isListening else { return }
            print("🔄 Smart reset after command processing")
            self.restartTaskKeepingEngineRunning()
            self.lastProcessedText = ""
        }
    }

    private func containsValidCommand(_ text: String) -> Bool {
        let validCommands = [
            "cataratas", "cataracts", "glaucoma", "macular", "túnel", "tunel", "tunnel",
            "más", "menos", "activar", "desactivar", "volver", "back", "cardboard",
            "realidad", "ayuda"
        ]
        
        return validCommands.contains { text.contains($0) }
    }

    private func restartTaskKeepingEngineRunning() {
        guard isListening else { return }
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        createRecognitionTask()
    }

    deinit {
        stopRecognition()
        commandProcessedTimer?.invalidate()
    }
}

extension SpeechRecognitionService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            if !available && self.isListening {
                print("⚠️ Speech recognition became unavailable")
                self.error = "Speech recognition became unavailable"
                self.stopRecognition()
            }
        }
    }
}
