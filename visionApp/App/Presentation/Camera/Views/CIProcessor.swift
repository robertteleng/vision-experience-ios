//
//  CIProcessor.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//
//  Procesador simple de Core Image que aplica efectos específicos de enfermedades a una UIImage.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

final class CIProcessor {
    static let shared = CIProcessor() // Instancia única (singleton) del procesador
    
    private let context = CIContext(options: nil) // Contexto de Core Image para realizar operaciones
    
    private init() {} // Inicializador privado para evitar la creación de instancias adicionales
    
    /// Aplica distorsión barrel para lentes Cardboard
    private func applyBarrelDistortion(_ image: CIImage) -> CIImage {
        let bumpDistortion = CIFilter.bumpDistortion()
        bumpDistortion.inputImage = image
        bumpDistortion.center = CGPoint(x: image.extent.midX, y: image.extent.midY)
        bumpDistortion.radius = Float(min(image.extent.width, image.extent.height) * 0.4)
        bumpDistortion.scale = -0.5 // Negativo para barrel (hacia adentro)
        return bumpDistortion.outputImage ?? image
    }
    
    /// Aplica efecto a un CGImage y devuelve CGImage (sin UIKit).
    func apply(
        illness: Illness?, // Enfermedad a la cual se aplicará el efecto
        settings: IllnessSettings?, // Ajustes específicos por enfermedad
        filterEnabled: Bool, // Si está desactivado, devuelve imagen original
        centralFocus: Double, // Intensidad global
        to image: CGImage, // Imagen de entrada
        panelSize: CGSize, // Tamaño del panel para la imagen
        centerOffsetNormalized: CGPoint = .zero, // Desplazamiento normalizado para centrar el efecto
        vrOffset: CGPoint = .zero // Offset para VR
    ) -> CGImage {
        
        let inputCI = CIImage(cgImage: image)
        
        // PASO 1: Aplicar offset VR si es necesario
        let offsetImage = vrOffset == .zero ? inputCI :
            inputCI.transformed(by: CGAffineTransform(translationX: vrOffset.x, y: vrOffset.y))
        
        // PASO 2: Aplicar distorsión barrel para Cardboard (solo para panels izq/der)
        let barrelCorrected = (vrOffset == .zero) ? offsetImage : applyBarrelDistortion(offsetImage)
        
        // PASO 3: Si no hay enfermedad o filtro desactivado, devolvemos imagen con correcciones aplicadas
        guard filterEnabled, let illness = illness else {
            return context.createCGImage(barrelCorrected, from: inputCI.extent) ?? image
        }

        let clampedFocus = max(0.0, min(1.0, centralFocus))

        // Centro del efecto con offset (ahora sobre barrelCorrected)
        let baseCenterX = barrelCorrected.extent.midX
        let baseCenterY = barrelCorrected.extent.midY
        let offsetPx = CGPoint(
            x: centerOffsetNormalized.x * barrelCorrected.extent.width,
            y: centerOffsetNormalized.y * barrelCorrected.extent.height
        )
        let effectCenter = CGPoint(x: baseCenterX + offsetPx.x, y: baseCenterY + offsetPx.y)

        let outputCI: CIImage
        switch illness.filterType {
        case .cataracts:
            // Settings concretos (con defaults por si no llegan)
            let s: CataractsSettings = {
                if case .cataracts(let v) = settings { return v }
                return .defaults
            }()
            // Aplicamos parámetros modulados por centralFocus como factor global
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = barrelCorrected  // Usar imagen con corrección barrel
            let blurRadius = s.blurRadius * clampedFocus
            blur.radius = Float(blurRadius)
            let blurred = blur.outputImage?.clamped(to: barrelCorrected.extent) ?? barrelCorrected

            let colorControls = CIFilter.colorControls()
            colorControls.inputImage = blurred
            colorControls.contrast = Float(1.0 - s.contrastReduction * clampedFocus)
            colorControls.saturation = Float(1.0 - s.saturationReduction * clampedFocus)

            let colorMatrix = CIFilter.colorMatrix()
            colorMatrix.inputImage = colorControls.outputImage ?? blurred
            colorMatrix.rVector = CIVector(x: 1.0, y: 0, z: 0, w: 0)
            colorMatrix.gVector = CIVector(x: 0, y: 1.0, z: 0, w: 0)
            let blueScale = max(0.0, 1.0 - CGFloat(s.blueReduction * clampedFocus))
            colorMatrix.bVector = CIVector(x: 0, y: 0, z: blueScale, w: 0)

            outputCI = colorMatrix.outputImage ?? blurred

        case .glaucoma:
            let s: GlaucomaSettings = {
                if case .glaucoma(let v) = settings { return v }
                return .defaults
            }()
            let vignette = CIFilter.vignette()
            vignette.inputImage = barrelCorrected
            vignette.intensity = Float((0.8 + s.vignetteIntensity * 1.2) * clampedFocus)
            vignette.radius = Float(0.8 + s.vignetteRadiusFactor * 1.0)
            let first = vignette.outputImage ?? barrelCorrected

            let vignetteEffect = CIFilter.vignetteEffect()
            vignetteEffect.inputImage = first
            vignetteEffect.center = effectCenter
            let minSide = min(barrelCorrected.extent.width, barrelCorrected.extent.height)
            vignetteEffect.radius = Float(minSide * s.effectRadiusFactor * (1.0 - clampedFocus + 0.0001))
            vignetteEffect.intensity = Float(clampedFocus)
            outputCI = vignetteEffect.outputImage ?? first

        case .macularDegeneration:
            let s: MacularDegenerationSettings = {
                if case .macular(let v) = settings { return v }
                return .defaults
            }()
            let minSide = min(barrelCorrected.extent.width, barrelCorrected.extent.height)
            let innerRadius = CGFloat(s.innerRadius * clampedFocus)
            let outerRadius = CGFloat(innerRadius + minSide * (s.outerRadiusFactor * clampedFocus))

            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(innerRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
            radial.color1 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
            let gradient = radial.outputImage?.cropped(to: barrelCorrected.extent) ?? barrelCorrected

            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = barrelCorrected
            blurFilter.radius = Float(s.blurRadius * clampedFocus)
            let blurredImage = blurFilter.outputImage?.clamped(to: barrelCorrected.extent) ?? barrelCorrected

            let darkColor = CIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(s.darkAlpha * clampedFocus))
            let darkOverlay = CIImage(color: darkColor).cropped(to: barrelCorrected.extent)

            let distortion = CIFilter.twirlDistortion()
            distortion.inputImage = gradient
            distortion.center = effectCenter
            distortion.radius = Float(innerRadius)
            distortion.angle = Float(s.twirlAngle * clampedFocus)

            let blend = CIFilter.blendWithMask()
            blend.inputImage = blurredImage
            blend.backgroundImage = darkOverlay
            blend.maskImage = distortion.outputImage

            outputCI = blend.outputImage ?? barrelCorrected

        case .tunnelVision:
            let s: TunnelVisionSettings = {
                if case .tunnel(let v) = settings { return v }
                return .defaults
            }()
            let minSide = min(barrelCorrected.extent.width, barrelCorrected.extent.height)
            let minTunnelRadius = minSide * CGFloat(s.minRadiusPercent)
            let maxTunnelRadius = minSide * CGFloat(s.maxRadiusFactor)
            let tunnelRadius = minTunnelRadius + (maxTunnelRadius - minTunnelRadius) * CGFloat(1 - clampedFocus)

            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = barrelCorrected
            blurFilter.radius = Float((s.blurRadius * (0.4 + 0.6 * (1.0 - clampedFocus))))
            let blurred = blurFilter.outputImage?.clampedToExtent().cropped(to: barrelCorrected.extent) ?? barrelCorrected

            let feather = tunnelRadius * CGFloat(s.featherFactorBase * (0.8 + 0.2 * (1.0 - clampedFocus)))
            let outerRadius = tunnelRadius + feather

            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(tunnelRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
            radial.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
            let mask = radial.outputImage?.cropped(to: barrelCorrected.extent) ?? barrelCorrected

            let multiply = CIFilter.multiplyCompositing()
            multiply.inputImage = mask
            multiply.backgroundImage = blurred
            let darkenedPeripheral = multiply.outputImage?.cropped(to: barrelCorrected.extent) ?? blurred

            let composite = CIFilter.blendWithMask()
            composite.inputImage = barrelCorrected
            composite.backgroundImage = darkenedPeripheral
            composite.maskImage = mask
            outputCI = composite.outputImage ?? barrelCorrected
        }

        return context.createCGImage(outputCI, from: inputCI.extent) ?? image
    }
}
