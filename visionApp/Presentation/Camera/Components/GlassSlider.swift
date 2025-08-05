//
//  Untitled.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

// Slider con fondo glass (translúcido), alineado

import SwiftUI

struct GlassSlider: View {
    @Binding var value: Double
    var width: CGFloat = 220

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: width, height: 24) // MÁS FINO
                .shadow(radius: 2, y: 1)
            Slider(value: $value, in: 0.1...1.0)
                .tint(Color.blue)
                .padding(.horizontal, 8)
        }
        .frame(width: width, height: 24)
    }
}
