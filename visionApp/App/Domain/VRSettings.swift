//
//  VRSettings.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 11/9/25.
//

// MARK: - VR Settings
struct VRSettings: Equatable, Codable {
    /// Distancia interpupilar en píxeles (convertida de mm)
    public var interpupillaryDistancePixels: Double
    /// Factor de distorsión barrel para lentes Cardboard
    public var barrelDistortionFactor: Double
    /// Escala de zoom para compensar la distorsión
    public var distortionZoomFactor: Double
    
    public init(
        interpupillaryDistancePixels: Double = 32.0, // ~63mm en mundo real
        barrelDistortionFactor: Double = 0.2,
        distortionZoomFactor: Double = 1.1
    ) {
        self.interpupillaryDistancePixels = interpupillaryDistancePixels
        self.barrelDistortionFactor = barrelDistortionFactor
        self.distortionZoomFactor = distortionZoomFactor
    }
    
    public static var defaults: VRSettings { VRSettings() }
}
