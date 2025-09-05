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
//

import SwiftUI
import Foundation
//import App.Presentation.Components.Panel // Import shared Panel enum

/// CameraImageView displays a processed camera image, optionally cropped and filtered.
/// - Crops the image based on the selected panel.
/// - Applies illness-specific processing using CIProcessor.
/// - Adapts to the view's geometry for correct scaling and clipping.
struct CameraImageView: View {
    /// The input image to display (UIKit-free CGImage).
    let image: CGImage?
    /// The panel to display (left, right, or full).
    let panel: Panel // Use shared Panel enum
    /// The selected illness for image processing.
    let illness: Illness?
    /// The central focus value for processing.
    let centralFocus: Double

    /// Crops the input image according to the selected panel.
    private func croppedImage(_ image: CGImage?, panel: Panel) -> CGImage? {
        guard let cgImage = image else { return nil }
        switch panel {
        case .full:
            return cgImage
        case .left, .right:
            let width = cgImage.width
            let height = cgImage.height
            let halfWidth = width / 2
            let rect: CGRect = (panel == .left)
                ? CGRect(x: 0, y: 0, width: halfWidth, height: height)
                : CGRect(x: halfWidth, y: 0, width: halfWidth, height: height)
            return cgImage.cropping(to: rect)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let base = croppedImage(image, panel: panel) {
                    // Processes the image with Core Image based on the selected illness (CGImage path).
                    let processed: CGImage = CIProcessor.shared.apply(
                        illness: illness,
                        centralFocus: centralFocus,
                        to: base,
                        panelSize: geometry.size,
//                        centerOffsetNormalized: centerOffsetNormalized(for: panel)
                    )
                    Image(decorative: processed, scale: 1.0, orientation: .up)
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

#Preview {
    CameraImageView(
        image: nil,
        panel: .full,
        illness: Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts),
        centralFocus: 0.5
    )
}

/// ViewModifier para aplicar rotación solo en panel .full --> ISMA: Esto no es necesario, la imagen se ve bien sin rotación. Lo dejo por si le tienes cariño, lo aplicabas a la Image así: .modifier(FullPanelRotationFix(apply: panel == .full))
//private struct FullPanelRotationFix: ViewModifier {
//    let apply: Bool
//    func body(content: Content) -> some View {
//        if apply {
//            // La imagen te aparece 90° en sentido antihorario (CCW),
//            // por lo que aplicamos +90° (CW) para corregir.
//            content.rotationEffect(.degrees(90))
//        } else {
//            content
//        }
//    }
//}


//    /// Optional per-panel center offset to compensate small misalignment in stereoscopic mode. --> ISMA: Esto tampoco es necesario, la imagen se ve centrada sin offset. Lo dejo por si le tienes cariño, lo aplicabas a CIProcessor así: centerOffsetNormalized: centerOffsetNormalized(for: panel). Te dejo ese parámetro en CIProcessor comentado por si en el futuro lo quieres usar.
//    /// Values are normalized (fraction of image width/height).
//    private func centerOffsetNormalized(for panel: Panel) -> CGPoint {
//        switch panel {
//        case .left:
//            // Slightly shift center to the left (~3% of width). Tune if needed.
//            return CGPoint(x: 0.0, y: 0.0)
//        case .right:
//            return CGPoint(x: 0.0, y: 0.0)
//        case .full:
//            return .zero
//        }
//    }
