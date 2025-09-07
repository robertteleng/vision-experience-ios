<<<<<<< HEAD
//
=======
>>>>>>> illness-filters-temp
//  FloatingMenu.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
<<<<<<< HEAD
//  This file defines the FloatingMenu, a SwiftUI component for displaying a floating
//  vertical menu with quick access icons and actions. It adapts to device orientation,
//  provides feedback, and exposes a settings callback for advanced configuration.

import SwiftUI

/// FloatingMenu displays a vertical menu of quick actions and icons.
/// - Adapts to device orientation and size class.
/// - Provides feedback and animation on expansion/collapse.
/// - Exposes a settings callback for advanced configuration.
struct FloatingMenu: View {
    /// Access to global app state and illness selection.
    @EnvironmentObject var globalViewModel: MainViewModel
    /// Controls whether the menu is expanded.
    @Binding var expanded: Bool
    /// Device vertical size class for adaptive layout.
    @Environment(\.verticalSizeClass) var verticalSizeClass
    /// Optional callback for settings action.
    var onSettingsTap: (() -> Void)? = nil

    /// Static width for menu alignment and overlay positioning.
    static let menuWidth: CGFloat = 56 // icon (24) + internal spacing and safe touch area

    /// Adaptive slider width based on device orientation.
    var sliderWidth: CGFloat {
        verticalSizeClass == .compact ? 340 : 220
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if expanded {
                Button(action: { print("Eye pressed") }) {
                    FloatingMenuIcon(systemName: "eye")
                }
                Button(action: { print("Alert pressed") }) {
                    FloatingMenuIcon(systemName: "exclamationmark.triangle")
                }
                Button(action: { onSettingsTap?() }) {
                    FloatingMenuIcon(systemName: "gear")
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
=======

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
    @EnvironmentObject var mainViewModel: MainViewModel
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
                            mainViewModel.isSpeechEnabled.toggle()
                        }
                    }) {
                        FloatingMenuIcon(systemName: mainViewModel.isSpeechEnabled ? "mic.fill" : "mic.slash.fill")
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
                    Button(action: { mainViewModel.isCardboardMode.toggle() }) {
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
                    filterEnabled: $mainViewModel.filterEnabled,
                    centralFocus: $mainViewModel.centralFocus,
                    selectedFilterType: mainViewModel.selectedIllness?.filterType,
                    cataracts: $mainViewModel.cataractsSettings,
                    glaucoma: $mainViewModel.glaucomaSettings,
                    macular: $mainViewModel.macularDegenerationSettings,
                    tunnel: $mainViewModel.tunnelVisionSettings,
                    blurry: $mainViewModel.blurryVisionSettings,
                    scotoma: $mainViewModel.centralScotomaSettings,
                    hemianopsia: $mainViewModel.hemianopsiaSettings,
                    combinedEnabled: $mainViewModel.combinedSymptomsEnabled,
                    combined: $mainViewModel.combinedSymptoms,
                    width: sliderWidth,
                    sliderHeight: sliderHeight
                )
                .alignmentGuide(.xCenter) { d in d[VerticalAlignment.center] }
                .padding(.leading, Self.menuWidth + 14)
                .transition(.move(edge: .leading).combined(with: .opacity))
            } else if expanded && !showFiltersPanel {
                // Slider rápido de intensidad global
                GlassSlider(value: $mainViewModel.centralFocus, width: sliderWidth)
                    .frame(height: sliderHeight)
                    .alignmentGuide(.xCenter) { d in d[VerticalAlignment.center] }
                    .padding(.leading, Self.menuWidth + 14)
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
>>>>>>> illness-filters-temp
