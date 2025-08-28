// filepath: /Users/robertorojosahuquillo/Desktop/visionApp/visionApp/App/Extensions/CIConfig.swift
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

    private init() {}
}