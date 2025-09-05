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

        if #available(iOS 17.0, *) {
            // iOS 17+: usar únicamente videoRotationAngle (grados)
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
            // iOS < 17: usar únicamente videoOrientation (sin transforms manuales)
            guard connection.isVideoOrientationSupported else { return }
            switch deviceOrientation {
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
            case .portrait:
                connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            default:
                // Mantener la orientación actual si es desconocida/faceUp/faceDown
                break
            }
        }
    }
}
