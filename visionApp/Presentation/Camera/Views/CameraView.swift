//
//  Untitled.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

// MARK: - Camera Simulation View with Filter Controls
struct CameraView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    @StateObject private var cameraService = CameraService()
    @State private var menuExpanded = false
    @StateObject private var orientationObserver = DeviceOrientationObserver()

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if isLandscape {
                    // Vista de cámara a pantalla completa
                    CameraPreviewView(session: cameraService.session)
                        .ignoresSafeArea()
                    
                    // Menú flotante en la esquina inferior izquierda
                    FloatingMenu(navigationViewModel: navigationViewModel, expanded: $menuExpanded)

                    // Slider centrado en la parte inferior, solo cuando el menú está expandido
                    if menuExpanded {
                        VStack {
                            Spacer()
                            GlassSlider(
                                value: $navigationViewModel.centralFocus,
                                width: geometry.size.width * 0.75 // 75% del ancho de pantalla
                            )
                            .padding(.bottom, 36)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .ignoresSafeArea(edges: [.bottom])
                    }
                } else {
                    // Vista para cuando el dispositivo NO está en landscape
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
                            navigationViewModel.stopVoiceRecognition()
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
            // ACTUALIZA LA ORIENTACIÓN DE LA CÁMARA CADA VEZ QUE CAMBIA
            .onChange(of: orientationObserver.orientation) { newOrientation in
                cameraService.updateVideoOrientation(deviceOrientation: newOrientation)
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
