//
//  CameraService+Extensions.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import AVFoundation
import UIKit

extension CameraService {
    func updateVideoOrientation(deviceOrientation: UIDeviceOrientation) {
        guard let connection = self.session.connections.first else { return }
        // iOS 17+: Use videoRotationAngle (in degrees)
        if #available(iOS 17.0, *) {
            switch deviceOrientation {
            case .landscapeLeft:
                connection.videoRotationAngle = 270.0
            case .landscapeRight:
                connection.videoRotationAngle = 90.0
            case .portrait:
                connection.videoRotationAngle = 0.0
            case .portraitUpsideDown:
                connection.videoRotationAngle = 180.0
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
            connection.videoOrientation = .portrait // Keep portrait for compatibility
            if let previewLayer = connection.videoPreviewLayer {
                previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: angle))
            }
        }
    }
}
