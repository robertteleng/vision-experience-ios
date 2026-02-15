//
//  CameraService.swift
//  VisionExperience
//
//  Created by automated-fix on 2025/12/17
//

import Foundation
import AVFoundation
import Combine
import UIKit
import CoreImage

class CameraService: NSObject, ObservableObject {
    // Publicly accessible capture session so extensions can update orientation
    let session = AVCaptureSession()

    // Publishes latest frame as CGImage
    @Published var currentFrame: CGImage?
    // Publishes camera errors
    @Published var error: CameraError?

    // Debug logging toggle (referenced in README)
    private let enableDebugLogs = false

    // Internal capture queue
    private let captureQueue = DispatchQueue(label: "VisionExperience.camera.captureQueue")

    // Video output
    private let videoOutput = AVCaptureVideoDataOutput()

    // Shared CIContext: creating this once is much cheaper than per-frame creation
    private let ciContext: CIContext = CIContext(options: nil)

    // Keep a reference to the connection's pixel buffer format description if needed
    private var videoConnection: AVCaptureConnection? {
        // Use the appropriate API depending on iOS version to avoid deprecation warnings
        if #available(iOS 17.0, *) {
            // isVideoRotationAngleSupported(_:) is a method that accepts an angle value (CGFloat)
            return session.connections.first { $0.isVideoRotationAngleSupported(0) }
        } else {
            return session.connections.first { $0.isVideoOrientationSupported }
        }
    }

    override init() {
        super.init()
        // Set sensible defaults
        session.sessionPreset = .high

        // VideoDataOutput config
        let settings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
    }

    deinit {
        stopSession()
    }

    /// Starts the camera session after checking/requesting permission.
    func startSession() {
        if enableDebugLogs { print("📸 [CameraService] startSession() called") }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStartSessionIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureAndStartSessionIfNeeded()
                    } else {
                        self?.error = .authorizationDenied
                    }
                }
            }
        case .denied, .restricted:
            error = .authorizationDenied
        @unknown default:
            error = .unknown
        }
    }

    /// Stops the camera session and releases resources.
    func stopSession() {
        if enableDebugLogs { print("📸 [CameraService] stopSession() called") }
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            // Remove outputs safely
            if self.session.inputs.count > 0 {
                for input in self.session.inputs {
                    self.session.removeInput(input)
                }
            }
            if self.session.outputs.count > 0 {
                for output in self.session.outputs {
                    self.session.removeOutput(output)
                }
            }
        }
    }

    // MARK: - Private helpers

    private func configureAndStartSessionIfNeeded() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning { return }

            do {
                self.session.beginConfiguration()

                // Select default video device (wide angle back camera preferred)
                if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) {
                    let deviceInput = try AVCaptureDeviceInput(device: device)

                    // Remove existing inputs
                    for input in self.session.inputs {
                        self.session.removeInput(input)
                    }

                    if self.session.canAddInput(deviceInput) {
                        self.session.addInput(deviceInput)
                    } else {
                        DispatchQueue.main.async { self.error = .configurationFailed }
                        self.session.commitConfiguration()
                        return
                    }
                } else {
                    DispatchQueue.main.async { self.error = .deviceUnavailable }
                    self.session.commitConfiguration()
                    return
                }

                // Add video output
                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                } else {
                    DispatchQueue.main.async { self.error = .configurationFailed }
                    self.session.commitConfiguration()
                    return
                }

                // Prefer high framerate if available (leave session preset as is)
                self.session.commitConfiguration()

                // Start running
                self.session.startRunning()

                if self.enableDebugLogs { print("📸 [CameraService] Session started") }
            } catch {
                if self.enableDebugLogs { print("📸 [CameraService] Configuration error: \(error)") }
                DispatchQueue.main.async { self.error = .configurationFailed }
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            // Convert CVPixelBuffer to CGImage using shared CIContext
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }

            // Publish on main queue
            DispatchQueue.main.async { [weak self] in
                self?.currentFrame = cgImage
            }
        }
    }
}
