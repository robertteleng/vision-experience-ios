//
//  FloatingGlassButton.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file defines the FloatingGlassButton, a reusable SwiftUI component styled
//  to resemble an Apple Glass button. It adapts its appearance for light/dark mode
//  and is used for illness selection and other floating actions in the app.

import SwiftUI

/// FloatingGlassButton is a stylized button for floating actions.
/// - Displays an icon and title, adapts to color scheme.
/// - Used for illness selection and other prominent actions.
struct FloatingGlassButton: View {
    /// The button's title text.
    var title: String
    /// The SF Symbol icon name to display.
    var iconName: String
    /// The action to perform when tapped.
    var action: () -> Void
    /// The current color scheme (light/dark).
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.18), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 8, y: 3)
        }
        .accessibilityLabel(title)
    }
}
