//
//  CameraService.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  Service to manage camera capture session, provide preview, and handle errors.
//  Designed for SwiftUI integration using UIViewRepresentable.
//

import Foundation
import AVFoundation
import UIKit


// Camera permission status
enum CameraError: Error, LocalizedError {
    case authorizationDenied
    case configurationFailed
    case deviceUnavailable
    case unknown

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Camera access was denied. Please enable it in settings."
        case .configurationFailed:
            return "Failed to configure the camera."
        case .deviceUnavailable:
            return "No camera device is available."
        case .unknown:
            return "Unknown camera error."
        }
    }
}


class CameraService: NSObject, ObservableObject {
    // The camera session managed by this service
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    // The video preview layer (can be used directly in UIKit)
    var previewLayer: AVCaptureVideoPreviewLayer?

    // Publish errors to the UI
    @Published var error: CameraError?
    @Published var currentFrame: UIImage?

    private var videoOutput: AVCaptureVideoDataOutput?

    private var isConfiguringSession = false

    // MARK: - Public Methods

    /// Request permission and start camera session if authorized
    func startSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.configureSession()
                } else {
                    DispatchQueue.main.async {
                        self?.error = .authorizationDenied
                    }
                }
            }
        default:
            error = .authorizationDenied
        }
    }

    /// Stop camera session
    func stopSession() {
        sessionQueue.async {
            if !self.isConfiguringSession {
                self.session.stopRunning()
            }
        }
    }

    // MARK: - Session Configuration

    private func configureSession() {
        sessionQueue.async {
            self.isConfiguringSession = true
            do {
                self.session.beginConfiguration()
                self.session.sessionPreset = .high

                // Remove all existing inputs
                for input in self.session.inputs {
                    self.session.removeInput(input)
                }

                // Add camera input
                guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    DispatchQueue.main.async {
                        self.error = .deviceUnavailable
                    }
                    self.isConfiguringSession = false
                    return
                }
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                guard self.session.canAddInput(videoInput) else {
                    DispatchQueue.main.async {
                        self.error = .configurationFailed
                    }
                    self.isConfiguringSession = false
                    return
                }
                self.session.addInput(videoInput)

                self.session.commitConfiguration()
                self.isConfiguringSession = false
                self.session.startRunning()
                self.setupVideoOutput()
            } catch {
                DispatchQueue.main.async {
                    self.error = .configurationFailed
                }
                self.isConfiguringSession = false
            }
        }
    }

    private func setupVideoOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue"))
        if self.session.canAddOutput(videoOutput) {
            self.session.addOutput(videoOutput)
            self.videoOutput = videoOutput
        }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let image = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.currentFrame = image
            }
        }
    }
}
