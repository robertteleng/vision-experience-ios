//
//  CameraViewModel.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//
//  This file defines the CameraViewModel class, which acts as the bridge between
//  the camera service and SwiftUI views. It manages the camera session lifecycle,
//  exposes the current frame and error state, and synchronizes updates to the UI.

import Foundation
import SwiftUI
import Combine

/// CameraViewModel is an observable object that manages camera session state and data.
/// - Publishes the current camera frame and error state for UI updates.
/// - Provides methods to start and stop the camera session.
class CameraViewModel: ObservableObject {
    /// The latest frame captured by the camera.
    @Published var currentFrame: CGImage?
    /// The latest error encountered by the camera service.
    @Published var error: CameraError?
    /// The camera service instance used for capturing frames and managing the session.
    let cameraService = CameraService() // Internal for testing and access
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the view model and sets up bindings to the camera service's publishers.
    init() {
        cameraService.$currentFrame
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentFrame, on: self)
            .store(in: &cancellables)
        
        cameraService.$error
            .receive(on: DispatchQueue.main)
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }

    /// Starts the camera session.
    func startSession() {
        cameraService.startSession()
    }

    /// Stops the camera session.
    func stopSession() {
        cameraService.stopSession()
    }
}
