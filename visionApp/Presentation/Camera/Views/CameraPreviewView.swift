//
//  CameraPreviewView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import AVFoundation
import UIKit

/// SwiftUI view that wraps a custom UIView to display the camera preview.
/// Uses `UIViewRepresentable` to integrate UIKit components into SwiftUI.
struct CameraPreviewView: UIViewRepresentable {
    /// The camera capture session to be displayed.
    let session: AVCaptureSession

    /// Creates the custom preview UIView and injects the session.
    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.session = session
        return view
    }

    /// No dynamic updates needed since the session is immutable.
    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        // No update needed
    }
}

/// Custom UIView that manages the camera preview using AVCaptureVideoPreviewLayer.
/// Also adapts orientation, mirroring (for the front camera), and observes orientation changes.
class PreviewUIView: UIView {
    /// Camera session to display. On set, updates the preview layer.
    var session: AVCaptureSession? {
        didSet {
            setupPreviewLayer()
        }
    }
    /// AVFoundation video layer used to show the live image.
    private var previewLayer: AVCaptureVideoPreviewLayer?

    /// Adjusts the size, position, rotation, and mirroring of the preview whenever the layout changes.
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = bounds
        previewLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        // Adjust mirroring if the camera is front-facing (usually mirrored)
        if let input = session?.inputs.first as? AVCaptureDeviceInput,
           let connection = previewLayer.connection {
            // Disable automatic adjustment before setting manually
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = (input.device.position == .front)
        }

        let io = currentInterfaceOrientation()
        if #available(iOS 17.0, *) {
            // On iOS 17+, use AVFoundation's native rotation angle
            if let connection = previewLayer.connection {
                connection.videoRotationAngle = angleDegrees(for: io)
            }
        } else {
            // On earlier versions, apply rotation using affine transforms
            let radians = angleRadians(for: io)
            previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: radians))
        }
    }

    /// Creates and adds the AVCaptureVideoPreviewLayer to the view, linking it to the camera session.
    private func setupPreviewLayer() {
        // Remove previous layer if present
        previewLayer?.removeFromSuperlayer()
        guard let session = session else { return }
        // Create the new layer with the active session
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.addSublayer(layer)
        self.previewLayer = layer
    }
    
    /// Gets the most recent and stable interface orientation using UIWindowScene.
    private func currentInterfaceOrientation() -> UIInterfaceOrientation {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.interfaceOrientation
        }
        return .unknown
    }

    /// Calculates the rotation angle in degrees for iOS 17+ according to the current orientation.
    @available(iOS 17.0, *)
    private func angleDegrees(for orientation: UIInterfaceOrientation) -> CGFloat {
        switch orientation {
        case .landscapeLeft:
            return 90
        case .landscapeRight:
            return 270.0
        case .portraitUpsideDown:
            return 180.0
        case .portrait:
            return 0.0
        default:
            return 0.0
        }
    }

    /// Calculates the rotation angle in radians for versions prior to iOS 17.
    private func angleRadians(for orientation: UIInterfaceOrientation) -> CGFloat {
        let degrees: CGFloat
        switch orientation {
        case .landscapeLeft:
            degrees = 90.0
        case .landscapeRight:
            degrees = 270.0
        case .portraitUpsideDown:
            degrees = 180.0
        case .portrait:
            degrees = 0.0
        default:
            degrees = 0.0
        }
        return degrees * .pi / 180.0
    }
    
    /// Standard initializer: starts observing orientation changes.
    override init(frame: CGRect) {
        super.init(frame: frame)
        startObservingOrientation()
    }

    /// Initializer from storyboard/XIB.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startObservingOrientation()
    }

    /// Cleans up notification subscription when the view is deallocated.
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    /// Subscribes to device orientation changes to refresh layout.
    private func startObservingOrientation() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    /// On orientation change, forces a new layout (therefore adjusting the preview).
    @objc private func orientationDidChange() {
        setNeedsLayout()
        layoutIfNeeded()
    }
}
