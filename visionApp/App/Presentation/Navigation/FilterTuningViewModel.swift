// filepath: /Users/robertorojosahuquillo/Desktop/visionApp/visionApp/App/Presentation/Navigation/FilterTuningViewModel.swift
import Foundation
import Combine

final class FilterTuningViewModel: ObservableObject {
    // Cataracts
    @Published var cataractsBloomIntensityBase: Double = CIConfig.shared.cataractsBloomIntensityBase {
        didSet { CIConfig.shared.cataractsBloomIntensityBase = cataractsBloomIntensityBase }
    }
    @Published var cataractsBloomIntensityScale: Double = CIConfig.shared.cataractsBloomIntensityScale {
        didSet { CIConfig.shared.cataractsBloomIntensityScale = cataractsBloomIntensityScale }
    }
    @Published var cataractsBloomRadiusBase: Double = CIConfig.shared.cataractsBloomRadiusBase {
        didSet { CIConfig.shared.cataractsBloomRadiusBase = cataractsBloomRadiusBase }
    }
    @Published var cataractsBloomRadiusScale: Double = CIConfig.shared.cataractsBloomRadiusScale {
        didSet { CIConfig.shared.cataractsBloomRadiusScale = cataractsBloomRadiusScale }
    }
    @Published var cataractsDesaturationMax: Double = CIConfig.shared.cataractsDesaturationMax {
        didSet { CIConfig.shared.cataractsDesaturationMax = cataractsDesaturationMax }
    }
    @Published var cataractsContrastDropMax: Double = CIConfig.shared.cataractsContrastDropMax {
        didSet { CIConfig.shared.cataractsContrastDropMax = cataractsContrastDropMax }
    }

    // Diabetic Retinopathy
    @Published var drSpeckleOpacityMax: Double = CIConfig.shared.drSpeckleOpacityMax {
        didSet { CIConfig.shared.drSpeckleOpacityMax = drSpeckleOpacityMax }
    }
    @Published var drVignetteIntensityBase: Double = CIConfig.shared.drVignetteIntensityBase {
        didSet { CIConfig.shared.drVignetteIntensityBase = drVignetteIntensityBase }
    }
    @Published var drVignetteIntensityScale: Double = CIConfig.shared.drVignetteIntensityScale {
        didSet { CIConfig.shared.drVignetteIntensityScale = drVignetteIntensityScale }
    }
    @Published var drVignetteRadiusBase: Double = CIConfig.shared.drVignetteRadiusBase {
        didSet { CIConfig.shared.drVignetteRadiusBase = drVignetteRadiusBase }
    }
    @Published var drVignetteRadiusScale: Double = CIConfig.shared.drVignetteRadiusScale {
        didSet { CIConfig.shared.drVignetteRadiusScale = drVignetteRadiusScale }
    }

    // Deuteranopia
    @Published var deuteranopiaStrengthMax: Double = CIConfig.shared.deuteranopiaStrengthMax {
        didSet { CIConfig.shared.deuteranopiaStrengthMax = deuteranopiaStrengthMax }
    }

    // Astigmatism
    @Published var astigMotionRadiusBase: Double = CIConfig.shared.astigMotionRadiusBase {
        didSet { CIConfig.shared.astigMotionRadiusBase = astigMotionRadiusBase }
    }
    @Published var astigMotionRadiusScale: Double = CIConfig.shared.astigMotionRadiusScale {
        didSet { CIConfig.shared.astigMotionRadiusScale = astigMotionRadiusScale }
    }
    @Published var astigGhostAlphaBase: Double = CIConfig.shared.astigGhostAlphaBase {
        didSet { CIConfig.shared.astigGhostAlphaBase = astigGhostAlphaBase }
    }
    @Published var astigGhostAlphaScale: Double = CIConfig.shared.astigGhostAlphaScale {
        didSet { CIConfig.shared.astigGhostAlphaScale = astigGhostAlphaScale }
    }
    @Published var astigAngleDegrees: Double = CIConfig.shared.astigAngleDegrees {
        didSet { CIConfig.shared.astigAngleDegrees = astigAngleDegrees }
    }

