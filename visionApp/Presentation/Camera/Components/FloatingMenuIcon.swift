//
//  FloatingMenuIcon.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

// Botón translúcido tipo glass, reutilizable
import SwiftUI

struct FloatingMenuIcon: View {
    var systemName: String
    var isMenu: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: isMenu ? 32 : 26))
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
