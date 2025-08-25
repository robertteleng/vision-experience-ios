//
//  FloatingMenu.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

import SwiftUI

struct FloatingMenu: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    @Binding var expanded: Bool
    @Environment(\.verticalSizeClass) var verticalSizeClass

    // Slider width adaptativo
    var sliderWidth: CGFloat {
        verticalSizeClass == .compact ? 340 : 220
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if expanded {
                Button(action: { print("Ojo pulsado") }) {
                    FloatingMenuIcon(systemName: "eye")
                }
                Button(action: { print("Alerta pulsado") }) {
                    FloatingMenuIcon(systemName: "exclamationmark.triangle")
                }
                Button(action: { print("Gear pulsado") }) {
                    FloatingMenuIcon(systemName: "gear")
                }
                // Cardboard glasses icon button
                Button(action: {
                    $navigationViewModel.isCardboardMode.toggle
                }) {
                    FloatingMenuIcon(systemName: "goforward") // Replace with custom asset if available
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
        .padding(.leading, 12)
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
