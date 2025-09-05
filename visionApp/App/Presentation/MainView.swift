import SwiftUI
import AVFoundation
import Speech

struct MainView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var orientationObserver: DeviceOrientationObserver

    var body: some View {
        NavigationView {
            ZStack {
                // Renderiza la pantalla según el estado de navegación
                switch router.currentRoute {
                case .splash:
                    SplashView()
                case .illnessList:
                    IllnessListView()
                case .camera:
                    CameraView(isCardboardMode: $mainViewModel.isCardboardMode)
                }
            }
            // Overlay del botón para Cardboard sin afectar el layout de la vista principal
            .overlay(alignment: .bottomTrailing) {
                if router.currentRoute == .illnessList { // En cámara ya está en el menú flotante
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
            // Si tienes lógica de voz, puedes inicializar aquí
        }
        .onChange(of: mainViewModel.selectedIllness) {
            if mainViewModel.selectedIllness != nil {
                router.currentRoute = .camera
            }
        }
        .onChange(of: orientationObserver.orientation) {
            let isLandscape = orientationObserver.orientation.isLandscape
            if mainViewModel.isCardboardMode && isLandscape {
                mainViewModel.speechService.startRecognition()
            } else {
                mainViewModel.speechService.stopRecognition()
            }
        }
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