    // Glaucoma
    @Published var glauStartRadiusScale: Double = CIConfig.shared.glauStartRadiusScale {
        didSet { CIConfig.shared.glauStartRadiusScale = glauStartRadiusScale }
    }
    @Published var glauEndRadiusExtra: Double = CIConfig.shared.glauEndRadiusExtra {
        didSet { CIConfig.shared.glauEndRadiusExtra = glauEndRadiusExtra }
    }
    @Published var glauEndRadiusScale: Double = CIConfig.shared.glauEndRadiusScale {
        didSet { CIConfig.shared.glauEndRadiusScale = glauEndRadiusScale }
    }
    @Published var glauEdgeAlphaMax: Double = CIConfig.shared.glauEdgeAlphaMax {
        didSet { CIConfig.shared.glauEdgeAlphaMax = glauEdgeAlphaMax }
    }

    // Macular Degeneration
    @Published var mdSpotRadiusMin: Double = CIConfig.shared.mdSpotRadiusMin {
        didSet { CIConfig.shared.mdSpotRadiusMin = mdSpotRadiusMin }
    }
    @Published var mdSpotRadiusScale: Double = CIConfig.shared.mdSpotRadiusScale {
        didSet { CIConfig.shared.mdSpotRadiusScale = mdSpotRadiusScale }
    }
    @Published var mdSpotColorAlpha: Double = CIConfig.shared.mdSpotColorAlpha {
        didSet { CIConfig.shared.mdSpotColorAlpha = mdSpotColorAlpha }
    }
    @Published var mdSpotInnerFactor: Double = CIConfig.shared.mdSpotInnerFactor {
        didSet { CIConfig.shared.mdSpotInnerFactor = mdSpotInnerFactor }
    }
    @Published var mdBlurBase: Double = CIConfig.shared.mdBlurBase {
        didSet { CIConfig.shared.mdBlurBase = mdBlurBase }
    }
    @Published var mdBlurScale: Double = CIConfig.shared.mdBlurScale {
        didSet { CIConfig.shared.mdBlurScale = mdBlurScale }
    }
    @Published var mdMaskInnerFactor: Double = CIConfig.shared.mdMaskInnerFactor {
        didSet { CIConfig.shared.mdMaskInnerFactor = mdMaskInnerFactor }
    }

    func resetCataracts() {
        cataractsBloomIntensityBase = 0.2
        cataractsBloomIntensityScale = 0.6
        cataractsBloomRadiusBase = 5.0
        cataractsBloomRadiusScale = 25.0
        cataractsDesaturationMax = 0.3
        cataractsContrastDropMax = 0.05
    }

    func resetRetinopathy() {
        drSpeckleOpacityMax = 0.20
        drVignetteIntensityBase = 0.4
        drVignetteIntensityScale = 0.8
        drVignetteRadiusBase = 1.5
        drVignetteRadiusScale = 1.5
    }

    func resetDeuteranopia() {
        deuteranopiaStrengthMax = 1.0
    }

    func resetAstigmatism() {
        astigMotionRadiusBase = 6.0
        astigMotionRadiusScale = 20.0
        astigGhostAlphaBase = 0.25
        astigGhostAlphaScale = 0.25
        astigAngleDegrees = 30.0
    }

    func resetGlaucoma() {
        glauStartRadiusScale = 60.0
        glauEndRadiusExtra = 40.0
        glauEndRadiusScale = 260.0
        glauEdgeAlphaMax = 1.0
    }

    func resetMacular() {
        mdSpotRadiusMin = 20.0
        mdSpotRadiusScale = 220.0
        mdSpotColorAlpha = 0.7
        mdSpotInnerFactor = 0.4
        mdBlurBase = 6.0
        mdBlurScale = 8.0
        mdMaskInnerFactor = 0.2
    }
}
