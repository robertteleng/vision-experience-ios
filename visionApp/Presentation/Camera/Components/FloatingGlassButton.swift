//
//  IllnessButton.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

// MARK: - Botón Apple Glass flotante adaptado para cada enfermedad

struct FloatingGlassButton: View {
    var title: String
    var iconName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: 320)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 8, y: 3)
        }
        .accessibilityLabel(title)
    }
}
