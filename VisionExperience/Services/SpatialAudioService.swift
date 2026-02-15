import Foundation
import AVFoundation

final class SpatialAudioService: ObservableObject {
    private let engine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private let player = AVAudioPlayerNode()

    private var isEngineRunning = false
    private var decodeQueue = DispatchQueue(label: "SpatialAudioService.decode")
    private var assetURL: URL?
    private var reader: AVAssetReader?
    private var readerOutput: AVAssetReaderTrackOutput?
    private var decoding = false
    private var shouldPlay = false
    private var gain: Float = 1.0
    private var isMuted: Bool = false

    // MARK: Engine Lifecycle
    func startEngineIfNeeded() {
        guard !isEngineRunning else { return }
        configureSession()
        engine.attach(environment)
        engine.attach(player)
        engine.connect(player, to: environment, format: nil)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        applyOutputVolume()
        // Remove hard override to 1.0; applyOutputVolume controls volume
        let mix = player as AVAudio3DMixing
        mix.sourceMode = .spatializeIfMono
        mix.renderingAlgorithm = .HRTFHQ
        mix.position = AVAudio3DPoint(x: 0, y: 0, z: -1)
        do { try engine.start(); isEngineRunning = true } catch { print("SpatialAudioService: engine start failed: \(error)") }
    }

    func stop() {
        decoding = false
        shouldPlay = false
        player.stop()
        reader?.cancelReading()
        reader = nil
        readerOutput = nil
        engine.stop()
        isEngineRunning = false
    }

    // MARK: Control
    func setPlaying(_ play: Bool) {
        shouldPlay = play
        if play {
            if !player.isPlaying { player.play() }
        } else {
            player.pause()
        }
    }
    
    func setGain(_ value: Float) {
        gain = max(0.0, min(1.0, value))
        applyOutputVolume()
    }
    
    func setMuted(_ muted: Bool) {
        isMuted = muted
        applyOutputVolume()
    }
    
    private func applyOutputVolume() {
        environment.outputVolume = isMuted ? 0.0 : gain
    }

    func updateListener(yaw: Float, pitch: Float, roll: Float) {
        environment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(yaw, pitch, roll)
    }

    func setSourcePosition(_ p: AVAudio3DPoint) {
        (player as AVAudio3DMixing).position = p
    }

    // MARK: Start from video asset
    func startFromAsset(url: URL) {
        startEngineIfNeeded()
        assetURL = url
        Task {
            await buildReaderAndStart(startTime: .zero)
        }
    }
    
    func seek(to time: CMTime) {
        guard assetURL != nil else { return }
        decoding = false
        reader?.cancelReading()
        reader = nil
        readerOutput = nil
        Task {
            await buildReaderAndStart(startTime: time)
        }
    }
    
    private func buildReaderAndStart(startTime: CMTime) async {
        guard let url = assetURL else { return }
        let asset = AVURLAsset(url: url)
        
        do {
            // Removed unnecessary explicit loads of tracks and duration:
            // try await asset.load(.tracks)
            // try await asset.load(.duration)
            
            // Load audio tracks asynchronously
            let audioTracks = try await asset.loadTracks(withMediaType: .audio)
            guard let track = audioTracks.first else {
                print("SpatialAudioService: no audio track")
                return
            }
            
            let reader = try AVAssetReader(asset: asset)
            let outputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMIsFloatKey: true,
                AVLinearPCMBitDepthKey: 32,
                AVLinearPCMIsNonInterleaved: false,
                AVLinearPCMIsBigEndianKey: false
            ]
            let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
            output.alwaysCopiesSampleData = true
            guard reader.canAdd(output) else {
                print("SpatialAudioService: cannot add output")
                return
            }
            reader.add(output)
            
            // Clamp time range to asset duration
            let duration = try await asset.load(.duration)
            let start = CMTimeMaximum(startTime, .zero)
            let remaining = CMTimeSubtract(duration, start)
            if remaining > .zero && remaining.isNumeric {
                reader.timeRange = CMTimeRange(start: start, duration: remaining)
            }
            
            self.reader = reader
            self.readerOutput = output
            
            self.startDecodingLoop()
        } catch {
            print("SpatialAudioService: AVAssetReader error: \(error)")
        }
    }
    
    private func startDecodingLoop() {
        guard let reader = reader, let output = readerOutput else { return }
        if !reader.startReading() { print("SpatialAudioService: reader failed to start"); return }
        decoding = true
        if shouldPlay && !player.isPlaying { player.play() }
        decodeQueue.async { [weak self] in
            guard let self = self else { return }
            var pending = 0
            let maxPending = 8
            while self.decoding && reader.status == .reading {
                if !self.shouldPlay { usleep(20_000); continue }
                if pending >= maxPending { usleep(10_000); continue }
                guard let sample = output.copyNextSampleBuffer() else { usleep(5_000); continue }
                if let pcm = self.makeMonoBuffer(from: sample) {
                    self.player.scheduleBuffer(pcm, at: nil, options: [], completionHandler: { pending = max(0, pending - 1) })
                    pending += 1
                }
                CMSampleBufferInvalidate(sample)
            }
            if reader.status == .completed {
                // Simple loop: restart at zero
                self.seek(to: .zero)
            }
        }
    }

    // Mix interleaved float32 buffer to mono AVAudioPCMBuffer
    private func makeMonoBuffer(from sample: CMSampleBuffer) -> AVAudioPCMBuffer? {
        guard let fmt = CMSampleBufferGetFormatDescription(sample),
              let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt)?.pointee,
              let block = CMSampleBufferGetDataBuffer(sample) else { return nil }
        let channels = Int(asbd.mChannelsPerFrame)
        let sampleRate = asbd.mSampleRate
        let frames = CMSampleBufferGetNumSamples(sample)
        var lenAtOffset = 0, totalLen = 0
        var basePtr: UnsafeMutablePointer<Int8>? = nil
        let status = CMBlockBufferGetDataPointer(block, atOffset: 0, lengthAtOffsetOut: &lenAtOffset, totalLengthOut: &totalLen, dataPointerOut: &basePtr)
        if status != kCMBlockBufferNoErr { return nil }
        guard let p = basePtr else { return nil }
        let floatPtr = p.withMemoryRebound(to: Float.self, capacity: totalLen / MemoryLayout<Float>.size) { $0 }
        let monoFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let mono = AVAudioPCMBuffer(pcmFormat: monoFormat, frameCapacity: AVAudioFrameCount(frames)) else { return nil }
        mono.frameLength = AVAudioFrameCount(frames)
        let dst = mono.floatChannelData![0]
        if channels == 1 {
            dst.update(from: floatPtr, count: Int(mono.frameLength))
        } else {
            // average channels
            for i in 0..<Int(mono.frameLength) {
                var sum: Float = 0
                var idx = i * channels
                for _ in 0..<channels { sum += floatPtr[idx]; idx += 1 }
                dst[i] = sum / Float(channels)
            }
        }
        return mono
    }

    // MARK: Session
    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try session.setActive(true, options: [])
        } catch {
            print("SpatialAudioService: session config failed: \(error)")
        }
    }

    // Optional test tone
    func playTestTone() {
        startEngineIfNeeded()
        let sr = 44100.0
        let dur = 1.0
        let frames = AVAudioFrameCount(sr * dur)
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 1)!
        guard let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: frames) else { return }
        buf.frameLength = frames
        let ch0 = buf.floatChannelData![0]
        for i in 0..<Int(frames) {
            let t = Double(i) / sr
            ch0[i] = Float(sin(2.0 * .pi * 440.0 * t) * 0.2)
        }
        player.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
        player.play()
    }
}
