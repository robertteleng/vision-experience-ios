//
//  FilterSettings.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 7/9/25.
//

import Foundation
import CoreGraphics

// MARK: - Ajustes específicos por filtro

public struct CataractsSettings: Equatable, Codable {
    // Desenfoque gaussiano (px)
    public var blurRadius: Double
    // Reducción de contraste (0 = sin cambio, 1 = contraste 0)
    public var contrastReduction: Double
    // Reducción de saturación (0 = sin cambio, 1 = saturación 0)
    public var saturationReduction: Double
    // Reducción del canal azul para simular tinte amarillento (0..1)
    public var blueReduction: Double

    public init(
        blurRadius: Double = 12.0,
        contrastReduction: Double = 0.25,
        saturationReduction: Double = 0.2,
        blueReduction: Double = 0.15
    ) {
        self.blurRadius = blurRadius
        self.contrastReduction = contrastReduction
        self.saturationReduction = saturationReduction
        self.blueReduction = blueReduction
    }

    public static var `defaults`: CataractsSettings { CataractsSettings() }
}

public struct GlaucomaSettings: Equatable, Codable {
    // Intensidad del viñeteado base (CIFilter.vignette.intensity)
    public var vignetteIntensity: Double
    // Factor del radio del viñeteado base (CIFilter.vignette.radius)
    public var vignetteRadiusFactor: Double
    // Factor del radio del efecto de viñeteado centrado (relativo al lado mínimo)
    public var effectRadiusFactor: Double

    public init(
        vignetteIntensity: Double = 1.0,
        vignetteRadiusFactor: Double = 1.0,
        effectRadiusFactor: Double = 1.0
    ) {
        self.vignetteIntensity = vignetteIntensity
        self.vignetteRadiusFactor = vignetteRadiusFactor
        self.effectRadiusFactor = effectRadiusFactor
    }

    public static var `defaults`: GlaucomaSettings { GlaucomaSettings() }
}

public struct MacularDegenerationSettings: Equatable, Codable {
    // Radio interno del área central afectada (px)
    public var innerRadius: Double
    // Factor del radio externo relativo al lado mínimo (0..1)
    public var outerRadiusFactor: Double
    // Desenfoque aplicado a la imagen (px)
    public var blurRadius: Double
    // Opacidad de oscurecimiento (0..1)
    public var darkAlpha: Double
    // Ángulo de distorsión (radianes)
    public var twirlAngle: Double

    public init(
        innerRadius: Double = 40.0,
        outerRadiusFactor: Double = 0.35,
        blurRadius: Double = 3.0,
        darkAlpha: Double = 0.65,
        twirlAngle: Double = .pi * 0.5
    ) {
        self.innerRadius = innerRadius
        self.outerRadiusFactor = outerRadiusFactor
        self.blurRadius = blurRadius
        self.darkAlpha = darkAlpha
        self.twirlAngle = twirlAngle
    }

    public static var `defaults`: MacularDegenerationSettings { MacularDegenerationSettings() }
}

public struct TunnelVisionSettings: Equatable, Codable {
    // Porcentaje del lado mínimo para el radio mínimo del túnel (0..1)
    public var minRadiusPercent: Double
    // Factor del lado mínimo para el radio máximo del túnel
    public var maxRadiusFactor: Double
    // Desenfoque periférico (px)
    public var blurRadius: Double
    // Factor base para el feather (suavizado del borde)
    public var featherFactorBase: Double

    public init(
        minRadiusPercent: Double = 0.05,
        maxRadiusFactor: Double = 0.62,
        blurRadius: Double = 10.0,
        featherFactorBase: Double = 0.12
    ) {
        self.minRadiusPercent = minRadiusPercent
        self.maxRadiusFactor = maxRadiusFactor
        self.blurRadius = blurRadius
        self.featherFactorBase = featherFactorBase
    }

    public static var `defaults`: TunnelVisionSettings { TunnelVisionSettings() }
}

// NUEVO: Visión borrosa simple
public struct BlurryVisionSettings: Equatable, Codable {
    public var blurRadius: Double

    public init(blurRadius: Double = 8.0) {
        self.blurRadius = blurRadius
    }

    public static var `defaults`: BlurryVisionSettings { BlurryVisionSettings() }
}

// NUEVO: Escotoma central
public struct CentralScotomaSettings: Equatable, Codable {
    // Radio interno (opaco) del escotoma en px
    public var innerRadius: Double
    // Feather (transición suave) en px
    public var feather: Double
    // Opacidad del oscurecimiento en el escotoma (0..1)
    public var opacity: Double
    // Offset normalizado del centro del escotoma relativo a la imagen
    public var offsetNormalizedX: Double
    public var offsetNormalizedY: Double

    public init(
        innerRadius: Double = 60.0,
        feather: Double = 80.0,
        opacity: Double = 1.0,
        offsetNormalizedX: Double = 0.0,
        offsetNormalizedY: Double = 0.0
    ) {
        self.innerRadius = innerRadius
        self.feather = feather
        self.opacity = opacity
        self.offsetNormalizedX = offsetNormalizedX
        self.offsetNormalizedY = offsetNormalizedY
    }

    public static var `defaults`: CentralScotomaSettings { CentralScotomaSettings() }
}

// NUEVO: Hemianopsia
public enum HemianopsiaSide: String, Codable, CaseIterable {
    case left, right, top, bottom
}

public struct HemianopsiaSettings: Equatable, Codable {
    public var side: HemianopsiaSide
    public var feather: Double
    public var opacity: Double

    public init(
        side: HemianopsiaSide = .left,
        feather: Double = 40.0,
        opacity: Double = 1.0
    ) {
        self.side = side
        self.feather = feather
        self.opacity = opacity
    }

    public static var `defaults`: HemianopsiaSettings { HemianopsiaSettings() }
}

// NUEVO: Síntomas combinables (post-proceso global)
public struct CombinedSymptomsSettings: Equatable, Codable {
    // Bloom/Glare
    public var bloomIntensity: Double         // 0..1
    public var bloomRadiusFactor: Double      // proporción del lado mínimo (0..0.1 recomendado)
    // Controles globales
    public var globalContrast: Double         // 0.5..1.5
    public var globalSaturation: Double       // 0..1.5
    // Velo/luz difusa global
    public var veilOpacity: Double            // 0..0.4 recomendado

    public init(
        bloomIntensity: Double = 0.35,
        bloomRadiusFactor: Double = 0.02,
        globalContrast: Double = 1.0,
        globalSaturation: Double = 1.0,
        veilOpacity: Double = 0.0
    ) {
        self.bloomIntensity = bloomIntensity
        self.bloomRadiusFactor = bloomRadiusFactor
        self.globalContrast = globalContrast
        self.globalSaturation = globalSaturation
        self.veilOpacity = veilOpacity
    }

    public static var `defaults`: CombinedSymptomsSettings { CombinedSymptomsSettings() }
}

// MARK: - Wrapper de ajustes por tipo de enfermedad

public enum IllnessSettings: Equatable, Codable {
    case cataracts(CataractsSettings)
    case glaucoma(GlaucomaSettings)
    case macular(MacularDegenerationSettings)
    case tunnel(TunnelVisionSettings)

    // Nuevos casos
    case blurryVision(BlurryVisionSettings)
    case centralScotoma(CentralScotomaSettings)
    case hemianopsia(HemianopsiaSettings)
}

