//
//  CIProcessor.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//
//  Simple Core Image processor that applies illness-specific effects to a UIImage.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

final class CIProcessor {
    static let shared = CIProcessor()

    private let context = CIContext(options: nil)

    private init() {}

    /// Applies effect to a CGImage and returns CGImage (UIKit-free).
    func apply(
        illness: Illness?,
        centralFocus: Double,
        to image: CGImage,
        panelSize: CGSize,
        centerOffsetNormalized: CGPoint = .zero
    ) -> CGImage {
        guard let illness = illness else { return image }

        let inputCI = CIImage(cgImage: image)
        let clampedFocus = max(0.0, min(1.0, centralFocus))

        let baseCenter = CGPoint(x: inputCI.extent.midX, y: inputCI.extent.midY)
        let offsetPx = CGPoint(
            x: centerOffsetNormalized.x * inputCI.extent.width,
            y: centerOffsetNormalized.y * inputCI.extent.height
        )
        let effectCenter = CGPoint(x: baseCenter.x + offsetPx.x, y: baseCenter.y + offsetPx.y)

        let outputCI: CIImage
        switch illness.filterType {
        case .cataracts:
            // 1. Desenfoque para visión nublada
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = inputCI
            blur.radius = Float(clampedFocus * 20.0)  // ISMA: Esto empezaba en 5, por eso con el slider al mínimo ya se veía borroso. Así va de 0 a 20
            let blurred = blur.outputImage?.clamped(to: inputCI.extent) ?? inputCI // Esto es para evitar que los bordes de la imagen se expandan al desenfocar y los limita a los de la imagen original https://developer.apple.com/documentation/coreimage/ciimage/clamped(to:)
            
            // 2. Reducción de contraste: tienen problemas para distinguir detalles
            let colorControls = CIFilter.colorControls()
            colorControls.inputImage = blurred
            colorControls.contrast = Float(1.0 - clampedFocus * 0.4)  // Reduce contraste
            colorControls.saturation = Float(1.0 - clampedFocus * 0.3)  // Reduce saturación
            
            // 3. Colores desvaídos o amarillentos -> le ponemos un color amarillento
            let colorMatrix = CIFilter.colorMatrix()
            colorMatrix.inputImage = colorControls.outputImage ?? blurred
            colorMatrix.rVector = CIVector(x: 1.0, y: 0, z: 0, w: 0)
            colorMatrix.gVector = CIVector(x: 0, y: 1.0 - CGFloat(clampedFocus * 0.1), z: 0, w: 0)
            colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.0 - CGFloat(clampedFocus * 0.2), w: 0)
            
            outputCI = colorMatrix.outputImage ?? blurred

        case .glaucoma:
            let vignette = CIFilter.vignette()
            vignette.inputImage = inputCI
            vignette.intensity = Float(0.8 + clampedFocus * 1.2)
            vignette.radius = Float(0.8 + clampedFocus * 1.0)
            let first = vignette.outputImage ?? inputCI

            let vignetteEffect = CIFilter.vignetteEffect()
            vignetteEffect.inputImage = first
            vignetteEffect.center = effectCenter
            let minSide = min(inputCI.extent.width, inputCI.extent.height)
            vignetteEffect.radius = Float(minSide * (0.3 + 0.4 * (1.0 - clampedFocus)))
            vignetteEffect.intensity = Float(0.7 + 0.8 * clampedFocus)
            outputCI = vignetteEffect.outputImage ?? first

        case .macularDegeneration:
            let minSide = min(inputCI.extent.width, inputCI.extent.height)
            let innerRadius = CGFloat(10 + clampedFocus * 60)
            let outerRadius = CGFloat(innerRadius + minSide * (0.2 + 0.25 * clampedFocus))
            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(innerRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
            radial.color1 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
            let gradient = radial.outputImage?.cropped(to: inputCI.extent) ?? inputCI
            let darkColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
            let darkOverlay = CIImage(color: darkColor).cropped(to: inputCI.extent)
            let invert = CIFilter.colorInvert()
            invert.inputImage = gradient
            let invertedMask = invert.outputImage ?? gradient
            let blend = CIFilter.blendWithMask()
            blend.inputImage = inputCI
            blend.backgroundImage = darkOverlay
            blend.maskImage = invertedMask
            outputCI = blend.outputImage ?? inputCI

        case .tunnelVision:
            let minSide = min(inputCI.extent.width, inputCI.extent.height)
            let innerRadius = CGFloat(minSide * (0.18 + 0.42 * clampedFocus))
            let feather = CGFloat(minSide * (0.12 + 0.08 * (1.0 - clampedFocus)))
            let outerRadius = innerRadius + feather
            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = inputCI
            blurFilter.radius = Float(8.0 + (1.0 - clampedFocus) * 14.0)
            let blurred = blurFilter.outputImage?.clampedToExtent().cropped(to: inputCI.extent) ?? inputCI
            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(innerRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
            radial.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
            let mask = radial.outputImage?.cropped(to: inputCI.extent) ?? inputCI
            let multiply = CIFilter.multiplyCompositing()
            multiply.inputImage = mask
            multiply.backgroundImage = blurred
            let darkenedPeripheral = multiply.outputImage?.cropped(to: inputCI.extent) ?? blurred
            let composite = CIFilter.blendWithMask()
            composite.inputImage = inputCI
            composite.backgroundImage = darkenedPeripheral
            composite.maskImage = mask
            outputCI = composite.outputImage ?? inputCI
        }

        return context.createCGImage(outputCI, from: inputCI.extent) ?? image
    }
}
