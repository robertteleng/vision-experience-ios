//
//  Image+Extensions.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
import SwiftUI

extension Image {
    func floatingMenuItemStyle() -> some View {
        self
            .font(.system(size: 26))
            .foregroundColor(.white)
            .background(
                Circle().fill(Color.blue.opacity(0.9))
                    .frame(width: 48, height: 48)
            )
            .shadow(radius: 3)
    }
}
