//
//  CameraView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject var globalViewModel: MainViewModel
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var menuExpanded = false
    @EnvironmentObject var orientationObserver: DeviceOrientationObserver
    @Binding var isCardboardMode: Bool
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var tuningVM: FilterTuningViewModel
    // Renamed: toggle for the tuning panel (per illness)
    @State private var showSettingsPanel = false

    var body: some View {
        ZStack {
            let isLandscape = orientationObserver.orientation.isLandscape
            if isLandscape {
                if isCardboardMode {
                    ZStack {
                        CardboardView(
                            cameraService: cameraViewModel.cameraService,
                            illness: globalViewModel.selectedIllness,
                            centralFocus: globalViewModel.centralFocus,
                            deviceOrientation: orientationObserver.orientation
                        )
                        // Floating menu overlay
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded, onSettingsTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    showSettingsPanel.toggle()
                                }
                            })
                            .padding(.leading, 12)
                            .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .zIndex(2)
                        // Slider overlay
                        if menuExpanded {
                            BottomSliderOverlay(value: $globalViewModel.centralFocus)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .zIndex(1)
                        }
                        // Tuning overlay (per illness)
                        if showSettingsPanel {
                            IllnessTuningPanel(isPresented: $showSettingsPanel, illness: globalViewModel.selectedIllness)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .padding(.trailing, 12)
                                .padding(.bottom, 12)
                                .zIndex(3)
                        }
                    }
                    .ignoresSafeArea()
                } else {
                    ZStack {
                        CameraImageView(
                            image: cameraViewModel.cameraService.currentFrame,
                            panel: .full,
                            illness: globalViewModel.selectedIllness,
                            centralFocus: globalViewModel.centralFocus
                        )
                        .ignoresSafeArea()
                        // Menú flotante y slider
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded, onSettingsTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    showSettingsPanel.toggle()
                                }
                            })
                            .padding(.leading, 12)
                            .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .zIndex(2)
                        if menuExpanded {
                            BottomSliderOverlay(value: $globalViewModel.centralFocus)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .zIndex(1)
                        }
                        // Tuning overlay (per illness)
                        if showSettingsPanel {
                            IllnessTuningPanel(isPresented: $showSettingsPanel, illness: globalViewModel.selectedIllness)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .padding(.trailing, 12)
                                .padding(.bottom, 12)
                                .zIndex(3)
                        }
                    }
                    .ignoresSafeArea()
                }
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "iphone.landscape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    Text("Please rotate your device")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        router.currentRoute = .illnessList
                    }) {
                        Image(systemName: "chevron.left.circle")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.blue)
                            .opacity(0.85)
                            .padding()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.ignoresSafeArea())
            }
        }
        .onChange(of: menuExpanded) { oldValue, newValue in
            if !newValue { showSettingsPanel = false }
        }
        .onAppear { cameraViewModel.startSession() }
        .onDisappear { cameraViewModel.stopSession() }
    }
}

private struct BottomSliderOverlay: View {
    @Binding var value: Double
    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geo in
                let leftInset = 12 + FloatingMenu.menuWidth + 12
                let rightInset: CGFloat = 12
                HStack(spacing: 0) {
                    Spacer().frame(width: leftInset)
                    GlassSlider(value: $value, width: max(0, geo.size.width - leftInset - rightInset))
                        .frame(height: 32)
                }
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
            }
            .frame(height: 32)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Per-illness tuning panels
private struct IllnessTuningPanel: View {
    @Binding var isPresented: Bool
    let illness: Illness?
    @EnvironmentObject var tuningVM: FilterTuningViewModel

    var body: some View {
        Group {
            switch illness?.filterType {
            case .cataracts:
                CataractsTuningPanel(isPresented: $isPresented)
            case .diabeticRetinopathy:
                RetinopathyTuningPanel(isPresented: $isPresented)
            case .colorBlindnessDeuteranopia:
                DeuteranopiaTuningPanel(isPresented: $isPresented)
            case .astigmatism:
                AstigmatismTuningPanel(isPresented: $isPresented)
            case .glaucoma:
                GlaucomaTuningPanel(isPresented: $isPresented)
            case .macularDegeneration:
                MacularTuningPanel(isPresented: $isPresented)
            default:
                EmptyView()
            }
        }
    }
}

private struct PanelContainer<Content: View>: View {
    let title: String
    @Binding var isPresented: Bool
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: "gearshape")
                    .font(.headline)
                Spacer()
                Button(action: { withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) { isPresented = false } }) {
                    Image(systemName: "xmark.circle.fill").font(.title3).foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 2)
            content
        }
        .padding(14)
        .frame(maxWidth: 340)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.primary.opacity(0.2), lineWidth: 1))
        .shadow(radius: 6, y: 2)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

private struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var decimals: Int = 1
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.subheadline).foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%0.*f", decimals, value)).font(.caption).foregroundColor(.secondary).monospacedDigit()
            }
            Slider(value: $value, in: range).tint(Color.blue.opacity(0.9))
        }
    }
}

