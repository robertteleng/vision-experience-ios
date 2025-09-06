//
//  FloatingMenu.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

struct FloatingMenu: View {
    @EnvironmentObject var globalViewModel: MainViewModel
    @EnvironmentObject var router: AppRouter
    @Binding var expanded: Bool
    @Environment(\.verticalSizeClass) var verticalSizeClass

    // Anchoring width so other overlays (e.g., bottom slider bar) can align to the menu's right edge
    static let menuWidth: CGFloat = 56 // icon (24) + internal spacing and safe touch area

    // Slider width adaptativo
    var sliderWidth: CGFloat {
        verticalSizeClass == .compact ? 340 : 220
    }
    private let sliderHeight: CGFloat = 32

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if expanded {
                Button(action: {
                    router.currentRoute = .illnessList
                }) {
                    FloatingMenuIcon(systemName: "list.bullet")
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
        // Slider overlay aligned to the right edge of the menu when expanded
        .overlay(alignment: .bottomLeading) {
            if expanded {
                GlassSlider(value: $globalViewModel.centralFocus, width: sliderWidth)
                    .offset(
                        x: FloatingMenu.menuWidth,
                        y: -((FloatingMenu.menuWidth - sliderHeight) / 2)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

#Preview {
    FloatingMenu(expanded: .constant(true))
        .padding()
        .background(Color.gray.opacity(0.2))
        .environmentObject(MainViewModel())
}
