//
//  FilterSettings.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 7/9/25.
//

import Foundation
import CoreGraphics

// MARK: - Filter-specific settings

public struct CataractsSettings: Equatable, Codable {
    // Gaussian blur radius (in pixels)
    public var blurRadius: Double
    // Contrast reduction (0 = no change, 1 = full contrast removal)
    public var contrastReduction: Double
    // Saturation reduction (0 = no change, 1 = full desaturation)
    public var saturationReduction: Double
    // Blue channel reduction to simulate yellowish tint (0..1)
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
    // Base vignette intensity (CIFilter.vignette.intensity)
    public var vignetteIntensity: Double
    // Base vignette radius factor (CIFilter.vignette.radius)
    public var vignetteRadiusFactor: Double
    // Effect radius factor for centered vignette (relative to the shorter image side)
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
    // Inner radius of the affected central area (in pixels)
    public var innerRadius: Double
    // Outer radius factor relative to the shorter image side (0..1)
    public var outerRadiusFactor: Double
    // Applied blur radius (in pixels)
    public var blurRadius: Double
    // Darkness opacity (0..1)
    public var darkAlpha: Double
    // Distortion angle (in radians)
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
    // Minimum tunnel radius as a percentage of the shorter image side (0..1)
    public var minRadiusPercent: Double
    // Maximum tunnel radius factor relative to the shorter image side
    public var maxRadiusFactor: Double
    // Peripheral blur radius (in pixels)
    public var blurRadius: Double
    // Base feather factor for edge smoothing
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

public struct HemianopsiaSettings: Equatable, Codable {
    // Lado afectado: true = izquierda, false = derecha
    public var leftSideAffected: Bool
    // Suavizado del borde (0 = borde duro, 1 = transición suave)
    public var featherFactor: Double

    public init(
        leftSideAffected: Bool = true,
        featherFactor: Double = 0.15
    ) {
        self.leftSideAffected = leftSideAffected
        self.featherFactor = featherFactor
    }

    public static var `defaults`: HemianopsiaSettings { HemianopsiaSettings() }
}
