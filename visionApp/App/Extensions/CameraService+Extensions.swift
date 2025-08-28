//
//  CameraService+Extensions.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file extends the CameraService class to provide additional functionality
//  for updating the video orientation based on the device's orientation. It handles
//  both iOS 17+ and earlier versions, ensuring compatibility and correct video display.
//
//  The updateVideoOrientation(deviceOrientation:) method adjusts the video orientation
//  for AVCaptureSession connections, using either the videoRotationAngle (iOS 17+) or
//  affine transforms (older iOS versions).

import AVFoundation
import UIKit

extension CameraService {
    /// Updates the video orientation of the camera session based on the device's orientation.
    /// - Parameter deviceOrientation: The current orientation of the device (portrait, landscape, etc).
    /// - For iOS 17 and above, sets the videoRotationAngle property directly.
    /// - For earlier iOS versions, applies an affine transform to the preview layer.
    func updateVideoOrientation(deviceOrientation: UIDeviceOrientation) {
        guard let connection = self.session.connections.first else { return }
        // iOS 17+: Use videoRotationAngle (in degrees)
        if #available(iOS 17.0, *) {
            switch deviceOrientation {
            case .landscapeLeft:
                connection.videoRotationAngle = 270.0 // Home button on the right
            case .landscapeRight:
                connection.videoRotationAngle = 90.0  // Home button on the left
            case .portrait:
                connection.videoRotationAngle = 0.0   // Standard portrait
            case .portraitUpsideDown:
                connection.videoRotationAngle = 180.0 // Upside down portrait
            default:
                break
            }
        } else {
            // Fallback for iOS < 17: Use transform
            var angle: CGFloat = 0.0
            switch deviceOrientation {
            case .landscapeLeft:
                angle = CGFloat.pi * 1.5
            case .landscapeRight:
                angle = CGFloat.pi / 2
            case .portrait:
                angle = 0.0
            case .portraitUpsideDown:
                angle = CGFloat.pi
            default:
                break
            }
            // Always set videoOrientation to portrait for compatibility
            connection.videoOrientation = .portrait
            if let previewLayer = connection.videoPreviewLayer {
                // Apply affine transform to rotate the preview layer
                previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: angle))
            }
        }
    }
}
