// filepath: /Users/robertorojosahuquillo/Desktop/VisionExperience/VisionExperience/App/Extensions/CIConfig.swift
import Foundation

// Global Core Image tuning parameters used by CIProcessor
final class CIConfig {
    static let shared = CIConfig()

    // Cataracts
    var cataractsBloomIntensityBase: Double = 0.2
    var cataractsBloomIntensityScale: Double = 0.6
    var cataractsBloomRadiusBase: Double = 5.0
    var cataractsBloomRadiusScale: Double = 25.0
    var cataractsDesaturationMax: Double = 0.3   // maximum amount to subtract from saturation
    var cataractsContrastDropMax: Double = 0.05  // maximum amount to subtract from contrast

    // Diabetic Retinopathy
    var drSpeckleOpacityMax: Double = 0.20       // max alpha for speckle overlay
    var drVignetteIntensityBase: Double = 0.4
    var drVignetteIntensityScale: Double = 0.8
    var drVignetteRadiusBase: Double = 1.5
    var drVignetteRadiusScale: Double = 1.5

    // Deuteranopia (Color Blindness)
    var deuteranopiaStrengthMax: Double = 1.0    // max blend strength of matrix effect

    // Astigmatism
    var astigMotionRadiusBase: Double = 6.0
    var astigMotionRadiusScale: Double = 20.0
    var astigGhostAlphaBase: Double = 0.25
    var astigGhostAlphaScale: Double = 0.25
    var astigAngleDegrees: Double = 30.0

    // Glaucoma (peripheral vignette)
    var glauStartRadiusScale: Double = 60.0
    var glauEndRadiusExtra: Double = 40.0
    var glauEndRadiusScale: Double = 260.0
    var glauEdgeAlphaMax: Double = 1.0

    // Macular Degeneration (central spot + blur)
    var mdSpotRadiusMin: Double = 20.0
    var mdSpotRadiusScale: Double = 220.0
    var mdSpotColorAlpha: Double = 0.7
    var mdSpotInnerFactor: Double = 0.4
    var mdBlurBase: Double = 6.0
    var mdBlurScale: Double = 8.0
    var mdMaskInnerFactor: Double = 0.2

    private init() {}
}
