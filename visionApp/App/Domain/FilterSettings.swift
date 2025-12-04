//
//  FilterSettings.swift
//  visionApp
//
//  Settings structures for each illness filter type
//

import Foundation
import CoreGraphics

// MARK: - Cataracts Settings
struct CataractsSettings: Codable, Equatable {
    var blurRadius: Double
    var cloudiness: Double
    var brightness: Double
    var saturationReduction: Double
    var contrastReduction: Double
    var blueReduction: Double
    
    static let defaults = CataractsSettings(
        blurRadius: 10.0,
        cloudiness: 0.3,
        brightness: 0.8,
        saturationReduction: 0.3,
        contrastReduction: 0.2,
        blueReduction: 0.2
    )
}

// MARK: - Glaucoma Settings
struct GlaucomaSettings: Codable, Equatable {
    var tunnelRadius: Double
    var vignetteFalloff: Double
    var contrast: Double
    var vignetteIntensity: Double
    var vignetteRadiusFactor: Double
    var effectRadiusFactor: Double
    
    static let defaults = GlaucomaSettings(
        tunnelRadius: 0.3,
        vignetteFalloff: 0.8,
        contrast: 1.2,
        vignetteIntensity: 0.8,
        vignetteRadiusFactor: 0.5,
        effectRadiusFactor: 0.3
    )
}

// MARK: - Macular Degeneration Settings
struct MacularDegenerationSettings: Codable, Equatable {
    var centralBlurRadius: Double
    var distortionAmount: Double
    var centralDarkness: Double
    var blurRadius: Double
    var darkAlpha: Double
    var twirlAngle: Double
    var innerRadius: Double
    var outerRadiusFactor: Double
    
    static let defaults = MacularDegenerationSettings(
        centralBlurRadius: 15.0,
        distortionAmount: 0.4,
        centralDarkness: 0.5,
        blurRadius: 15.0,
        darkAlpha: 0.5,
        twirlAngle: 0.4,
        innerRadius: 0.1,
        outerRadiusFactor: 0.3
    )
}

// MARK: - Tunnel Vision Settings
struct TunnelVisionSettings: Codable, Equatable {
    var tunnelRadius: Double
    var edgeSoftness: Double
    var darknessLevel: Double
    var blurRadius: Double
    var maxRadiusFactor: Double
    var featherFactorBase: Double
    var minRadiusPercent: Double
    
    static let defaults = TunnelVisionSettings(
        tunnelRadius: 0.25,
        edgeSoftness: 0.5,
        darknessLevel: 0.9,
        blurRadius: 10.0,
        maxRadiusFactor: 0.25,
        featherFactorBase: 0.5,
        minRadiusPercent: 0.1
    )
}

// MARK: - Blurry Vision Settings
struct BlurryVisionSettings: Codable, Equatable {
    var blurAmount: Double
    var clarity: Double
    
    static let defaults = BlurryVisionSettings(
        blurAmount: 8.0,
        clarity: 0.7
    )
}

// MARK: - Central Scotoma Settings
struct CentralScotomaSettings: Codable, Equatable {
    var scotomaRadius: Double
    var darkness: Double
    var edgeBlur: Double
    
    static let defaults = CentralScotomaSettings(
        scotomaRadius: 0.15,
        darkness: 0.8,
        edgeBlur: 20.0
    )
}

// MARK: - Hemianopsia Settings
struct HemianopsiaSettings: Codable, Equatable {
    var side: HemianopsiaSide
    var transitionSoftness: Double
    var darkness: Double
    var leftSideAffected: Bool
    var featherFactor: Double
    
    static let defaults = HemianopsiaSettings(
        side: .left,
        transitionSoftness: 0.3,
        darkness: 0.95,
        leftSideAffected: true,
        featherFactor: 0.3
    )
}

enum HemianopsiaSide: String, Codable, CaseIterable {
    case left
    case right
    case top
    case bottom
}

// MARK: - Combined Symptoms Settings
struct CombinedSymptomsSettings: Codable, Equatable {
    var photophobia: Double // Light sensitivity
    var floaters: Double // Eye floaters intensity
    var halos: Double // Light halos around objects
    
    static let defaults = CombinedSymptomsSettings(
        photophobia: 0.0,
        floaters: 0.0,
        halos: 0.0
    )
}
