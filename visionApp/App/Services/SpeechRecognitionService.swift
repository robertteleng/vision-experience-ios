//
//  SpeechRecognitionService.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import Foundation
import Speech
import AVFoundation // ✅ AÑADIDO: Necesario para AVAudioSession y AVAudioEngine
import Combine

class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var lastCommand: String = ""
    @Published var isListening: Bool = false
    @Published var error: String?

    // Callback opcional al procesar un comando válido
    var onCommand: ((String) -> Void)?

    // Permite escucha continua (reinicia cuando termina un resultado final)
    var continuousListening: Bool = true

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // Timer para evitar procesar comandos muy seguidos
    private var commandTimer: Timer?
    private var lastProcessedCommand: String = ""

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

    // Solicita permisos de voz y micrófono
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
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            micOK = granted
            group.leave()
        }

        group.notify(queue: .main) {
            if !speechOK { self.error = "Speech recognition not authorized" }
            if !micOK { self.error = "Microphone not authorized" }
            completion(speechOK && micOK)
        }
    }

    // Alterna entre iniciar y detener
    func toggleRecognition() {
        isListening ? stopRecognition() : startRecognition()
    }

    func startRecognition() {
        guard !isListening else { return }

        // Verificar disponibilidad del reconocedor
        guard speechRecognizer?.isAvailable == true else {
            error = "Speech recognition not available"
            return
        }

        // Asegurar permisos antes de empezar
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

        commandTimer?.invalidate()
        commandTimer = nil

        isListening = false
        print("🛑 Speech recognition stopped")
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        // .playAndRecord ayuda si combinamos con reproducción; duckOthers reduce el volumen de otros audios
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startRecording() throws {
        // Limpiar sesión anterior
        recognitionTask?.cancel()
        recognitionTask = nil

        // Configurar sesión de audio
        try configureAudioSession()

        // Preparar request y engine
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechRecognition", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode

        // Evitar taps duplicados
        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
        }

        // Formato de audio válido
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0 else {
            throw NSError(domain: "SpeechRecognition", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid audio format"])
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        // Crear task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Recognition error: \(error.localizedDescription)")
                    self.error = "Recognition error: \(error.localizedDescription)"
                    // Algunos errores son recuperables; si estamos en escucha continua, intentar reiniciar
                    self.handleTaskCompletionOrError(restart: self.continuousListening)
                    return
                }

                if let result = result {
                    let command = result.bestTranscription.formattedString.lowercased()
                    self.lastCommand = command

                    if result.isFinal || self.shouldProcessCommand(command) {
                        print("🗣️ Processing command: \(command)")
                        self.onCommand?(command)
                        // Si no queremos escucha continua y el resultado es final, detener
                        if result.isFinal && !self.continuousListening {
                            self.stopRecognition()
                        }
                    }

                    // Si terminó (final) y queremos continua, reiniciamos el task
                    if result.isFinal && self.continuousListening {
                        self.restartTaskKeepingEngineRunning()
                    }
                }
            }
        }
    }

    private func restartTaskKeepingEngineRunning() {
        // Mantener engine y tap, solo recrear request y task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Recognition error (restart): \(error.localizedDescription)")
                    self.error = "Recognition error: \(error.localizedDescription)"
                    self.handleTaskCompletionOrError(restart: self.continuousListening)
                    return
                }
                if let result = result {
                    let command = result.bestTranscription.formattedString.lowercased()
                    self.lastCommand = command
                    if result.isFinal || self.shouldProcessCommand(command) {
                        print("🗣️ Processing command: \(command)")
                        self.onCommand?(command)
                        if result.isFinal && !self.continuousListening {
                            self.stopRecognition()
                        }
                    }
                    if result.isFinal && self.continuousListening {
                        self.restartTaskKeepingEngineRunning()
                    }
                }
            }
        }
    }

    private func handleTaskCompletionOrError(restart: Bool) {
        if restart {
            // Intentar reiniciar manteniendo el engine activo
            restartTaskKeepingEngineRunning()
        } else {
            stopRecognition()
        }
    }

    // Evita procesar comandos duplicados muy seguidos
    private func shouldProcessCommand(_ command: String) -> Bool {
        defer {
            lastProcessedCommand = command
            commandTimer?.invalidate()
            commandTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in }
        }
        return command != lastProcessedCommand || commandTimer == nil
    }

    deinit {
        stopRecognition()
        commandTimer?.invalidate()
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
