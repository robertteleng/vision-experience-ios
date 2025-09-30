//
//  CameraImageView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//
//  This file defines the CameraImageView, a SwiftUI view for displaying camera frames.
//  It applies illness-specific Core Image processing with VR offset for stereoscopic display.
//  The view adapts to the geometry and ensures the image is scaled and clipped appropriately.
//

import SwiftUI
import Foundation

/// CameraImageView displays a processed camera image with VR offset and filters.
/// - Applies VR offset based on the selected panel (left/right eye).
/// - Applies illness-specific processing using CIProcessor.
/// - Adapts to the view's geometry for correct scaling and clipping.
struct CameraImageView: View {
    /// The input image to display (UIKit-free CGImage).
    let image: CGImage?
    /// The panel to display (left, right, or full).
    let panel: Panel
    /// The selected illness for image processing.
    let illness: Illness?
    /// The central focus value for processing.
    let centralFocus: Double
    /// Filter enabled toggle
    let filterEnabled: Bool
    /// Illness-specific settings wrapper
    let illnessSettings: IllnessSettings?
    /// VR settings for stereoscopic rendering
    let vrSettings: VRSettings

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = image {
                    // Calcular offset VR según el panel usando IPD en píxeles
                    let halfIPD = CGFloat(vrSettings.interpupillaryDistancePixels / 2.0)
                    let vrOffset: CGPoint = {
                        switch panel {
                        case .full: return .zero
                        case .left: return CGPoint(x: -halfIPD, y: 0)
                        case .right: return CGPoint(x: halfIPD, y: 0)
                        }
                    }()
                    
                    // Pipeline unificado: offset + filtro en una sola pasada
                    let processed: CGImage = CIProcessor.shared.apply(
                        illness: illness,
                        settings: illnessSettings,
                        filterEnabled: filterEnabled,
                        centralFocus: centralFocus,
                        to: image,
                        panelSize: geometry.size,
                        vrOffset: vrOffset,
                        vrSettings: vrSettings
                    )
                    
                    Image(decorative: processed, scale: 1.0, orientation: .up)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Color.black // No hay imagen disponible
                }
            }
        }
    }
}

//#Preview {
//    CameraImageView(
//        image: nil,
//        panel: .full,
//        illness: Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts),
//        centralFocus: 0.5,
//        filterEnabled: true,
//        illnessSettings: .cataracts(.defaults),
//        vrSettings: .defaults
//    )
//}

