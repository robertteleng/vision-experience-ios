//  ImmersiveVideoView.swift
//  VisionExperience
//  This view will play 360º video with spatial audio (scaffold).

import SwiftUI
import SceneKit
import AVFoundation
import UIKit
import CoreImage
import CoreVideo
import Combine

struct ImmersiveVideoView: View {
    @State private var isPlaying = false
    @State private var selectedFilter: IllnessFilterType = .glaucoma
    @State private var centralFocus: Double = 0.5 // 0.0 – 1.0
    // Spatial audio + head tracking
    @StateObject private var spatialAudio = SpatialAudioService()
    @StateObject private var head = HeadOrientationProvider()
    @StateObject private var headphoneHead = HeadphoneHeadOrientationProvider()
    // Use a remote video URL instead of a local asset
    private let videoURL = URL(string: "https://www.apple.com/105/media/us/apple-events/2021/2021-09-14/2021-09-14_event_360p.mp4")
    @State private var player: AVPlayer? = nil
    @State private var videoLoadFailed = false
    // Restart coordination tick
    @State private var restartTick: Int = 0
    // Seek support
    @State private var durationSeconds: Double = 0
    @State private var seekSeconds: Double = 0
    @State private var seekTick: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
            Text("360º Video with Spatial Audio")
                .font(.title)
                .foregroundColor(.gray)
            Spacer()
            Picker("Filter", selection: $selectedFilter) {
                ForEach(IllnessFilterType.allCases) { filter in
                    Text(filter.displayName).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            // Central focus slider
            HStack {
                Text("Focus")
                    .foregroundColor(.white)
                Slider(value: $centralFocus, in: 0...1)
                Text(String(format: "%.2f", centralFocus))
                    .foregroundColor(.white)
                    .frame(width: 44, alignment: .trailing)
            }
            .padding(.horizontal)
            // Seek slider
            HStack {
                Text("Seek")
                    .foregroundColor(.white)
                Slider(value: $seekSeconds, in: 0...(durationSeconds > 0 ? durationSeconds : 1), onEditingChanged: { editing in
                    if !editing {
                        seekTick &+= 1
                        let t = CMTime(seconds: seekSeconds, preferredTimescale: 600)
                        spatialAudio.seek(to: t)
                    }
                })
                Text(formatTime(seekSeconds))
                    .foregroundColor(.white)
                    .frame(width: 70, alignment: .trailing)
            }
            .padding(.horizontal)
            Spacer()
            if let url = videoURL, !videoLoadFailed {
                SceneKitVideoSphereView(
                    videoURL: url,
                    isPlaying: $isPlaying,
                    videoLoadFailed: $videoLoadFailed,
                    filterType: selectedFilter,
                    centralFocus: centralFocus,
                    restartTick: restartTick,
                    seekTick: seekTick,
                    seekSeconds: seekSeconds
                )
                .frame(height: 300)
            } else if videoLoadFailed {
                Text("Failed to load 360º video.")
                    .foregroundColor(.red)
            } else {
                Text("Invalid video URL.")
                    .foregroundColor(.red)
            }
            Spacer()
            HStack(spacing: 24) {
                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
                Button("Restart") {
                    restartTick &+= 1
                    spatialAudio.seek(to: .zero)
                }
                .foregroundColor(.white)
                Button("Recenter") {
                    headphoneHead.recenter()
                }
                .foregroundColor(.white)
            }
            Spacer()
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            spatialAudio.startEngineIfNeeded()
            if let url = videoURL {
                spatialAudio.startFromAsset(url: url)
                // Load duration for seek slider
                let asset = AVURLAsset(url: url)
                Task {
                    do {
                        let dur = try await asset.load(.duration)
                        durationSeconds = CMTimeGetSeconds(dur)
                    } catch {
                        durationSeconds = 0
                    }
                }
            }
            spatialAudio.setPlaying(isPlaying)
            head.start()
            headphoneHead.start()
        }
        .onDisappear {
            head.stop()
            headphoneHead.stop()
            spatialAudio.stop()
        }
        // Prefer AirPods head tracking when active
        .onReceive(Publishers.CombineLatest3(headphoneHead.$yaw, headphoneHead.$pitch, headphoneHead.$roll)) { yaw, pitch, roll in
            if headphoneHead.isActive {
                spatialAudio.updateListener(yaw: yaw, pitch: pitch, roll: roll)
            }
        }
        // Fallback to phone motion when headphones not active
        .onReceive(Publishers.CombineLatest3(head.$yaw, head.$pitch, head.$roll)) { yaw, pitch, roll in
            if !headphoneHead.isActive {
                spatialAudio.updateListener(yaw: yaw, pitch: pitch, roll: roll)
            }
        }
        .onChange(of: isPlaying) { _, newValue in
            spatialAudio.setPlaying(newValue)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "0:00" }
        let s = Int(seconds.rounded())
        let m = s / 60
        let r = s % 60
        return String(format: "%d:%02d", m, r)
    }
}

