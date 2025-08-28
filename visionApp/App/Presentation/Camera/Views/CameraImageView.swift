//
//  CameraImageView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//
//  This file defines the CameraImageView, a SwiftUI view for displaying camera frames.
//  It supports cropping the image for left, right, or full panel display, and applies
//  illness-specific Core Image processing. The view adapts to the geometry and ensures
//  the image is scaled and clipped appropriately.


import SwiftUI
import UIKit

/// Enum representing the panel to display: left, right, or full.
enum CameraPanel {
    case left, right, full
}

/// CameraImageView displays a processed camera image, optionally cropped and filtered.
/// - Crops the image based on the selected panel.
/// - Applies illness-specific processing using CIProcessor.
/// - Adapts to the view's geometry for correct scaling and clipping.
struct CameraImageView: View {
    /// The input image to display.
    let image: UIImage?
    /// The panel to display (left, right, or full).
    let panel: CameraPanel
    /// The selected illness for image processing.
    let illness: Illness?
    /// The central focus value for processing.
    let centralFocus: Double

    /// Crops the input image according to the selected panel.
    private func croppedImage(_ image: UIImage?, panel: CameraPanel) -> UIImage? {
        guard let cgImage = image?.cgImage else { return nil }
        switch panel {
        case .full:
            return image
        case .left, .right:
            let halfWidth = cgImage.width / 2
            let height = cgImage.height
            let rect: CGRect = (panel == .left)
                ? CGRect(x: 0, y: 0, width: halfWidth, height: height)
                : CGRect(x: halfWidth, y: 0, width: halfWidth, height: height)
            guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
            return UIImage(cgImage: croppedCGImage)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let base = croppedImage(image, panel: panel) {
                    // Processes the image with Core Image based on the selected illness.
                    let processed = CIProcessor.shared.apply(
                        illness: illness,
                        centralFocus: centralFocus,
                        to: base,
                        panelSize: geometry.size
                    )
                    Image(uiImage: processed)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Color.black // Fallback if no image is available.
                }
            }
        }
    }
}
