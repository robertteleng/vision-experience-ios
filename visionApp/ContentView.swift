import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var globalViewModel: GlobalViewModel
    @EnvironmentObject var orientationObserver: DeviceOrientationObserver

    var body: some View {
        NavigationView {
            VStack {
                // Renderiza la pantalla según el estado de navegación
                switch router.currentRoute {
                case .splash:
                    SplashView()
                case .illnessList:
                    IllnessListView()
                case .camera:
                    CameraView(isCardboardMode: $globalViewModel.isCardboardMode)
                }

                // Botón para Cardboard en illnessList y camera
                if router.currentRoute == .illnessList || router.currentRoute == .camera {
                    Button(action: {
                        globalViewModel.isCardboardMode.toggle()
                    }) {
                        Image(systemName: "eyeglasses")
                            .resizable()
                            .frame(width: 24, height: 16)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(globalViewModel.isCardboardMode ? 1.0 : 0.3))
                            )
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Si tienes lógica de voz, puedes inicializar aquí
        }
        .onChange(of: globalViewModel.selectedIllness) {
            if globalViewModel.selectedIllness != nil {
                router.currentRoute = .camera
            }
        }
        .onChange(of: orientationObserver.orientation) {
            let isLandscape = orientationObserver.orientation.isLandscape
            if globalViewModel.isCardboardMode && isLandscape {
                globalViewModel.speechService.startRecognition()
            } else {
                globalViewModel.speechService.stopRecognition()
            }
        }
        .onChange(of: globalViewModel.isCardboardMode) {
            if globalViewModel.isCardboardMode {
                if orientationObserver.orientation.isLandscape {
                    globalViewModel.speechService.startRecognition()
                }
            } else {
                globalViewModel.speechService.stopRecognition()
            }
        }
    }
}
