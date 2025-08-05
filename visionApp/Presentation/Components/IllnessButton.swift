//
//  IllnessButton.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

struct IllnessButton: View {
    let title: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .shadow(color: Color.blue.opacity(0.22), radius: 3, x: 0, y: 2)
                Text(title)
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .shadow(color: Color.blue.opacity(0.18), radius: 2, x: 0, y: 1)
                Spacer()
            }
            .frame(minWidth: 280, maxWidth: 340, minHeight: 54)
            .padding(.horizontal, 18)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.95)]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 2)
            )
            .shadow(color: Color.blue.opacity(0.15), radius: 6, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
