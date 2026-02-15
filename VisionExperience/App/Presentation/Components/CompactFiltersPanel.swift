//
//  CompactFiltersPanel.swift
//  VisionExperience
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
    @Binding var hemianopsia: HemianopsiaSettings
    @Binding var blurryVision: BlurryVisionSettings
    @Binding var centralScotoma: CentralScotomaSettings

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
                        case .hemianopsia:
                            hemianopsiaSection
                        case .blurryVision:
                            blurryVisionSection
                        case .centralScotoma:
                            centralScotomaSection
                        case .diabeticRetinopathy:
                            notImplementedSection(name: "Retinopatía diabética")
                        case .deuteranopia:
                            notImplementedSection(name: "Deuteranopia")
                        case .astigmatism:
                            notImplementedSection(name: "Astigmatismo")
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
            sliderRow(title: "Nubosidad", value: $cataracts.cloudiness, range: 0...1, format: "%.2f")
            sliderRow(title: "Brillo", value: $cataracts.brightness, range: 0...1.5, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var glaucomaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Glaucoma").font(.subheadline).bold()
            sliderRow(title: "Radio túnel", value: $glaucoma.tunnelRadius, range: 0...1, format: "%.2f")
            sliderRow(title: "Caída de viñeta", value: $glaucoma.vignetteFalloff, range: 0...1, format: "%.2f")
            sliderRow(title: "Contraste", value: $glaucoma.contrast, range: 0.5...2, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var macularSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Degeneración macular").font(.subheadline).bold()
            sliderRow(title: "Desenfoque central", value: $macular.centralBlurRadius, range: 0...30, format: "%.0f px")
            sliderRow(title: "Distorsión", value: $macular.distortionAmount, range: 0...1, format: "%.2f")
            sliderRow(title: "Oscuridad central", value: $macular.centralDarkness, range: 0...1, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var tunnelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Visión túnel").font(.subheadline).bold()
            sliderRow(title: "Radio túnel", value: $tunnel.tunnelRadius, range: 0...0.5, format: "%.3f")
            sliderRow(title: "Suavizado del borde", value: $tunnel.edgeSoftness, range: 0...1, format: "%.2f")
            sliderRow(title: "Nivel de oscuridad", value: $tunnel.darknessLevel, range: 0...1, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var hemianopsiaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hemianopsia").font(.subheadline).bold()
            
            Picker("Lado afectado", selection: $hemianopsia.side) {
                ForEach(HemianopsiaSide.allCases, id: \.self) { side in
                    Text(side.rawValue.capitalized).tag(side)
                }
            }
            .pickerStyle(.segmented)
            
            sliderRow(title: "Suavizado del borde", value: $hemianopsia.transitionSoftness, range: 0.0...1.0, format: "%.2f")
            sliderRow(title: "Oscuridad", value: $hemianopsia.darkness, range: 0.0...1.0, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var blurryVisionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Visión borrosa").font(.subheadline).bold()
            sliderRow(title: "Desenfoque", value: $blurryVision.blurAmount, range: 0...30, format: "%.0f px")
            sliderRow(title: "Claridad", value: $blurryVision.clarity, range: 0...1, format: "%.2f")
        }
        .padding(.top, 6)
    }

    private var centralScotomaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Escotoma central").font(.subheadline).bold()
            sliderRow(title: "Radio del escotoma", value: $centralScotoma.scotomaRadius, range: 0...0.5, format: "%.2f")
            sliderRow(title: "Oscuridad", value: $centralScotoma.darkness, range: 0...1, format: "%.2f")
            sliderRow(title: "Desenfoque del borde", value: $centralScotoma.edgeBlur, range: 0...30, format: "%.0f px")
        }
        .padding(.top, 6)
    }

    private func notImplementedSection(name: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name).font(.subheadline).bold()
            Text("Este filtro aún no tiene controles personalizados.")
                .font(.footnote)
                .foregroundStyle(.secondary)
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
