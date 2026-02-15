//
//  FloatingMenuIcon.swift
//  VisionExperience
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file defines the FloatingMenuIcon, a reusable SwiftUI component for rendering
//  glass-style circular icons in floating menus. It adapts its appearance for light/dark mode
//  and supports larger sizing for menu toggles. Used throughout the app for quick actions.

import SwiftUI

/// FloatingMenuIcon renders a glass-style circular icon for floating menus.
/// - Adapts to color scheme (light/dark).
/// - Supports larger sizing for menu toggles.
struct FloatingMenuIcon: View {
    /// The SF Symbol name for the icon.
    var systemName: String
    /// Indicates if the icon is for the main menu toggle (larger size).
    var isMenu: Bool = false
    /// The current color scheme (light/dark).
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: isMenu ? 32 : 26)) // Larger font for menu toggle
            .foregroundColor(Color.primary)
            .frame(width: isMenu ? 56 : 48, height: isMenu ? 56 : 48)
            .background(
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.15))
            )
            .overlay(
                Circle()
                    .stroke(Color.primary.opacity(0.25), lineWidth: 1)
            )
            .shadow(radius: 4)
    }
}
