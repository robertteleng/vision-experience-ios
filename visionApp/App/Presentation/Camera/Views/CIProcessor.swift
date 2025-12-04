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
    
    /// Aplica distorsión barrel para lentes Cardboard con factor variable
    private func applyBarrelDistortion(_ image: CIImage, factor: Double) -> CIImage {
        let bumpDistortion = CIFilter.bumpDistortion()
        bumpDistortion.inputImage = image
        bumpDistortion.center = CGPoint(x: image.extent.midX, y: image.extent.midY)
        bumpDistortion.radius = Float(min(image.extent.width, image.extent.height) * 0.4)
        bumpDistortion.scale = Float(factor) // 0 = sin distorsión; negativo = barrel
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
        vrOffset: CGPoint = .zero, // Offset para VR
        vrSettings: VRSettings = .defaults
    ) -> CGImage {
        
        let inputCI = CIImage(cgImage: image)
        
        // PASO 1: Aplicar offset VR si es necesario
        let offsetImage = vrOffset == .zero ? inputCI :
            inputCI.transformed(by: CGAffineTransform(translationX: vrOffset.x, y: vrOffset.y))
        
        // PASO 2: Aplicar distorsión barrel según VRSettings
        let barrelCorrected: CIImage = {
            guard vrOffset != .zero else { return offsetImage }
            let factor = vrSettings.barrelDistortionFactor
            guard abs(factor) > 0.0001 else { return offsetImage } // 0.0 => sin distorsión
            return applyBarrelDistortion(offsetImage, factor: factor)
        }()
        
        // PASO 2.1: Aplicar zoom de compensación si corresponde
        let zoomed: CIImage = {
            let zoom = vrSettings.distortionZoomFactor
            guard abs(zoom - 1.0) > 0.0001 else { return barrelCorrected }
            let cx = barrelCorrected.extent.midX
            let cy = barrelCorrected.extent.midY
            let t = CGAffineTransform(translationX: cx, y: cy)
                .scaledBy(x: zoom, y: zoom)
                .translatedBy(x: -cx, y: -cy)
            return barrelCorrected.transformed(by: t)
        }()
        
        // PASO 3: Si no hay enfermedad o filtro desactivado, devolvemos imagen con correcciones aplicadas
        guard filterEnabled, let illness = illness else {
            return context.createCGImage(zoomed, from: inputCI.extent) ?? image
        }

        let clampedFocus = max(0.0, min(1.0, centralFocus))

        // Centro del efecto con offset (ahora sobre zoomed)
        let baseCenterX = zoomed.extent.midX
        let baseCenterY = zoomed.extent.midY
        let offsetPx = CGPoint(
            x: centerOffsetNormalized.x * zoomed.extent.width,
            y: centerOffsetNormalized.y * zoomed.extent.height
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
            blur.inputImage = zoomed  // Usar imagen con corrección y zoom
            let blurRadius = s.blurRadius * clampedFocus
            blur.radius = Float(blurRadius)
            let blurred = blur.outputImage?.clamped(to: zoomed.extent) ?? zoomed

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
            vignette.inputImage = zoomed
            vignette.intensity = Float((0.8 + s.vignetteIntensity * 1.2) * clampedFocus)
            vignette.radius = Float(0.8 + s.vignetteRadiusFactor * 1.0)
            let first = vignette.outputImage ?? zoomed

            let vignetteEffect = CIFilter.vignetteEffect()
            vignetteEffect.inputImage = first
            vignetteEffect.center = effectCenter
            let minSide = min(zoomed.extent.width, zoomed.extent.height)
            vignetteEffect.radius = Float(minSide * s.effectRadiusFactor * (1.0 - clampedFocus + 0.0001))
            vignetteEffect.intensity = Float(clampedFocus)
            outputCI = vignetteEffect.outputImage ?? first

        case .macularDegeneration:
            let s: MacularDegenerationSettings = {
                if case .macular(let v) = settings { return v }
                return .defaults
            }()
            let minSide = min(zoomed.extent.width, zoomed.extent.height)
            let innerRadius = CGFloat(s.innerRadius * clampedFocus)
            let outerRadius = CGFloat(innerRadius + minSide * (s.outerRadiusFactor * clampedFocus))

            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(innerRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
            radial.color1 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
            let gradient = radial.outputImage?.cropped(to: zoomed.extent) ?? zoomed

            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = zoomed
            blurFilter.radius = Float(s.blurRadius * clampedFocus)
            let blurredImage = blurFilter.outputImage?.clamped(to: zoomed.extent) ?? zoomed

            let darkColor = CIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(s.darkAlpha * clampedFocus))
            let darkOverlay = CIImage(color: darkColor).cropped(to: zoomed.extent)

            let distortion = CIFilter.twirlDistortion()
            distortion.inputImage = gradient
            distortion.center = effectCenter
            distortion.radius = Float(innerRadius)
            distortion.angle = Float(s.twirlAngle * clampedFocus)

            let blend = CIFilter.blendWithMask()
            blend.inputImage = blurredImage
            blend.backgroundImage = darkOverlay
            blend.maskImage = distortion.outputImage

            outputCI = blend.outputImage ?? zoomed

        case .tunnelVision:
            let s: TunnelVisionSettings = {
                if case .tunnel(let v) = settings { return v }
                return .defaults
            }()
            let minSide = min(zoomed.extent.width, zoomed.extent.height)
            let minTunnelRadius = minSide * CGFloat(s.minRadiusPercent)
            let maxTunnelRadius = minSide * CGFloat(s.maxRadiusFactor)
            let tunnelRadius = minTunnelRadius + (maxTunnelRadius - minTunnelRadius) * CGFloat(1 - clampedFocus)

            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = zoomed
            blurFilter.radius = Float((s.blurRadius * (0.4 + 0.6 * (1.0 - clampedFocus))))
            let blurred = blurFilter.outputImage?.clampedToExtent().cropped(to: zoomed.extent) ?? zoomed

            let feather = tunnelRadius * CGFloat(s.featherFactorBase * (0.8 + 0.2 * (1.0 - clampedFocus)))
            let outerRadius = tunnelRadius + feather

            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(tunnelRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
            radial.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
            let mask = radial.outputImage?.cropped(to: zoomed.extent) ?? zoomed

            let multiply = CIFilter.multiplyCompositing()
            multiply.inputImage = mask
            multiply.backgroundImage = blurred
            let darkenedPeripheral = multiply.outputImage?.cropped(to: zoomed.extent) ?? blurred

            let composite = CIFilter.blendWithMask()
            composite.inputImage = zoomed
            composite.backgroundImage = darkenedPeripheral
            composite.maskImage = mask
            outputCI = composite.outputImage ?? zoomed

        case .hemianopsia:
            let s: HemianopsiaSettings = {
                if case .hemianopsia(let v) = settings { return v }
                return .defaults
            }()
            let minSide = min(zoomed.extent.width, zoomed.extent.height)
            let feather = CGFloat(s.featherFactor) * minSide
            let maskWidth = zoomed.extent.width * 0.5
            let maskRect: CGRect = s.leftSideAffected ?
                CGRect(x: 0, y: 0, width: maskWidth + feather, height: zoomed.extent.height) :
                CGRect(x: maskWidth - feather, y: 0, width: maskWidth + feather, height: zoomed.extent.height)
            // Crear máscara con gradiente para suavizar el borde
            let gradient = CIFilter.linearGradient()
            gradient.point0 = s.leftSideAffected ? CGPoint(x: maskWidth, y: 0) : CGPoint(x: maskWidth, y: 0)
            gradient.point1 = s.leftSideAffected ? CGPoint(x: maskWidth + feather, y: 0) : CGPoint(x: maskWidth - feather, y: 0)
            gradient.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
            gradient.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
            let gradImage = gradient.outputImage?.cropped(to: maskRect) ?? zoomed
            // Crear fondo negro para la mitad afectada
            let black = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 1)).cropped(to: maskRect)
            // Componer la imagen final
            let composite = CIFilter.sourceOverCompositing()
            composite.inputImage = black.composited(over: gradImage)
            composite.backgroundImage = zoomed
            outputCI = composite.outputImage?.cropped(to: zoomed.extent) ?? zoomed
            
        case .blurryVision:
            // TODO: Implement blurry vision effect
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = zoomed
            blur.radius = Float(10.0 * clampedFocus)
            outputCI = blur.outputImage?.clamped(to: zoomed.extent) ?? zoomed
            
        case .centralScotoma:
            // TODO: Implement central scotoma effect
            outputCI = zoomed
            
        case .diabeticRetinopathy:
            // TODO: Implement diabetic retinopathy effect
            outputCI = zoomed
            
        case .deuteranopia:
            // TODO: Implement deuteranopia (color blindness) effect
            outputCI = zoomed
            
        case .astigmatism:
            // TODO: Implement astigmatism effect
            outputCI = zoomed
        }

        return context.createCGImage(outputCI, from: inputCI.extent) ?? image
    }
}
