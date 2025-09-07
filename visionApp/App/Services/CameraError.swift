//
//  CameraError.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 3/9/25.
//
import Foundation

// Camera permission status
enum CameraError: Error, LocalizedError {
    case authorizationDenied
    case configurationFailed
    case deviceUnavailable
    case unknown

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Camera access was denied. Please enable it in settings."
        case .configurationFailed:
            return "Failed to configure the camera."
        case .deviceUnavailable:
            return "No camera device is available."
        case .unknown:
            return "Unknown camera error."
        }
    }
}
