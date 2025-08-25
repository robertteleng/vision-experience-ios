//
//  CameraView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var menuExpanded = false
    @EnvironmentObject var orientationObserver: DeviceOrientationObserver
    @Binding var isCardboardMode: Bool
    @EnvironmentObject var router: AppRouter

    var body: some View {
        ZStack {
            let isLandscape = orientationObserver.orientation.isLandscape
            if isLandscape {
                if isCardboardMode {
                    ZStack {
                        CardboardView(
                            cameraService: cameraViewModel.cameraService,
                            illness: globalViewModel.selectedIllness,
                            centralFocus: globalViewModel.centralFocus,
                            deviceOrientation: orientationObserver.orientation
                        )
                        // Floating menu overlay
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded)
                                .padding(.leading, 12)
                                .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        // Slider overlay
                        if menuExpanded {
                            VStack {
                                Spacer()
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 68)
                                    GlassSlider(
                                        value: $globalViewModel.centralFocus,
                                        width: UIScreen.main.bounds.width - 68 - 32
                                    )
                                    .frame(height: 32)
                                }
                                .frame(maxWidth: .infinity, alignment: .bottom)
                                .padding(.bottom, 12)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    .ignoresSafeArea()
                } else {
                    ZStack {
                        CameraPreviewView(session: cameraViewModel.cameraService.session)
                            .ignoresSafeArea()
                        ColorOverlay(illness: globalViewModel.selectedIllness, centralFocus: globalViewModel.centralFocus)
                            .ignoresSafeArea()
                    }
                }
            } else {
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
                        router.currentRoute = .illnessList
                        // Si tienes lógica de voz, puedes detenerla aquí
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
        .onAppear {
            cameraViewModel.startSession()
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
    }
}

//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView(navigationViewModel: NavigationViewModel())
//            .previewLayout(.fixed(width: 400, height: 800))
//    }
//}
