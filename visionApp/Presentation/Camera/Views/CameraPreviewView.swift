//
//  CameraPreviewView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        // No update needed
    }
}

class PreviewUIView: UIView {
    var session: AVCaptureSession? {
        didSet {
            setupPreviewLayer()
        }
    }
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = bounds
        previewLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        // Ajustar mirroring según cámara (frontal suele ir espejada)
        if let input = session?.inputs.first as? AVCaptureDeviceInput,
           let connection = previewLayer.connection {
            // Deshabilitar el ajuste automático antes de establecer manualmente
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = (input.device.position == .front)
        }

        let io = currentInterfaceOrientation()
        if #available(iOS 17.0, *) {
            if let connection = previewLayer.connection {
                connection.videoRotationAngle = angleDegrees(for: io)
            }
        } else {
            let radians = angleRadians(for: io)
            previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: radians))
        }
    }

    private func setupPreviewLayer() {
        previewLayer?.removeFromSuperlayer()
        guard let session = session else { return }
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.addSublayer(layer)
        self.previewLayer = layer
    }
    
    // UIInterfaceOrientation actual (más estable que UIDeviceOrientation)
    private func currentInterfaceOrientation() -> UIInterfaceOrientation {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.interfaceOrientation
        }
        return .unknown
    }

    // iOS 17+: ángulo en grados para cada orientación de interfaz
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

    // iOS < 17: ángulo en radianes
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        startObservingOrientation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startObservingOrientation()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    private func startObservingOrientation() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func orientationDidChange() {
        setNeedsLayout()
        layoutIfNeeded()
    }
}
