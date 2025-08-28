//
//  Image+Extensions.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file extends the SwiftUI Image type to provide a custom style modifier
//  for floating menu items. The floatingMenuItemStyle() method applies a consistent
//  visual appearance to menu icons, including font size, color, background, and shadow.

import SwiftUI

extension Image {
    /// Applies a custom style for floating menu items.
    /// - Returns: A view with the menu item styling (font, color, background, shadow).
    func floatingMenuItemStyle() -> some View {
        self
            .font(.system(size: 26)) // Sets icon size
            .foregroundColor(.white) // Sets icon color
            .background(
                Circle().fill(Color.blue.opacity(0.9))
                    .frame(width: 48, height: 48) // Circular background
            )
            .shadow(radius: 3) // Adds a subtle shadow
    }
}
