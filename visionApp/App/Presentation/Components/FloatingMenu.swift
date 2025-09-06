//
//  FloatingMenu.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

// MARK: - Custom vertical alignment (centra el slider con la "X")
extension VerticalAlignment {
    private enum XCenterID: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat { d[VerticalAlignment.center] }
    }
    /// Usado para alinear verticalmente el slider con el centro del botón de la "X".
    static let xCenter = VerticalAlignment(XCenterID.self)
}

struct FloatingMenu: View {
    @EnvironmentObject var globalViewModel: MainViewModel
    @EnvironmentObject var router: AppRouter
    @Binding var expanded: Bool
    @Environment(\.verticalSizeClass) var verticalSizeClass

    // Anchoring width del menú (iconos + toque seguro)
    static let menuWidth: CGFloat = 56

    // Slider adaptativo por size class
    var sliderWidth: CGFloat { verticalSizeClass == .compact ? 340 : 220 }
    private let sliderHeight: CGFloat = 32

    var body: some View {
        // Coloca todo en la esquina inferior izquierda
        VStack {
            Spacer()
            HStack {
                controlStack
                Spacer(minLength: 0)
            }
            .padding(.leading, 12)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Columna izquierda + slider alineado con el centro de la "X"
    private var controlStack: some View {
        // Contenedor con alineación personalizada: leading + xCenter
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .xCenter)) {
            // --- Columna de botones (incluye la "X")
            VStack(alignment: .leading, spacing: 18) {
                if expanded {
                    Button(action: { router.currentRoute = .illnessList }) {
                        FloatingMenuIcon(systemName: "arrow.left.circle")
                    }
                    Button(action: { router.currentRoute = .illnessList }) {
                        FloatingMenuIcon(systemName: "list.bullet")
                    }
                    Button(action: { globalViewModel.isCardboardMode.toggle() }) {
                        FloatingMenuIcon(systemName: "eyeglasses")
                    }
                }

                // Botón "X" (o "..." cuando está colapsado)
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        expanded.toggle()
                    }
                }) {
                    FloatingMenuIcon(
                        systemName: expanded ? "xmark.circle.fill" : "ellipsis.circle",
                        isMenu: true
                    )
                }
                // Publica su centro vertical en la alineación personalizada
                .alignmentGuide(.xCenter) { d in d[VerticalAlignment.center] }
            }
            .frame(width: Self.menuWidth, alignment: .leading)
            .padding(.bottom, 12)

            // --- Slider: aparece a la derecha y se alinea con el centro de la "X"
            if expanded {
                GlassSlider(value: $globalViewModel.centralFocus, width: sliderWidth)
                    .frame(height: sliderHeight)
                    // Alinea su centro vertical a la guía xCenter
                    .alignmentGuide(.xCenter) { d in d[VerticalAlignment.center] }
                    // Lo desplazamos en X exactamente el ancho del menú + margen
                    .padding(.leading, Self.menuWidth + 18) // mismo “aire” que el spacing de la columna
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    FloatingMenu(expanded: .constant(true))
        .padding()
        .background(Color.gray.opacity(0.2))
        .environmentObject(MainViewModel())
        .environmentObject(AppRouter())
}
