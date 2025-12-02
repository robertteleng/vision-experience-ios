//  CardboardView.swift
//  visionApp
//
//  This file defines the CardboardView, a SwiftUI view for simulating a stereoscopic
//  (cardboard) experience by rendering left and right panels side by side. Each panel
//  displays a processed camera image, optionally filtered by illness and central focus.
//  The view adapts to device orientation and provides fallback text if no frame is available.

import SwiftUI
import AVFoundation
//import App.Presentation.Components.Panel // Import shared Panel enum

/// CardboardView renders left and right camera panels for a stereoscopic effect.
/// - Uses CameraImageView for each panel, applying illness and focus filters.
/// - Adapts to device orientation and geometry.
/// - Displays fallback text if no camera frame is available.
struct CardboardView: View {
    /// The camera service providing frames.
    @ObservedObject var cameraService: CameraService
    /// The selected illness for image processing.
    let illness: Illness?
    /// The central focus value for processing.
    let centralFocus: Double
<<<<<<< HEAD
    /// The current device orientation.
=======
    let filterEnabled: Bool
    let illnessSettings: IllnessSettings?
>>>>>>> illness-filters-temp
    @State var deviceOrientation: UIDeviceOrientation
    let vrSettings: VRSettings
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) { // Cambiar spacing a 0
                // Panel izquierdo
                ZStack {
                    CameraImageView(
                        image: cameraService.currentFrame,
                        panel: .left,
                        illness: illness,
<<<<<<< HEAD
                        centralFocus: centralFocus
                    )
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                    .ignoresSafeArea()
=======
                        centralFocus: centralFocus,
                        filterEnabled: filterEnabled,
                        illnessSettings: illnessSettings,
                        vrSettings: vrSettings
                    )
                    
>>>>>>> illness-filters-temp
                    if cameraService.currentFrame == nil {
                        Text("No frame LEFT")
                            .foregroundColor(.white)
                            .background(Color.red)
                    }
                }
                .frame(width: geometry.size.width / 2, height: geometry.size.height)
                
                // Panel derecho
                ZStack {
                    CameraImageView(
                        image: cameraService.currentFrame,
                        panel: .right,
                        illness: illness,
<<<<<<< HEAD
                        centralFocus: centralFocus
                    )
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                    .ignoresSafeArea()
=======
                        centralFocus: centralFocus,
                        filterEnabled: filterEnabled,
                        illnessSettings: illnessSettings,
                        vrSettings: vrSettings
                    )
                    
>>>>>>> illness-filters-temp
                    if cameraService.currentFrame == nil {
                        Text("No frame RIGHT")
                            .foregroundColor(.white)
                            .background(Color.blue)
                    }
                }
                .frame(width: geometry.size.width / 2, height: geometry.size.height)
            }
        }
        .ignoresSafeArea(.all) // Ignorar TODAS las safe areas
        .statusBar(hidden: true) // Ocultar la barra de estado si es necesario
    }
}


//// Cataracts preview
//#Preview {
//    CardboardView(
//        cameraService: CameraViewModel().cameraService,
//        illness: Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts),
//        centralFocus: 0.5,
//        filterEnabled: true,
//        illnessSettings: .cataracts(.defaults),
//        deviceOrientation: .portrait,
//        vrSettings: .defaults
//    )
//}

