//
//  CameraPreviewView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  SwiftUI wrapper around AVCaptureVideoPreviewLayer to display the camera
//  preview. It fills its container and keeps the video oriented with the UI.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        // Ensure initial orientation
        view.updateOrientation()
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        if uiView.videoPreviewLayer.session !== session {
            uiView.videoPreviewLayer.session = session
        }
        // Keep orientation in sync on updates/layout changes
        uiView.updateOrientation()
    }

    static func dismantleUIView(_ uiView: PreviewView, coordinator: ()) {
        NotificationCenter.default.removeObserver(uiView)
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        videoPreviewLayer.videoGravity = .resizeAspectFill
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
        // Adjust on layout in case bounds changed due to rotation/UI changes
        updateOrientation()
    }

    @objc private func orientationDidChange() {
        updateOrientation()
    }

    func updateOrientation() {
        guard let connection = videoPreviewLayer.connection else { return }
        let io: UIInterfaceOrientation
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            io = scene.interfaceOrientation
        } else {
            switch UIDevice.current.orientation {
            case .landscapeLeft: io = .landscapeLeft
            case .landscapeRight: io = .landscapeRight
            case .portraitUpsideDown: io = .portraitUpsideDown
            case .portrait: io = .portrait
            default: io = .portrait
            }
        }
        if #available(iOS 17.0, *) {
            let angle: CGFloat
            switch io {
            case .landscapeLeft: angle = 90
            case .landscapeRight: angle = 270
            case .portraitUpsideDown: angle = 180
            case .portrait: angle = 0
            default: angle = 0
            }
            if connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        } else if connection.isVideoOrientationSupported {
            switch io {
            case .landscapeLeft: connection.videoOrientation = .landscapeLeft
            case .landscapeRight: connection.videoOrientation = .landscapeRight
            case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
            default: connection.videoOrientation = .portrait
            }
        }
    }
}
