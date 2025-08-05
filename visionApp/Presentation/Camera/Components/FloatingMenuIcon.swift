//
//  Untitled.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

// Botón translúcido tipo glass, reutilizable
import SwiftUI

struct FloatingMenuIcon: View {
    var systemName: String
    var isMenu: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    icon
                }
            } else {
                icon
            }
        }
    }

    var icon: some View {
        Image(systemName: systemName)
            .font(.system(size: isMenu ? 32 : 26))
            .foregroundColor(.white)
            .frame(width: isMenu ? 56 : 48, height: isMenu ? 56 : 48)
            .background(.ultraThinMaterial, in: Circle())
            .shadow(radius: 4)
    }
}