private struct CataractsTuningPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var tuningVM: FilterTuningViewModel
    var body: some View {
        PanelContainer(title: "Cataracts", isPresented: $isPresented) {
            SliderRow(title: "Bloom Intensity", value: $tuningVM.cataractsBloomIntensityScale, range: 0...1.5, decimals: 2)
            SliderRow(title: "Bloom Radius", value: $tuningVM.cataractsBloomRadiusScale, range: 0...50, decimals: 0)
            SliderRow(title: "Desaturation", value: $tuningVM.cataractsDesaturationMax, range: 0...0.6, decimals: 2)
            SliderRow(title: "Contrast Drop", value: $tuningVM.cataractsContrastDropMax, range: 0...0.2, decimals: 2)
            HStack { Spacer(); Button("Reset") { tuningVM.resetCataracts() } }
        }
    }
}

private struct RetinopathyTuningPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var tuningVM: FilterTuningViewModel
    var body: some View {
        PanelContainer(title: "Retinopathy", isPresented: $isPresented) {
            SliderRow(title: "Speckle Opacity Max", value: $tuningVM.drSpeckleOpacityMax, range: 0...0.6, decimals: 2)
            SliderRow(title: "Vignette Intensity Base", value: $tuningVM.drVignetteIntensityBase, range: 0...1.0, decimals: 2)
            SliderRow(title: "Vignette Intensity Scale", value: $tuningVM.drVignetteIntensityScale, range: 0...1.5, decimals: 2)
            SliderRow(title: "Vignette Radius Base", value: $tuningVM.drVignetteRadiusBase, range: 0.5...3.0, decimals: 2)
            SliderRow(title: "Vignette Radius Scale", value: $tuningVM.drVignetteRadiusScale, range: 0...3.0, decimals: 2)
            HStack { Spacer(); Button("Reset") { tuningVM.resetRetinopathy() } }
        }
    }
}

private struct DeuteranopiaTuningPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var tuningVM: FilterTuningViewModel
    var body: some View {
        PanelContainer(title: "Deuteranopia", isPresented: $isPresented) {
            SliderRow(title: "Strength", value: $tuningVM.deuteranopiaStrengthMax, range: 0...1.0, decimals: 2)
            HStack { Spacer(); Button("Reset") { tuningVM.resetDeuteranopia() } }
        }
    }
}

private struct AstigmatismTuningPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var tuningVM: FilterTuningViewModel
    var body: some View {
        PanelContainer(title: "Astigmatism", isPresented: $isPresented) {
            SliderRow(title: "Motion Base", value: $tuningVM.astigMotionRadiusBase, range: 0...20, decimals: 1)
            SliderRow(title: "Motion Scale", value: $tuningVM.astigMotionRadiusScale, range: 0...40, decimals: 1)
            SliderRow(title: "Ghost Alpha Base", value: $tuningVM.astigGhostAlphaBase, range: 0...1.0, decimals: 2)
            SliderRow(title: "Ghost Alpha Scale", value: $tuningVM.astigGhostAlphaScale, range: 0...1.0, decimals: 2)
            SliderRow(title: "Angle (deg)", value: $tuningVM.astigAngleDegrees, range: 0...180, decimals: 0)
            HStack { Spacer(); Button("Reset") { tuningVM.resetAstigmatism() } }
        }
    }
}

private struct GlaucomaTuningPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var tuningVM: FilterTuningViewModel
    var body: some View {
        PanelContainer(title: "Glaucoma", isPresented: $isPresented) {
            SliderRow(title: "Inner Radius Scale", value: $tuningVM.glauStartRadiusScale, range: 10...200, decimals: 0)
            SliderRow(title: "Outer Extra Radius", value: $tuningVM.glauEndRadiusExtra, range: 0...200, decimals: 0)
            SliderRow(title: "Outer Radius Scale", value: $tuningVM.glauEndRadiusScale, range: 100...600, decimals: 0)
            SliderRow(title: "Edge Alpha Max", value: $tuningVM.glauEdgeAlphaMax, range: 0...1.0, decimals: 2)
            HStack { Spacer(); Button("Reset") { tuningVM.resetGlaucoma() } }
        }
    }
}

private struct MacularTuningPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var tuningVM: FilterTuningViewModel
    var body: some View {
        PanelContainer(title: "Macular Degeneration", isPresented: $isPresented) {
            SliderRow(title: "Spot Min Radius", value: $tuningVM.mdSpotRadiusMin, range: 0...100, decimals: 0)
            SliderRow(title: "Spot Radius Scale", value: $tuningVM.mdSpotRadiusScale, range: 50...400, decimals: 0)
            SliderRow(title: "Spot Alpha", value: $tuningVM.mdSpotColorAlpha, range: 0...1.0, decimals: 2)
            SliderRow(title: "Spot Inner Factor", value: $tuningVM.mdSpotInnerFactor, range: 0.1...0.9, decimals: 2)
            SliderRow(title: "Blur Base", value: $tuningVM.mdBlurBase, range: 0...20, decimals: 1)
            SliderRow(title: "Blur Scale", value: $tuningVM.mdBlurScale, range: 0...30, decimals: 1)
            SliderRow(title: "Mask Inner Factor", value: $tuningVM.mdMaskInnerFactor, range: 0.05...0.8, decimals: 2)
            HStack { Spacer(); Button("Reset") { tuningVM.resetMacular() } }
        }
    }
}
