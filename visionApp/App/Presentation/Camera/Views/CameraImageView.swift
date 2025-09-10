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
    /// Filter enabled toggle
    let filterEnabled: Bool
    /// Illness-specific settings wrapper
    let illnessSettings: IllnessSettings?
    
    //    /// Crops the input image according to the selected panel.
    //    private func croppedImage(_ image: CGImage?, panel: Panel) -> CGImage? {
    //        guard let cgImage = image else { return nil }
    //        switch panel {
    //        case .full:
    //            return cgImage
    //        case .left, .right:
    //            let width = cgImage.width
    //            let height = cgImage.height
    //            let halfWidth = width / 2
    //            let rect: CGRect = (panel == .left)
    //                ? CGRect(x: 0, y: 0, width: halfWidth, height: height)
    //                : CGRect(x: halfWidth, y: 0, width: halfWidth, height: height)
    //            return cgImage.cropping(to: rect)
    //        }
    //    }
    
    // En CameraImageView.swift - función completa y optimizada
    private func applyVROffset(_ image: CGImage?, panel: Panel, ipdPixels: Double) -> CGImage? {
        guard let cgImage = image else { return nil }
        
        switch panel {
        case .full:
            return cgImage // Sin cambios para modo normal
            
        case .left, .right:
            let ciImage = CIImage(cgImage: cgImage)
            
            // Calcular offset: negativo para izquierda, positivo para derecha
            let offsetX = panel == .left ? -ipdPixels/2 : +ipdPixels/2
            
            // Aplicar transformación
            let transform = CGAffineTransform(translationX: offsetX, y: 0)
            let transformedImage = ciImage.transformed(by: transform)
            
            // Mantener el extent original para evitar recortes
            let outputExtent = ciImage.extent
            
            // Crear contexto y renderizar
            let context = CIContext()
            return context.createCGImage(transformedImage, from: outputExtent)
        }
    }
    
    // En CameraImageView.swift - REEMPLAZAR el body actual
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = image {
                    // PASO 1: Aplicar offset IPD (nueva función)
                    let offsetImage = applyVROffset(
                        image,
                        panel: panel,
                        ipdPixels: 32.0 // TODO: hacer configurable
                    )
                    
                    // PASO 2: Aplicar filtros de enfermedad (tu código existente)
                    if let processedImage = offsetImage {
                        let finalImage: CGImage = CIProcessor.shared.apply(
                            illness: illness,
                            settings: illnessSettings,
                            filterEnabled: filterEnabled,
                            centralFocus: centralFocus,
                            to: processedImage,
                            panelSize: geometry.size
                        )
                        
                        // PASO 3: Mostrar resultado final
                        Image(decorative: finalImage, scale: 1.0, orientation: .up)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else {
                        Color.black // Fallback
                    }
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
//        illnessSettings: .cataracts(.defaults)
//    )
//}

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

