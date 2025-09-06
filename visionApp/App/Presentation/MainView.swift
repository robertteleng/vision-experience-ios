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
