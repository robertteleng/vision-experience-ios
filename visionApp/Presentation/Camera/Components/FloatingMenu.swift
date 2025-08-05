//
//  FloatingMenu.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

struct FloatingMenu: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var expanded = false   // Empieza cerrado

    // Calcula el ancho del slider según orientación
    var sliderWidth: CGFloat {
        verticalSizeClass == .compact ? 600 : 200 // Más ancho tanto en landscape como portrait
    }

    // Cambia el padding inferior según orientación para mayor pegado visual
    var bottomPadding: CGFloat {
        verticalSizeClass == .compact ? 16 : 8  // Ajusta a tu gusto, 0 si quieres PEGADO TOTAL
    }

    var body: some View {
        ZStack {
            Color.clear // o tu contenido principal de fondo
            HStack(alignment: .bottom, spacing: 0) {
                VStack(spacing: 18) {
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
                if expanded {
                    GlassSlider(
                        value: $navigationViewModel.centralFocus,
                        width: sliderWidth
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .padding(.bottom, 2)
                    .padding(.leading, 24)
                }
                Spacer(minLength: 0)
            }
            // ¡NO pongas padding!
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            // ¡Ignora safe areas del bottom y leading para pegarlo al pixel!
            .ignoresSafeArea(edges: [.bottom, .leading])
        }
    }
}

struct FloatingMenu_Previews: PreviewProvider {
    static var previews: some View {
        FloatingMenu(navigationViewModel: NavigationViewModel())
            .previewLayout(.fixed(width: 600, height: 400)) // Mejor que sizeThatFits para ver el layout real
            .padding()
    }
}
