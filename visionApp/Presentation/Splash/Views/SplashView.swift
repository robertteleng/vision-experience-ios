import SwiftUI
import Lottie

struct SplashView: View {
    var navigationViewModel: NavigationViewModel
    @State private var animate = false

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                // Lottie animation centered on the screen
                LottieView(animationName: "eyeAnimation", loopMode: .loop)
                    .frame(width: 200, height: 200)
                    .opacity(animate ? 1 : 0)
                    .animation(Animation.easeIn(duration: 1.0), value: animate)

                Spacer()

                // Logo centered at the bottom (should exist in bundle)
                if let path = Bundle.main.path(forResource: "logo", ofType: "png"),
                   let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .opacity(0.8)
                        .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            animate = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                navigationViewModel.currentView = .illnessList
            }
        }
    }
}
