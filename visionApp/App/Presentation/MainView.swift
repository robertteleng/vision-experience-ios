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
            // ✅ AÑADIDO: Configurar la navegación en el ViewModel
            mainViewModel.navigateToIllnessList = {
                router.currentRoute = .illnessList
            }
            
            // ✅ AÑADIDO: Iniciar speech recognition globalmente al aparecer la app
            mainViewModel.startSpeechRecognition()
        }
        .onDisappear {
            // ✅ AÑADIDO: Detener speech recognition al salir de la app
            mainViewModel.stopSpeechRecognition()
        }
        .onChange(of: mainViewModel.selectedIllness) {
            if mainViewModel.selectedIllness != nil {
                router.currentRoute = .camera
            }
        }
        // ✅ AÑADIDO: Gestión inteligente según el contexto
        .onChange(of: router.currentRoute) {
            // Notificar cambio de ruta al ViewModel
            let appRoute: AppRoute = {
                switch router.currentRoute {
                case .splash: return .splash
                case .illnessList: return .illnessList
                case .camera: return .camera
                }
            }()
            mainViewModel.updateCurrentRoute(appRoute)
            handleSpeechRecognitionContext()
        }
        .onChange(of: mainViewModel.isCardboardMode) {
            handleSpeechRecognitionContext()
        }
        .onChange(of: orientationObserver.orientation) {
            handleSpeechRecognitionContext()
        }
    }
    
    // ✅ AÑADIDO: Gestión inteligente del speech recognition según contexto
    private func handleSpeechRecognitionContext() {
        let isInCamera = router.currentRoute == .camera
        let isVRMode = mainViewModel.isCardboardMode
        let isLandscape = orientationObserver.orientation.isLandscape
        
        // Diferentes estrategias según el contexto:
        
        if router.currentRoute == .splash {
            // En splash, no necesitamos speech recognition
            mainViewModel.stopSpeechRecognition()
            
        } else if router.currentRoute == .illnessList {
            // En lista de enfermedades, SIEMPRE activo para seleccionar
            if !mainViewModel.speechService.isListening {
                print("🎤 Activating speech for illness selection")
                mainViewModel.startSpeechRecognition()
            }
            
        } else if isInCamera && isVRMode && isLandscape {
            // En VR mode, SIEMPRE activo para control hands-free
            if !mainViewModel.speechService.isListening {
                print("🎤 Activating speech for VR hands-free control")
                mainViewModel.startSpeechRecognition()
            }
            
        } else if isInCamera && !isVRMode {
            // En cámara normal, activo para conveniencia
            if !mainViewModel.speechService.isListening {
                print("🎤 Activating speech for camera convenience")
                mainViewModel.startSpeechRecognition()
            }
            
        } else {
            // En otros casos, mantener activo pero con menor prioridad
            if !mainViewModel.speechService.isListening {
                print("🎤 Maintaining speech recognition for global access")
                mainViewModel.startSpeechRecognition()
            }
        }
    }
}

//#Preview {
//    MainView()
//        .environmentObject(AppRouter())
//        .environmentObject(MainViewModel())
//        .environmentObject(DeviceOrientationObserver.shared)
//}
