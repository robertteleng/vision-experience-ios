//
//  FloatingMenu.swift
//  VisionExperience
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
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var speechViewModel: SpeechRecognitionViewModel
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
    
    // ✅ AÑADIDO: Estado para mostrar panel de testing de voz
    @State private var showVoiceTestPanel: Bool = false

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
        // ✅ AÑADIDO: Sheet para testing de voz
        .sheet(isPresented: $showVoiceTestPanel) {
            NavigationView {
                VoiceCommandsTestView(
                    mainViewModel: mainViewModel,
                    speechViewModel: speechViewModel
                )
                .navigationTitle("Test de Voz")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") {
                            showVoiceTestPanel = false
                        }
                    }
                }
            }
        }
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
                    // "list.bullet" ahora abre/cierra el panel de filtros
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showFiltersPanel.toggle()
                            if showFiltersPanel {
                                showVoiceTestPanel = false // Cerrar voice test si está abierto
                            }
                        }
                    }) {
                        FloatingMenuIcon(systemName: "list.bullet")
                    }
                    Button(action: { mainViewModel.isCardboardMode.toggle() }) {
                        FloatingMenuIcon(systemName: "eyeglasses")
                    }
                    
                    // ✅ AÑADIDO: Botón para testing de voz
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showVoiceTestPanel = true
                        // Cerrar panel de filtros si está abierto
                        if showFiltersPanel {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showFiltersPanel = false
                            }
                        }
                    }) {
                        FloatingMenuIcon(systemName: "mic.circle")
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
                    hemianopsia: $mainViewModel.hemianopsiaSettings,
                    blurryVision: $mainViewModel.blurryVisionSettings,
                    centralScotoma: $mainViewModel.centralScotomaSettings,
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



//#Preview {
//    FloatingMenu(expanded: .constant(true))
//        .padding()
//        .background(Color.gray.opacity(0.2))
//        .environmentObject(MainViewModel())
//        .environmentObject(AppRouter())
//}
