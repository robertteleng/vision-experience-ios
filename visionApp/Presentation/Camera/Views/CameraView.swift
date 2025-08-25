//
//  Untitled.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

// --- CameraView.swift ---

struct CameraView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    @StateObject private var cameraService = CameraService()
    @State private var menuExpanded = false
    @StateObject private var orientationObserver = DeviceOrientationObserver()
    @Binding var isCardboardMode: Bool // Cambiado a Binding

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if isLandscape {
                    if isCardboardMode {
                        // Usar la vista modular CardboardView
                        CardboardView(
                            cameraService: cameraService,
                            illness: navigationViewModel.selectedIllness,
                            centralFocus: navigationViewModel.centralFocus
                        )
                    } else {
                        // Normal mode: camera feed with filter overlay
                        ZStack {
                            CameraPreviewView(session: cameraService.session)
                                .ignoresSafeArea()
                            ColorOverlay(illness: navigationViewModel.selectedIllness, centralFocus: navigationViewModel.centralFocus)
                                .ignoresSafeArea()
                        }
                    }

                    // Menú flotante en la esquina inferior izquierda
                    VStack {
                        Spacer()
                        FloatingMenu(navigationViewModel: navigationViewModel, expanded: $menuExpanded)
                            .padding(.leading, 12)
                            .padding(.bottom, 12)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                    // Slider alineado exactamente tras el menú
                    if menuExpanded {
                        VStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Spacer().frame(width: 68)
                                GlassSlider(
                                    value: $navigationViewModel.centralFocus,
                                    width: geometry.size.width - 68 - 32
                                )
                                .frame(height: 32)
                            }
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                } else {
                    // Portrait: pantalla para girar el dispositivo
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
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            navigationViewModel.currentView = .illnessList
                            navigationViewModel.speechService.stopRecognition()
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
        }
        .onAppear {
            cameraService.startSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
    }
}

//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView(navigationViewModel: NavigationViewModel())
//            .previewLayout(.fixed(width: 400, height: 800))
//    }
//}
