//
//  SpeechRecognitionService.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import Foundation
import Speech
import Combine
import AVFoundation

final class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var lastCommand: String = ""
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isAuthorized: Bool = false

    // Idiomas soportados: primario español y secundario inglés
    private(set) var primaryLocaleID: String = "es-ES"
    private(set) var secondaryLocaleID: String = "en-US"

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

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
                }
            }
        }
    }

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
    }
}
