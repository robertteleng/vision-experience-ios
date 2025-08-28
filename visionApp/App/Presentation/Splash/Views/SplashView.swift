//
//  SplashView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import Lottie

struct SplashView: View {
    @EnvironmentObject var router: AppRouter
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
                
                VStack {
                    
                    if let path = Bundle.main.path(forResource: "logo-fonce", ofType: "png"),
                       let uiImage = UIImage(contentsOfFile: path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.primary)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 0.4)
                            .opacity(0.8)
                            .padding(.bottom, 30)
                    }
                    
                    if let path = Bundle.main.path(forResource: "logo-umh", ofType: "png"),
                       let uiImage = UIImage(contentsOfFile: path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.primary)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 0.1)
                            .opacity(0.8)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            animate = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                router.currentRoute = .illnessList
            }
        }
    }
}

