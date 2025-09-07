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
    var sliderWidth: CGFloat { verticalSizeClass == .compact ? 300 : 240 }
    private let sliderHeight: CGFloat = 30

    // Estado local para abrir/cerrar el panel de filtros
    @State private var showFiltersPanel: Bool = false

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

    /// Columna izquierda + slider/panel alineado con el centro de la "X"
    private var controlStack: some View {
        // Contenedor con alineación personalizada: leading + xCenter
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .xCenter)) {
            // --- Columna de botones (incluye la "X")
            VStack(alignment: .leading, spacing: 14) {
                if expanded {
                    Button(action: { router.currentRoute = .illnessList }) {
                        FloatingMenuIcon(systemName: "arrow.left.circle")
                    }
                    // Botón micrófono: activar/desactivar reconocimiento global
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            globalViewModel.isSpeechEnabled.toggle()
                        }
                    }) {
                        FloatingMenuIcon(systemName: globalViewModel.isSpeechEnabled ? "mic.fill" : "mic.slash.fill")
                    }
                    // “list.bullet” ahora abre/cierra el panel de filtros
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showFiltersPanel.toggle()
                        }
                    }) {
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
                        // Al colapsar, oculta el panel de filtros
                        if expanded {
                            showFiltersPanel = false
                        }
                        expanded.toggle()
                    }
                }) {
                    FloatingMenuIcon(
                        systemName: expanded ? "xmark.circle.fill" : "ellipsis.circle",
                        isMenu: true
                    )
                }
                .alignmentGuide(.xCenter) { d in d[VerticalAlignment.center] }
            }
            .frame(width: Self.menuWidth, alignment: .leading)
            .padding(.bottom, 8)

            // --- Panel de filtros dinámico por filtro seleccionado
            if expanded && showFiltersPanel {
                CompactFiltersPanel(
                    filterEnabled: $globalViewModel.filterEnabled,
                    centralFocus: $globalViewModel.centralFocus,
                    selectedFilterType: globalViewModel.selectedIllness?.filterType,
                    cataracts: $globalViewModel.cataractsSettings,
                    glaucoma: $globalViewModel.glaucomaSettings,
                    macular: $globalViewModel.macularDegenerationSettings,
                    tunnel: $globalViewModel.tunnelVisionSettings,
                    width: sliderWidth,
                    sliderHeight: sliderHeight
                )
                .alignmentGuide(.xCenter) { d in d[VerticalAlignment.center] }
                .padding(.leading, Self.menuWidth + 14)
                .transition(.move(edge: .leading).combined(with: .opacity))
            } else if expanded && !showFiltersPanel {
                // Slider rápido de intensidad global
                GlassSlider(value: $globalViewModel.centralFocus, width: sliderWidth)
                    .frame(height: sliderHeight)
                    .alignmentGuide(.xCenter) { d in d[VerticalAlignment.center] }
                    .padding(.leading, Self.menuWidth + 14)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
}

