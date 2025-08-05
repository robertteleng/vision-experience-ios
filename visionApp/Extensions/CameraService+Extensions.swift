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
        guard let connection = self.session.connections.first,
              connection.isVideoOrientationSupported else { return }

        switch deviceOrientation {
        case .landscapeLeft:
            connection.videoOrientation = .landscapeRight
        case .landscapeRight:
            connection.videoOrientation = .landscapeLeft
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        default:
            break
        }
    }
}
