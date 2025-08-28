//
//  FloatingMenu.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file defines the FloatingMenu, a SwiftUI component for displaying a floating
//  vertical menu with quick access icons and actions. It adapts to device orientation,
//  provides feedback, and exposes a settings callback for advanced configuration.

import SwiftUI

/// FloatingMenu displays a vertical menu of quick actions and icons.
/// - Adapts to device orientation and size class.
/// - Provides feedback and animation on expansion/collapse.
/// - Exposes a settings callback for advanced configuration.
struct FloatingMenu: View {
    /// Access to global app state and illness selection.
    @EnvironmentObject var globalViewModel: MainViewModel
    /// Controls whether the menu is expanded.
    @Binding var expanded: Bool
    /// Device vertical size class for adaptive layout.
    @Environment(\.verticalSizeClass) var verticalSizeClass
    /// Optional callback for settings action.
    var onSettingsTap: (() -> Void)? = nil

    /// Static width for menu alignment and overlay positioning.
    static let menuWidth: CGFloat = 56 // icon (24) + internal spacing and safe touch area

    /// Adaptive slider width based on device orientation.
    var sliderWidth: CGFloat {
        verticalSizeClass == .compact ? 340 : 220
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if expanded {
                Button(action: { print("Eye pressed") }) {
                    FloatingMenuIcon(systemName: "eye")
                }
                Button(action: { print("Alert pressed") }) {
                    FloatingMenuIcon(systemName: "exclamationmark.triangle")
                }
                Button(action: { onSettingsTap?() }) {
                    FloatingMenuIcon(systemName: "gear")
                }
                // Cardboard glasses icon button
                Button(action: {
                    globalViewModel.isCardboardMode.toggle()
                }) {
                    FloatingMenuIcon(systemName: "eyeglasses")
                }
            }
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expanded.toggle()
                }
            }) {
                FloatingMenuIcon(
                    systemName: expanded ? "xmark.circle.fill" : "ellipsis.circle",
                    isMenu: true
                )
            }
        }
        .frame(width: FloatingMenu.menuWidth, alignment: .leading)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

//struct FloatingMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        FloatingMenu(navigationViewModel: NavigationViewModel())
//            .previewLayout(.fixed(width: 400, height: 800))
//        FloatingMenu(navigationViewModel: NavigationViewModel())
//            .previewLayout(.fixed(width: 800, height: 400))
//    }
//}
