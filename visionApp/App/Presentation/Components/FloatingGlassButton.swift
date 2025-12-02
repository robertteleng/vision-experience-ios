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

    // Intento seguro de crear la imagen SF; si falla, se muestra un símbolo por defecto
    private var fallbackIconName: String { "eye" }

    // Computed properties to break up complex expressions
    private var foregroundColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    private var backgroundFill: some ShapeStyle {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.10)
    }
    
    private var strokeColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.18)
    }
    
    private var iconView: some View {
        Group {
            if UIImage(systemName: iconName) != nil {
                Image(systemName: iconName)
                    .renderingMode(.template)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(foregroundColor)
            } else {
                Image(systemName: fallbackIconName)
                    .renderingMode(.template)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(foregroundColor)
            }
        }
    }
    
    private var titleView: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundColor(foregroundColor)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
    }
    
    private var contentView: some View {
        HStack(spacing: 16) {
            iconView
            titleView
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .frame(minWidth: 320)
    }
    
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(backgroundFill)
    }
    
    private var overlayShape: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(strokeColor, lineWidth: 1.2)
    }
    
    var body: some View {
        Button(action: action) {
            contentView
                .background(backgroundShape)
                .overlay(overlayShape)
                .shadow(color: Color.black.opacity(0.16), radius: 8, y: 3)
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    FloatingGlassButton(title: "Test Button", iconName: "star.fill") {
        print("Button tapped")
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
