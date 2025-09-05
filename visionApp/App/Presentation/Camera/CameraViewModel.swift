//
//  CameraViewModel.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//

import Foundation
import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    @Published var currentFrame: CGImage?
    @Published var error: CameraError?
    
    let cameraService = CameraService() // Cambiado de private a internal
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func startSession() {
        cameraService.startSession()
    }
    
    func stopSession() {
        cameraService.stopSession()
    }
}
