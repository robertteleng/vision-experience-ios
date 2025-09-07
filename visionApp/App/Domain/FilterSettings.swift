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

// MARK: - Wrapper de ajustes por tipo de enfermedad

public enum IllnessSettings: Equatable, Codable {
    case cataracts(CataractsSettings)
    case glaucoma(GlaucomaSettings)
    case macular(MacularDegenerationSettings)
    case tunnel(TunnelVisionSettings)
}

