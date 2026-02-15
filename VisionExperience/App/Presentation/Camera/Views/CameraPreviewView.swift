//
//  CameraPreviewView.swift
//  VisionExperience
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  SwiftUI wrapper around AVCaptureVideoPreviewLayer to display the camera
//  preview. It fills its container. Orientation is managed exclusively by
//  CameraService.
//

import SwiftUI
import AVFoundation
//import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        if uiView.videoPreviewLayer.session !== session {
            uiView.videoPreviewLayer.session = session
        }
        // Orientation is handled by CameraService. No changes here.
    }

    static func dismantleUIView(_ uiView: PreviewView, coordinator: ()) {
        // No observers added here anymore.
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
        // No orientation observation here; CameraService is the source of truth.
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
    }
}
