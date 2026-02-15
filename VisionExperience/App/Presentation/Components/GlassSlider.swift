//
//  GlassSlider.swift
//  VisionExperience
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file defines the GlassSlider, a reusable SwiftUI component for displaying
//  a slider with a glass (translucent) background. It is used for filter tuning and
//  other adjustable parameters throughout the app, and adapts its width for layout alignment.

import SwiftUI

/// GlassSlider displays a slider with a glass-style background for filter tuning.
/// - Adapts its width for layout alignment.
/// - Used for adjustable parameters in overlays and tuning panels.
struct GlassSlider: View {
    /// The bound value for the slider.
    @Binding var value: Double
    /// The width of the slider control.
    var width: CGFloat = 220

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: width, height: 32)
                .shadow(radius: 2, y: 1)
            Slider(value: $value, in: 0...1.0) // ISMA: Esto iba de 0.1 a 1, no de 0 a 1. Por esto tus enfermedades empezaban siempre con un poco de enfermedad y no se podían poner a 0
                .tint(Color.blue.opacity(0.85))
                .padding(.horizontal, 8)
        }
        .frame(width: width, height: 32)
    }
}
