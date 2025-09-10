//
//  Image+Extensions.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file provides reusable styling for floating menu icons.
//  It includes:
//  - An Image-specific convenience to style SF Symbols quickly.
//  - A generic View-based modifier to reuse the circular floating style with any content.
//
//  Accessibility:
//  - Callers should set .accessibilityLabel(_) at usage sites to describe the action.
//

import SwiftUI

// MARK: - Floating Menu Item Style (Image-specific)
//
// Example:
//   Image(systemName: "xmark")
//       .floatingMenuItemStyle()
//
extension Image {
    /// Applies a circular floating menu style to an Image, suitable for quick actions.
    /// - Parameters:
    ///   - size: The diameter of the circular background in points. Default is 48.
    ///   - symbolFontSize: Font size for SF Symbols. Default is 26.
    ///   - color: Background color of the circle. Default is blue at 90% opacity.
    ///   - foreground: Foreground color for the symbol. Default is white.
    ///   - shadowRadius: Shadow blur radius. Default is 3.
    /// - Returns: A styled view representing a floating menu item.
    func floatingMenuItemStyle(
        size: CGFloat = 48,
        symbolFontSize: CGFloat = 26,
        color: Color = Color.blue.opacity(0.9),
        foreground: Color = .white,
        shadowRadius: CGFloat = 3
    ) -> some View {
        self
            .font(.system(size: symbolFontSize))
            .foregroundColor(foreground)
            .background(
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
            )
            .shadow(radius: shadowRadius)
    }
}

// MARK: - Generic View Modifier Variant
//
// This enables the same floating style to be applied to any view (e.g., Text, Label, custom content).
// Examples:
//   Image(systemName: "xmark").floatingMenuItem()
//   Text("A").font(.headline).floatingMenuItem(size: 56)
//
private struct FloatingMenuItemModifier: ViewModifier {
    var size: CGFloat
    var color: Color
    var foreground: Color
    var shadowRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .foregroundStyle(foreground)
            .frame(width: size, height: size, alignment: .center)
            .background(
                Circle()
                    .fill(color)
            )
            .shadow(radius: shadowRadius)
            // Note: Add an accessibility label at call sites to describe the control’s purpose.
    }
}

extension View {
    /// Applies a circular floating menu style to any view.
    /// - Parameters:
    ///   - size: The diameter of the circular background in points. Default is 48.
    ///   - color: Background color of the circle. Default is blue at 90% opacity.
    ///   - foreground: Foreground color for the content. Default is white.
    ///   - shadowRadius: Shadow blur radius. Default is 3.
    /// - Returns: A styled view representing a floating menu item.
    func floatingMenuItem(
        size: CGFloat = 48,
        color: Color = Color.blue.opacity(0.9),
        foreground: Color = .white,
        shadowRadius: CGFloat = 3
    ) -> some View {
        modifier(FloatingMenuItemModifier(size: size, color: color, foreground: foreground, shadowRadius: shadowRadius))
    }
}
