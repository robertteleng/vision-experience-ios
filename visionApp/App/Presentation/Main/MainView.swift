//  MainView.swift
//  visionApp
//
//  This file defines the main view of the application, responsible for rendering
//  the primary navigation and handling state transitions between splash, illness list,
//  and camera screens. It also manages overlays and device orientation changes for
//  features such as Cardboard mode and speech recognition.

import SwiftUI
import AVFoundation
import Speech

/// MainView is the root view for navigation and state management.
/// - Handles navigation between splash, illness list, and camera screens.
/// - Manages overlays for Cardboard mode and device orientation changes.
struct MainView: View {
    /// Router for navigation state.
    @EnvironmentObject var router: AppRouter
    /// Main view model for app state and logic.
    @EnvironmentObject var mainViewModel: MainViewModel
    /// Observer for device orientation changes.
    @EnvironmentObject var orientationObserver: DeviceOrientationObserver

    var body: some View {
        NavigationView {
            ZStack {
                // Renders the screen based on the current navigation route.
                switch router.currentRoute {
                case .splash:
                    SplashView() // Splash screen
                case .illnessList:
                    IllnessListView() // List of illnesses
                case .camera:
                    CameraView(isCardboardMode: $mainViewModel.isCardboardMode) // Camera screen
                case .home:
                    HomeView() // Home screen
                case .immersiveVideo:
                    ImmersiveVideoView() // 360º video with spatial audio
                }
            }
            // Overlay for Cardboard mode button, only on illness list screen.
            .overlay(alignment: .bottomTrailing) {
                if router.currentRoute == .illnessList {
                    Button(action: {
                        mainViewModel.isCardboardMode.toggle()
                    }) {
                        Image(systemName: "eyeglasses")
                            .resizable()
                            .frame(width: 24, height: 16)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(mainViewModel.isCardboardMode ? 1.0 : 0.3))
                            )
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Solicitar permisos una sola vez
            mainViewModel.speechService.requestAuthorization { _ in
                // Opcional: iniciar en función del estado actual
                if self.mainViewModel.isCardboardMode && self.orientationObserver.orientation.isLandscape {
                    self.mainViewModel.speechService.startRecognition()
                }
            }
        }
        // Handles navigation to camera when an illness is selected.
        .onChange(of: mainViewModel.selectedIllness) {
            if mainViewModel.selectedIllness != nil {
                router.currentRoute = .camera
            }
        }
        // Handles speech recognition based on orientation and Cardboard mode.
        .onChange(of: orientationObserver.orientation) {
            let isLandscape = orientationObserver.orientation.isLandscape
            if mainViewModel.isCardboardMode && isLandscape {
                mainViewModel.speechService.startRecognition()
            } else {
                mainViewModel.speechService.stopRecognition()
            }
        }
        // Handles speech recognition when Cardboard mode is toggled.
        .onChange(of: mainViewModel.isCardboardMode) {
            if mainViewModel.isCardboardMode {
                if orientationObserver.orientation.isLandscape {
                    mainViewModel.speechService.startRecognition()
                }
            } else {
                mainViewModel.speechService.stopRecognition()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppRouter())
        .environmentObject(MainViewModel())
        .environmentObject(DeviceOrientationObserver.shared)
}

