//
//  LottieView.swift
//  VisionExperience
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import Lottie
import UIKit

struct LottieView: View {
    let animationName: String
    let loopMode: LottieLoopMode

    var body: some View {
        LottieRepresentable(animationName: animationName, loopMode: loopMode)
            .frame(width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height - 150) // 150 for once logos
            .aspectRatio(contentMode: .fill)
            .clipped()
            .ignoresSafeArea(edges: [.bottom, .leading, .trailing])
    }
}

private struct LottieRepresentable: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode

    final class Coordinator {
        var currentAnimationName: String?

        init(currentAnimationName: String? = nil) {
            self.currentAnimationName = currentAnimationName
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> LottieAnimationView {
        let animation = LottieAnimation.named(animationName)
        let view = LottieAnimationView(animation: animation)
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.play()

        // Track the current animation name since LottieAnimation doesn't expose `name`.
        context.coordinator.currentAnimationName = animationName

        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // Update the animation if the name changed (tracked via Coordinator)
        if context.coordinator.currentAnimationName != animationName {
            uiView.animation = LottieAnimation.named(animationName)
            context.coordinator.currentAnimationName = animationName
        }

        // Update loop mode if needed
        if uiView.loopMode != loopMode {
            uiView.loopMode = loopMode
        }

        // Ensure aspect fit
        uiView.contentMode = .scaleAspectFit

        // If not playing, start playing
        if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }
}

#Preview {
    LottieView(
        animationName: "eyeAnimation",
        loopMode: .loop
    )
}

