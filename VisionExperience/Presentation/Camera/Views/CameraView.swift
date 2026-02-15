//
//  CameraView.swift
//  VisionExperience
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
    @State private var showVRSettings = false

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
                            deviceOrientation: orientationObserver.orientation,
                            vrSettings: globalViewModel.vrSettings
                        )
                        .ignoresSafeArea()
                        .allowsHitTesting(false) // La imagen no captura toques
                        .zIndex(0)

                        // Floating menu overlay (respeta safe area)
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded)
                                .padding(.leading, 16)
                                .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .zIndex(100)
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
                            illnessSettings: globalViewModel.currentIllnessSettings,
                            vrSettings: globalViewModel.vrSettings
                        )
                        .ignoresSafeArea()
                        .allowsHitTesting(false) // La imagen no captura toques
                        .zIndex(0)

                        // Floating menu overlay (respeta safe area)
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded)
                                .padding(.leading, 16)
                                .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .zIndex(100)
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
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Button(action: { showVRSettings = true }) {
                Image(systemName: "gauge")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
            }
            .padding()
        }
        .sheet(isPresented: $showVRSettings) {
            NavigationView {
                Form {
                    Section(header: Text("Distancia interpupilar (px)")) {
                        let binding = Binding<Double>(
                            get: { globalViewModel.vrSettings.interpupillaryDistancePixels },
                            set: { newValue in
                                var s = globalViewModel.vrSettings
                                s.interpupillaryDistancePixels = newValue
                                globalViewModel.vrSettings = s
                            }
                        )
                        Slider(value: binding, in: 0...300, step: 1) {
                            Text("IPD")
                        }
                        HStack {
                            Text("Actual: ")
                            Spacer()
                            Text("\(Int(globalViewModel.vrSettings.interpupillaryDistancePixels)) px")
                                .monospacedDigit()
                        }
                    }
                    Section(header: Text("Distorsión de lente (barrel)"), footer: Text("0.0 = sin distorsión; negativo = barrel; positivo = pincushion")) {
                        let binding = Binding<Double>(
                            get: { globalViewModel.vrSettings.barrelDistortionFactor },
                            set: { newValue in
                                var s = globalViewModel.vrSettings
                                s.barrelDistortionFactor = newValue
                                globalViewModel.vrSettings = s
                            }
                        )
                        Slider(value: binding, in: -1.0...1.0, step: 0.01) {
                            Text("Factor")
                        }
                        HStack {
                            Text("Actual:")
                            Spacer()
                            Text(String(format: "%.2f", globalViewModel.vrSettings.barrelDistortionFactor))
                                .monospacedDigit()
                        }
                    }
                    Section(header: Text("Zoom de compensación"), footer: Text("1.0 = sin zoom; >1 recorta bordes tras distorsión")) {
                        let binding = Binding<Double>(
                            get: { globalViewModel.vrSettings.distortionZoomFactor },
                            set: { newValue in
                                var s = globalViewModel.vrSettings
                                s.distortionZoomFactor = newValue
                                globalViewModel.vrSettings = s
                            }
                        )
                        Slider(value: binding, in: 0.9...1.3, step: 0.005) {
                            Text("Zoom")
                        }
                        HStack {
                            Text("Actual:")
                            Spacer()
                            Text(String(format: "%.3f", globalViewModel.vrSettings.distortionZoomFactor))
                                .monospacedDigit()
                        }
                    }
                }
                .navigationTitle("Ajustes VR")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cerrar") { showVRSettings = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Reset") { globalViewModel.vrSettings = .defaults }
                    }
                }
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

