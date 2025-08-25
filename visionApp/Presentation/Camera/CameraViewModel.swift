import Foundation
import SwiftUI

class CameraViewModel: ObservableObject {
    @Published var currentFrame: UIImage?
    @Published var error: CameraService.CameraError?
    
    let cameraService = CameraService() // Cambiado de private a internal
    
    init() {
        cameraService.$currentFrame
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentFrame)
        cameraService.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
    }
    
    func startSession() {
        cameraService.startSession()
    }
    
    func stopSession() {
        cameraService.stopSession()
    }
}
