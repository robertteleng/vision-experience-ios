//
//  CameraImageView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//


import SwiftUI
import UIKit

enum CameraPanel {
    case left, right, full
}

struct CameraImageView: View {
    let image: UIImage?
    let panel: CameraPanel
    let illness: Illness?
    let centralFocus: Double

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
                    // Procesa con Core Image según la enfermedad seleccionada
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
                    Color.black
                }
            }
        }
    }
}
