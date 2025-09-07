//
//  Untitled.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 7/9/25.
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

    // Nuevos ajustes de filtros
    @Binding var blurry: BlurryVisionSettings
    @Binding var scotoma: CentralScotomaSettings
    @Binding var hemianopsia: HemianopsiaSettings

    // NUEVO: Síntomas combinables
    @Binding var combinedEnabled: Bool
    @Binding var combined: CombinedSymptomsSettings

    var width: CGFloat
    var sliderHeight: CGFloat

    var body: some View {
        GeometryReader { geo in
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
                        case .blurryVision:
                            blurryVisionSection
                        case .centralScotoma:
                            centralScotomaSection
                        case .hemianopsia:
                            hemianopsiaSection
                        case .none:
                            Text("Selecciona una enfermedad para ajustar sus parámetros.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }

                        // Síntomas combinables (siempre visibles)
                        combinedSymptomsSection
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
            sliderRow(title: "Radio interno", value: $macular.innerRadius, range: 0...200, format: "%.0f px")
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

    private var blurryVisionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Visión borrosa").font(.subheadline).bold()
            sliderRow(title: "Desenfoque", value: $blurry.blurRadius, range: 0...30, format: "%.0f px")
        }
        .padding(.top, 6)
    }

    private var centralScotomaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Escotoma central").font(.subheadline).bold()
            sliderRow(title: "Radio interno", value: $scotoma.innerRadius, range: 0...200, format: "%.0f px")
            sliderRow(title: "Feather (borde)", value: $scotoma.feather, range: 0...200, format: "%.0f px")
            sliderRow(title: "Opacidad", value: $scotoma.opacity, range: 0...1, format: "%.2f")
            sliderRow(title: "Offset X", value: $scotoma.offsetNormalizedX, range: -1...1, format: "%.2f")
            sliderRow(title: "Offset Y", value: $scotoma.offsetNormalizedY, range: -1...1, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var hemianopsiaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hemianopsia").font(.subheadline).bold()
            HStack {
                Text("Lado")
                    .font(.subheadline)
                Spacer()
                Picker("", selection: Binding(
                    get: { hemianopsia.side },
                    set: { hemianopsia.side = $0 }
                )) {
                    ForEach(HemianopsiaSide.allCases, id: \.self) { side in
                        Text(label(for: side)).tag(side)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity)
            }
            sliderRow(title: "Feather (borde)", value: $hemianopsia.feather, range: 0...200, format: "%.0f px")
            sliderRow(title: "Opacidad", value: $hemianopsia.opacity, range: 0...1, format: "%.2f")
        }
        .padding(.top, 6)
    }

    // NUEVO: Sección de síntomas combinables (post-proceso global)
    private var combinedSymptomsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Síntomas combinables").font(.subheadline).bold()
                Spacer()
                Toggle("Activo", isOn: $combinedEnabled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            Group {
                sliderRow(title: "Bloom intensidad", value: $combined.bloomIntensity, range: 0...1, format: "%.2f")
                sliderRow(title: "Bloom radio (factor)", value: $combined.bloomRadiusFactor, range: 0...0.1, format: "%.3f")
                sliderRow(title: "Contraste global", value: $combined.globalContrast, range: 0.5...1.5, format: "%.2f")
                sliderRow(title: "Saturación global", value: $combined.globalSaturation, range: 0...1.5, format: "%.2f")
                sliderRow(title: "Velo (opacidad)", value: $combined.veilOpacity, range: 0...0.4, format: "%.2f")
            }
            .disabled(!combinedEnabled)
            .opacity(combinedEnabled ? 1.0 : 0.5)
        }
        .padding(.top, 12)
    }

    private func label(for side: HemianopsiaSide) -> String {
        switch side {
        case .left: return "Izq."
        case .right: return "Der."
        case .top: return "Sup."
        case .bottom: return "Inf."
        }
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

#Preview {
    @State var filterEnabled = true
    @State var centralFocus = 0.5
    @State var cataracts = CataractsSettings.defaults
    @State var glaucoma = GlaucomaSettings.defaults
    @State var macular = MacularDegenerationSettings.defaults
    @State var tunnel = TunnelVisionSettings.defaults
    @State var blurry = BlurryVisionSettings.defaults
    @State var scotoma = CentralScotomaSettings.defaults
    @State var hemianopsia = HemianopsiaSettings.defaults
    @State var combinedEnabled = true
    @State var combined = CombinedSymptomsSettings.defaults

    return CompactFiltersPanel(
        filterEnabled: $filterEnabled,
        centralFocus: $centralFocus,
        selectedFilterType: .centralScotoma,
        cataracts: $cataracts,
        glaucoma: $glaucoma,
        macular: $macular,
        tunnel: $tunnel,
        blurry: $blurry,
        scotoma: $scotoma,
        hemianopsia: $hemianopsia,
        combinedEnabled: $combinedEnabled,
        combined: $combined,
        width: 320,
        sliderHeight: 30
    )
    .padding()
}
