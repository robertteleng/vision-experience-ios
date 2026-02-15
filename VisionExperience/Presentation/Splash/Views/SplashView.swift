//
//  SplashView.swift
//  VisionExperience
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import Lottie

struct SplashView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var orientationObserver: DeviceOrientationObserver
    @State private var animate = false

    var body: some View {
        
        // When in landscape show logos side by side, otherwise show logos above the animation
        Group {
            if (orientationObserver.orientation.isLandscape) {
                LandscapeSplashView()
            } else {
                PortraitSplashView()
            }
        }.onAppear {
            animate = true
            // Use SwiftUI haptics
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                router.currentRoute = .illnessList
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppRouter())
        .environmentObject(DeviceOrientationObserver.shared)
}


struct PortraitSplashView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer(minLength: 150)
            // Once logo 150px height
            HStack(spacing: 20) {
                Image("logo-fonce")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.primary)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.4)
                    .opacity(0.8)
                    .padding(.bottom, 30)
                Image("logo-umh")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.primary)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.1)
                    .opacity(0.8)
                    .padding(.bottom, 30)
            }
            .frame(width: UIScreen.main.bounds.width, height: 150)
            
            // Lottie animation filling the rest of the screen
            LottieView(animationName: "eyeAnimation", loopMode: .loop)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PortraitSplashView()
        .environmentObject(AppRouter())
        .environmentObject(DeviceOrientationObserver.shared)
}

struct LandscapeSplashView: View {
    var body: some View {
        HStack(spacing: 20) {
            Image("logo-fonce")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.primary)
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.4)
                .opacity(0.8)
                .padding(.bottom, 30)
            Image("logo-umh")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.primary)
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.1)
                .opacity(0.8)
                .padding(.bottom, 30)
        }
        .frame(width: UIScreen.main.bounds.width, height: 150)
    }
}

#Preview {
    LandscapeSplashView()
        .environmentObject(AppRouter())
        .environmentObject(DeviceOrientationObserver.shared)
}
