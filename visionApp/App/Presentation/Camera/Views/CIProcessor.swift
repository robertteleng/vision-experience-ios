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
    
    /// Aplica efecto a un CGImage y devuelve CGImage (sin UIKit).
    func apply(
        illness: Illness?,
        settings: IllnessSettings?,
        filterEnabled: Bool,
        centralFocus: Double,
        to image: CGImage,
        panelSize: CGSize,
        centerOffsetNormalized: CGPoint = .zero
    ) -> CGImage {
        guard filterEnabled, let illness = illness else { return image }

        let inputCI = CIImage(cgImage: image)
        let clampedFocus = max(0.0, min(1.0, centralFocus))

        // Centro del efecto con offset externo
        let baseCenter = CGPoint(x: inputCI.extent.midX, y: inputCI.extent.midY)
        let offsetPx = CGPoint(
            x: centerOffsetNormalized.x * inputCI.extent.width,
            y: centerOffsetNormalized.y * inputCI.extent.height
        )
        let effectCenter = CGPoint(x: baseCenter.x + offsetPx.x, y: baseCenter.y + offsetPx.y)

        let outputCI: CIImage
        switch illness.filterType {
        case .cataracts:
            let s: CataractsSettings = {
                if case .cataracts(let v) = settings { return v }
                return .defaults
            }()
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = inputCI
            let blurRadius = s.blurRadius * clampedFocus
            blur.radius = Float(blurRadius)
            let blurred = blur.outputImage?.clamped(to: inputCI.extent) ?? inputCI

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
            vignette.inputImage = inputCI
            vignette.intensity = Float((0.8 + s.vignetteIntensity * 1.2) * clampedFocus)
            vignette.radius = Float(0.8 + s.vignetteRadiusFactor * 1.0)
            let first = vignette.outputImage ?? inputCI

            let vignetteEffect = CIFilter.vignetteEffect()
            vignetteEffect.inputImage = first
            vignetteEffect.center = effectCenter
            let minSide = min(inputCI.extent.width, inputCI.extent.height)
            vignetteEffect.radius = Float(minSide * s.effectRadiusFactor * (1.0 - clampedFocus + 0.0001))
            vignetteEffect.intensity = Float(clampedFocus)
            outputCI = vignetteEffect.outputImage ?? first

        case .macularDegeneration:
            let s: MacularDegenerationSettings = {
                if case .macular(let v) = settings { return v }
                return .defaults
            }()
            let minSide = min(inputCI.extent.width, inputCI.extent.height)
            let innerRadius = CGFloat(s.innerRadius * clampedFocus)
            let outerRadius = CGFloat(innerRadius + minSide * (s.outerRadiusFactor * clampedFocus))

            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(innerRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
            radial.color1 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
            let gradient = radial.outputImage?.cropped(to: inputCI.extent) ?? inputCI

            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = inputCI
            blurFilter.radius = Float(s.blurRadius * clampedFocus)
            let blurredImage = blurFilter.outputImage?.clamped(to: inputCI.extent) ?? inputCI

            let darkColor = CIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(s.darkAlpha * clampedFocus))
            let darkOverlay = CIImage(color: darkColor).cropped(to: inputCI.extent)

            let distortion = CIFilter.twirlDistortion()
            distortion.inputImage = gradient
            distortion.center = effectCenter
            distortion.radius = Float(innerRadius)
            distortion.angle = Float(s.twirlAngle * clampedFocus)

            let blend = CIFilter.blendWithMask()
            blend.inputImage = blurredImage
            blend.backgroundImage = darkOverlay
            blend.maskImage = distortion.outputImage
            outputCI = blend.outputImage ?? inputCI

        case .tunnelVision:
            let s: TunnelVisionSettings = {
                if case .tunnel(let v) = settings { return v }
                return .defaults
            }()
            let minSide = min(inputCI.extent.width, inputCI.extent.height)
            let minTunnelRadius = minSide * CGFloat(s.minRadiusPercent)
            let maxTunnelRadius = minSide * CGFloat(s.maxRadiusFactor)
            let tunnelRadius = minTunnelRadius + (maxTunnelRadius - minTunnelRadius) * CGFloat(1 - clampedFocus)

            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = inputCI
            blurFilter.radius = Float((s.blurRadius * (0.4 + 0.6 * (1.0 - clampedFocus))))
            let blurred = blurFilter.outputImage?.clampedToExtent().cropped(to: inputCI.extent) ?? inputCI

            let feather = tunnelRadius * CGFloat(s.featherFactorBase * (0.8 + 0.2 * (1.0 - clampedFocus)))
            let outerRadius = tunnelRadius + feather

            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(tunnelRadius)
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

        case .blurryVision:
            let s: BlurryVisionSettings = {
                if case .blurryVision(let v) = settings { return v }
                return .defaults
            }()
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = inputCI
            blur.radius = Float(s.blurRadius * clampedFocus)
            outputCI = blur.outputImage?.clampedToExtent().cropped(to: inputCI.extent) ?? inputCI

        case .centralScotoma:
            let s: CentralScotomaSettings = {
                if case .centralScotoma(let v) = settings { return v }
                return .defaults
            }()
            let centerWithOffsets = CGPoint(
                x: effectCenter.x + CGFloat(s.offsetNormalizedX) * inputCI.extent.width,
                y: effectCenter.y + CGFloat(s.offsetNormalizedY) * inputCI.extent.height
            )
            let inner = max(0.0, CGFloat(s.innerRadius) * CGFloat(0.6 + 0.4 * clampedFocus))
            let feather = max(1.0, CGFloat(s.feather) * CGFloat(0.5 + 0.5 * clampedFocus))
            let outer = inner + feather

            let radial = CIFilter.radialGradient()
            radial.center = centerWithOffsets
            radial.radius0 = Float(inner)
            radial.radius1 = Float(outer)
            radial.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 0) // centro
            radial.color1 = CIColor(red: 1, green: 1, blue: 1, alpha: 1) // fuera
            let mask = radial.outputImage?.cropped(to: inputCI.extent) ?? inputCI

            let alpha = CGFloat(min(1.0, max(0.0, s.opacity)) * clampedFocus)
            let dark = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: alpha)).cropped(to: inputCI.extent)

            let blend = CIFilter.blendWithMask()
            blend.inputImage = inputCI
            blend.backgroundImage = dark
            blend.maskImage = mask
            outputCI = blend.outputImage ?? inputCI

        case .hemianopsia:
            let s: HemianopsiaSettings = {
                if case .hemianopsia(let v) = settings { return v }
                return .defaults
            }()
            let rect = inputCI.extent
            let dark = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(s.opacity * clampedFocus)))
                .cropped(to: rect)

            let feather = CGFloat(max(1.0, s.feather))
            let gradient = CIFilter.linearGradient()
            let startPoint: CGPoint
            let endPoint: CGPoint
            switch s.side {
            case .left:
                startPoint = CGPoint(x: rect.minX + feather, y: rect.midY)
                endPoint   = CGPoint(x: rect.minX, y: rect.midY)
            case .right:
                startPoint = CGPoint(x: rect.maxX - feather, y: rect.midY)
                endPoint   = CGPoint(x: rect.maxX, y: rect.midY)
            case .top:
                startPoint = CGPoint(x: rect.midX, y: rect.maxY - feather)
                endPoint   = CGPoint(x: rect.midX, y: rect.maxY)
            case .bottom:
                startPoint = CGPoint(x: rect.midX, y: rect.minY + feather)
                endPoint   = CGPoint(x: rect.midX, y: rect.minY)
            }
            gradient.point0 = startPoint
            gradient.point1 = endPoint
            gradient.color0 = CIColor.white
            gradient.color1 = CIColor.black
            let g = gradient.outputImage?.cropped(to: rect) ?? CIImage(color: .white).cropped(to: rect)

            let mask: CIImage
            switch s.side {
            case .left:
                let rightWhite = CIImage(color: .white).cropped(to: CGRect(x: rect.midX, y: rect.minY, width: rect.width / 2, height: rect.height))
                let leftGrad = g.cropped(to: CGRect(x: rect.minX, y: rect.minY, width: rect.width / 2, height: rect.height))
                mask = rightWhite.composited(over: leftGrad.composited(over: CIImage(color: .black).cropped(to: CGRect(x: rect.minX, y: rect.minY, width: rect.width / 2, height: rect.height)))).cropped(to: rect)
            case .right:
                let leftWhite = CIImage(color: .white).cropped(to: CGRect(x: rect.minX, y: rect.minY, width: rect.width / 2, height: rect.height))
                let rightGrad = g.cropped(to: CGRect(x: rect.midX, y: rect.minY, width: rect.width / 2, height: rect.height))
                mask = leftWhite.composited(over: rightGrad.composited(over: CIImage(color: .black).cropped(to: CGRect(x: rect.midX, y: rect.minY, width: rect.width / 2, height: rect.height)))).cropped(to: rect)
            case .top:
                let bottomWhite = CIImage(color: .white).cropped(to: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height / 2))
                let topGrad = g.cropped(to: CGRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2))
                mask = bottomWhite.composited(over: topGrad.composited(over: CIImage(color: .black).cropped(to: CGRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2)))).cropped(to: rect)
            case .bottom:
                let topWhite = CIImage(color: .white).cropped(to: CGRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2))
                let bottomGrad = g.cropped(to: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height / 2))
                mask = topWhite.composited(over: bottomGrad.composited(over: CIImage(color: .black).cropped(to: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height / 2)))).cropped(to: rect)
            }

            let blend = CIFilter.blendWithMask()
            blend.inputImage = inputCI
            blend.backgroundImage = dark
            blend.maskImage = mask
            outputCI = blend.outputImage ?? inputCI
        }

        return context.createCGImage(outputCI, from: inputCI.extent) ?? image
    }
}

