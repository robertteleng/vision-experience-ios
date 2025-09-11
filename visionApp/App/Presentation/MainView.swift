import SwiftUI

struct MainView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var speechViewModel: SpeechRecognitionViewModel
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
    }
}

//#Preview {
//    MainView()
//        .environmentObject(AppRouter())
//        .environmentObject(MainViewModel())
//        .environmentObject(DeviceOrientationObserver.shared)
//}
