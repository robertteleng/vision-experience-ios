//
//  ContentView.swift
//  visionApp
//
//  Main user interface logic, state management and navigation for the app.
//  Implements MVVM principles: views are separated, state is handled by NavigationViewModel.
//  Includes voice command processing and basic AR/Camera simulation.
//

import SwiftUI
import AVFoundation
import Speech

// MARK: - Main Entry Point and App Navigation

struct ContentView: View {
    @StateObject private var navigationViewModel = NavigationViewModel()
    @State private var isCardboardMode = false
    @State private var isLandscape = UIDevice.current.orientation.isLandscape

    var body: some View {
        NavigationView {
            VStack {
                // Render the main screens based on the navigation state
                switch navigationViewModel.currentView {
                case .splash:
                    SplashView(navigationViewModel: navigationViewModel)
                case .illnessList:
                    IllnessListView(navigationViewModel: navigationViewModel)
                case .camera:
                    CameraView(navigationViewModel: navigationViewModel, isCardboardMode: $isCardboardMode)
                }

                // Show the Cardboard button in both illness list and camera screens
                if navigationViewModel.currentView == .illnessList || navigationViewModel.currentView == .camera {
                    Button(action: {
                        isCardboardMode.toggle()
                    }) {
                        Image(systemName: "eyeglasses")
                            .resizable()
                            .frame(width: 24, height: 16)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(isCardboardMode ? 1.0 : 0.3))
                            )
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Request speech recognition authorization when the app launches
            navigationViewModel.setupSpeech()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            let orientation = UIDevice.current.orientation
            if orientation.isValidInterfaceOrientation {
                isLandscape = orientation.isLandscape
            }
        }
        .onChange(of: isLandscape) {
            if isCardboardMode && isLandscape {
                navigationViewModel.startVoiceRecognition()
            } else if isCardboardMode && !isLandscape {
                navigationViewModel.stopVoiceRecognition()
            }
        }
        .onChange(of: isCardboardMode) {
            if isCardboardMode {
                if isLandscape {
                    navigationViewModel.startVoiceRecognition()
                }
            } else {
                navigationViewModel.stopVoiceRecognition()
            }
        }
    }
}
