//
//  CompactFiltersPanel.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 11/9/25.
//

import SwiftUI

// MARK: - Panel de Filtros compacto y scrollable
struct CompactFiltersPanel: View {
    @Binding var filterEnabled: Bool
    @Binding var centralFocus: Double

    let selectedFilterType: IllnessFilterType?

    @Binding var cataracts: CataractsSettings
    @Binding var glaucoma: GlaucomaSettings
    @Binding var macular: MacularDegenerationSettings
    @Binding var tunnel: TunnelVisionSettings

    var width: CGFloat
    var sliderHeight: CGFloat

    var body: some View {
        GeometryReader { geo in
            // Altura máxima ~48% del alto disponible
            let maxPanelHeight = max(220.0, geo.size.height * 0.48)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                Divider().opacity(0.15)

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 10) {
                        // Intensidad global
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Intensidad global")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            GlassSlider(value: $centralFocus, width: width - 24)
                                .frame(height: sliderHeight)
                        }

                        // Controles específicos por filtro
                        switch selectedFilterType {
                        case .cataracts:
                            cataractsSection
                        case .glaucoma:
                            glaucomaSection
                        case .macularDegeneration:
                            macularSection
                        case .tunnelVision:
                            tunnelSection
                        case .none:
                            Text("Selecciona una enfermedad para ajustar sus parámetros.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
                .scrollIndicators(.visible)
            }
            .frame(width: width)
            .frame(maxHeight: maxPanelHeight, alignment: .top)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.18), radius: 6, y: 3)
        }
        .frame(width: width, alignment: .leading)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "slider.horizontal.3")
                .foregroundStyle(.primary)
            Text("Filtros")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            Toggle(isOn: $filterEnabled) { Text("Activo").font(.subheadline) }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .labelsHidden()
        }
    }

    // MARK: Secciones por filtro (compactas)

    private var cataractsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cataratas").font(.subheadline).bold()
            sliderRow(title: "Desenfoque", value: $cataracts.blurRadius, range: 0...30, format: "%.0f px")
            sliderRow(title: "Contraste -", value: $cataracts.contrastReduction, range: 0...0.6, format: "%.2f")
            sliderRow(title: "Saturación -", value: $cataracts.saturationReduction, range: 0...0.5, format: "%.2f")
            sliderRow(title: "Azul - (tinte)", value: $cataracts.blueReduction, range: 0...0.4, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var glaucomaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Glaucoma").font(.subheadline).bold()
            sliderRow(title: "Intensidad viñeta", value: $glaucoma.vignetteIntensity, range: 0...2, format: "%.2f")
            sliderRow(title: "Radio viñeta (factor)", value: $glaucoma.vignetteRadiusFactor, range: 0.5...2, format: "%.2f")
            sliderRow(title: "Radio efecto (minSide)", value: $glaucoma.effectRadiusFactor, range: 0.2...2, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var macularSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Degeneración macular").font(.subheadline).bold()
            sliderRow(title: "Radio interno", value: $macular.innerRadius, range: 0...120, format: "%.0f px")
            sliderRow(title: "Radio externo (factor)", value: $macular.outerRadiusFactor, range: 0...1.0, format: "%.2f")
            sliderRow(title: "Desenfoque", value: $macular.blurRadius, range: 0...10, format: "%.1f px")
            sliderRow(title: "Oscurecimiento", value: $macular.darkAlpha, range: 0...1, format: "%.2f")
            sliderRow(title: "Distorsión (ángulo)", value: $macular.twirlAngle, range: 0...Double.pi, format: "%.2f rad")
        }
        .padding(.top, 6)
    }

    private var tunnelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Visión túnel").font(.subheadline).bold()
            sliderRow(title: "Radio mínimo (%)", value: $tunnel.minRadiusPercent, range: 0.02...0.15, format: "%.3f")
            sliderRow(title: "Radio máximo (factor)", value: $tunnel.maxRadiusFactor, range: 0.4...0.8, format: "%.2f")
            sliderRow(title: "Desenfoque periférico", value: $tunnel.blurRadius, range: 0...20, format: "%.0f px")
            sliderRow(title: "Feather base", value: $tunnel.featherFactorBase, range: 0.05...0.25, format: "%.3f")
        }
        .padding(.top, 6)
    }

    // Helper UI
    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, format: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .monospacedDigit()
            }
            Slider(value: value, in: range)
                .tint(.blue.opacity(0.85))
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
