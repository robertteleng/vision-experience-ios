//
//  CameraView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file defines the CameraView, the main camera interface for the app. It manages
//  the display of camera frames, overlays, and the floating menu.
//  The view adapts to device orientation and Cardboard mode, and provides interactive
//  controls for navigation.

import SwiftUI

/// CameraView is the main camera interface for the app.
/// - Displays camera frames and overlays for illness simulation.
/// - Adapts to device orientation and Cardboard mode.
/// - Provides interactive controls for navigation.
struct CameraView: View {
    /// Provides access to the main application state and selected illness.
    @EnvironmentObject var globalViewModel: MainViewModel
    /// Manages camera session and frame updates.
    @StateObject private var cameraViewModel = CameraViewModel()
    /// Controls whether the floating menu is expanded.
    @State private var menuExpanded = false
    /// Observes device orientation changes to adapt the UI.
    @EnvironmentObject var orientationObserver: DeviceOrientationObserver
    /// Indicates whether Cardboard mode is active (stereoscopic view).
    @Binding var isCardboardMode: Bool
    /// Handles navigation between screens.
    @EnvironmentObject var router: AppRouter

    var body: some View {
        ZStack {
            // Determine if the device is in landscape orientation.
            let isLandscape = orientationObserver.orientation.isLandscape
            if isLandscape {
                // Cardboard mode: render stereoscopic left/right panels.
                if isCardboardMode {
                    ZStack {
                        // Capa de imagen con efecto estereoscópico
                        CardboardView(
                            cameraService: cameraViewModel.cameraService,
                            illness: globalViewModel.selectedIllness,
                            centralFocus: globalViewModel.centralFocus,
                            filterEnabled: globalViewModel.filterEnabled,
                            illnessSettings: globalViewModel.currentIllnessSettings,
                            deviceOrientation: orientationObserver.orientation
                        )
                        .ignoresSafeArea() // solo la imagen ignora safe area

                        // Floating menu overlay (respeta safe area)
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded)
                                .padding(.leading, 16)
                                .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .zIndex(2)
                    }
                } else {
                    // Standard camera view (single panel).
                    ZStack {
                        // Capa de imagen con filtros (rotación corregida en CameraImageView)
                        CameraImageView(
                            image: cameraViewModel.cameraService.currentFrame,
                            panel: .full,
                            illness: globalViewModel.selectedIllness,
                            centralFocus: globalViewModel.centralFocus,
                            filterEnabled: globalViewModel.filterEnabled,
                            illnessSettings: globalViewModel.currentIllnessSettings
                        )
                        .ignoresSafeArea() // solo la imagen ignora safe area

                        // Floating menu overlay (respeta safe area)
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded)
                                .padding(.leading, 16)
                                .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .zIndex(2)
                    }
                }
            } else {
                // Portrait mode: prompt user to rotate device for camera experience.
                VStack {
                    Spacer()
                    Image(systemName: "iphone.landscape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    Text("Please rotate your device")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                    Button(action: {
                        // Removed UIKit feedback, use SwiftUI haptics
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                        router.currentRoute = .illnessList
                    }) {
                        Image(systemName: "chevron.left.circle")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.blue)
                            .opacity(0.85)
                            .padding()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.ignoresSafeArea())
            }
        }
        // Start camera session when view appears.
        .onAppear {
            cameraViewModel.startSession()
        }
        // Stop camera session when view disappears.
        .onDisappear { 
            cameraViewModel.stopSession() 
        }
    }
}

//#Preview {
//    CameraView(isCardboardMode: .constant(false))
//        .environmentObject(MainViewModel())
//        .environmentObject(AppRouter())
//        .environmentObject(DeviceOrientationObserver.shared)
//}
//
