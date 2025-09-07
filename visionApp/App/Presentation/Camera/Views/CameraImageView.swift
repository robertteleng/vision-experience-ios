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
<<<<<<< HEAD


import SwiftUI
import UIKit

/// Enum representing the panel to display: left, right, or full.
enum CameraPanel {
    case left, right, full
}

=======
//

import SwiftUI
import Foundation
//import App.Presentation.Components.Panel // Import shared Panel enum

>>>>>>> illness-filters-temp
/// CameraImageView displays a processed camera image, optionally cropped and filtered.
/// - Crops the image based on the selected panel.
/// - Applies illness-specific processing using CIProcessor.
/// - Adapts to the view's geometry for correct scaling and clipping.
struct CameraImageView: View {
<<<<<<< HEAD
    /// The input image to display.
    let image: UIImage?
    /// The panel to display (left, right, or full).
    let panel: CameraPanel
=======
    /// The input image to display (UIKit-free CGImage).
    let image: CGImage?
    /// The panel to display (left, right, or full).
    let panel: Panel // Use shared Panel enum
>>>>>>> illness-filters-temp
    /// The selected illness for image processing.
    let illness: Illness?
    /// The central focus value for processing.
    let centralFocus: Double
<<<<<<< HEAD

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
=======
    /// Filter enabled toggle
    let filterEnabled: Bool
    /// Illness-specific settings wrapper
    let illnessSettings: IllnessSettings?

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
>>>>>>> illness-filters-temp
        }
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let base = croppedImage(image, panel: panel) {
<<<<<<< HEAD
                    // Processes the image with Core Image based on the selected illness.
                    let processed = CIProcessor.shared.apply(
                        illness: illness,
                        centralFocus: centralFocus,
                        to: base,
                        panelSize: geometry.size
                    )
                    Image(uiImage: processed)
=======
                    // Processes the image with Core Image based on the selected illness (CGImage path).
                    let processed: CGImage = CIProcessor.shared.apply(
                        illness: illness,
                        settings: illnessSettings,
                        filterEnabled: filterEnabled,
                        centralFocus: centralFocus,
                        to: base,
                        panelSize: geometry.size
                        // centerOffsetNormalized: centerOffsetNormalized(for: panel)
                    )
                    Image(decorative: processed, scale: 1.0, orientation: .up)
>>>>>>> illness-filters-temp
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
        centralFocus: 0.5,
        filterEnabled: true,
        illnessSettings: .cataracts(.defaults)
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