struct SceneKitVideoSphereView: UIViewRepresentable {
    let videoURL: URL
    @Binding var isPlaying: Bool
    @Binding var videoLoadFailed: Bool
    var filterType: IllnessFilterType
    var centralFocus: Double
    var restartTick: Int
    var seekTick: Int
    var seekSeconds: Double
    
    func makeCoordinator() -> Coordinator {
        Coordinator(videoLoadFailed: $videoLoadFailed, filterType: filterType, videoURL: videoURL, centralFocus: centralFocus, restartTick: restartTick, seekTick: seekTick)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        let scene = SCNScene()
        let sphere = SCNSphere(radius: 10)
        sphere.firstMaterial?.isDoubleSided = true
        let node = SCNNode(geometry: sphere)
        scene.rootNode.addChildNode(node)
        sceneView.scene = scene
        sceneView.pointOfView = SCNNode()
        sceneView.backgroundColor = UIColor.black
        context.coordinator.sphereNode = node
        context.coordinator.start()
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.filterType = filterType
        context.coordinator.centralFocus = centralFocus
        if context.coordinator.restartTick != restartTick {
            context.coordinator.restartTick = restartTick
            context.coordinator.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        if context.coordinator.seekTick != seekTick {
            context.coordinator.seekTick = seekTick
            let t = CMTime(seconds: seekSeconds, preferredTimescale: 600)
            context.coordinator.player?.seek(to: t, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        if isPlaying {
            context.coordinator.player?.play()
        } else {
            context.coordinator.player?.pause()
        }
    }
    
    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        coordinator.stop()
    }
    
    class Coordinator: NSObject {
        var videoLoadFailed: Binding<Bool>
        var filterType: IllnessFilterType
        let videoURL: URL
        var centralFocus: Double
        var restartTick: Int
        var seekTick: Int
        var player: AVPlayer?
        var videoOutput: AVPlayerItemVideoOutput?
        weak var sphereNode: SCNNode?
        var displayLink: CADisplayLink?
        private var statusObservedItem: AVPlayerItem?
        
        init(videoLoadFailed: Binding<Bool>, filterType: IllnessFilterType, videoURL: URL, centralFocus: Double, restartTick: Int, seekTick: Int) {
            self.videoLoadFailed = videoLoadFailed
            self.filterType = filterType
            self.videoURL = videoURL
            self.centralFocus = centralFocus
            self.restartTick = restartTick
            self.seekTick = seekTick
        }
        
        func start() {
            let player = AVPlayer(url: videoURL)
            player.isMuted = true // avoid double audio; spatial audio handled externally
            self.player = player
            let pixelBufferAttrs: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            let output = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttrs)
            self.videoOutput = output
            if let item = player.currentItem {
                item.add(output)
                item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                statusObservedItem = item
            }
            let link = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
            link.add(to: .main, forMode: .default)
            self.displayLink = link
        }
        
        func stop() {
            displayLink?.invalidate()
            displayLink = nil
            if let item = statusObservedItem {
                item.removeObserver(self, forKeyPath: "status")
                statusObservedItem = nil
            }
            player?.pause()
            player = nil
            videoOutput = nil
            sphereNode = nil
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "status" {
                if let item = object as? AVPlayerItem, item.status == .failed {
                    videoLoadFailed.wrappedValue = true
                }
            }
        }
        
        @objc func displayLinkDidFire() {
            guard let player = player, let output = videoOutput, let node = sphereNode else { return }
            let currentTime = player.currentTime()
            // Only process if there's a new frame
            if !output.hasNewPixelBuffer(forItemTime: currentTime) { return }
            var displayTime = CMTime.zero
            autoreleasepool {
                if let pixelBuffer = output.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: &displayTime) {
                    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                    let context = CIContext()
                    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
                    let illness = Illness(name: filterType.displayName, description: "", filterType: filterType)
                    let width = CVPixelBufferGetWidth(pixelBuffer)
                    let height = CVPixelBufferGetHeight(pixelBuffer)
                    let filteredCGImage = CIProcessor.shared.apply(
                        illness: illness,
                        settings: nil,
                        filterEnabled: true,
                        centralFocus: centralFocus,
                        to: cgImage,
                        panelSize: CGSize(width: width, height: height)
                    )
                    node.geometry?.firstMaterial?.diffuse.contents = filteredCGImage
                }
            }
        }
        
        deinit {
            stop()
        }
    }
}
