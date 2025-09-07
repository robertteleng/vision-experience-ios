//
//  CameraView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//
//  This file defines the CameraView, the main camera interface for the app. It manages
<<<<<<< HEAD
//  the display of camera frames, overlays, floating menus, and per-illness tuning panels.
//  The view adapts to device orientation and Cardboard mode, and provides interactive
//  controls for filter tuning and navigation.
=======
//  the display of camera frames, overlays, and the floating menu.
//  The view adapts to device orientation and Cardboard mode, and provides interactive
//  controls for navigation.
>>>>>>> illness-filters-temp

import SwiftUI

/// CameraView is the main camera interface for the app.
<<<<<<< HEAD
/// - Displays camera frames and overlays for filter tuning and illness simulation.
/// - Adapts to device orientation and Cardboard mode.
/// - Provides interactive controls for filter tuning and navigation.
struct CameraView: View {
    /// Provides access to the main application state and selected illness.
    @EnvironmentObject var globalViewModel: MainViewModel
=======
/// - Displays camera frames and overlays for illness simulation.
/// - Adapts to device orientation and Cardboard mode.
/// - Provides interactive controls for navigation.
struct CameraView: View {
    /// Provides access to the main application state and selected illness.
    @EnvironmentObject var mainViewModel: MainViewModel
>>>>>>> illness-filters-temp
    /// Manages camera session and frame updates.
    @StateObject private var cameraViewModel = CameraViewModel()
    /// Controls whether the floating menu is expanded.
    @State private var menuExpanded = false
    /// Observes device orientation changes to adapt the UI.
    @EnvironmentObject var orientationObserver: DeviceOrientationObserver
    /// Indicates whether Cardboard mode is active (stereoscopic view).
    @Binding var isCardboardMode: Bool
    /// Handles navigation between screens.
    @EnvironmentObject var router: AppRouter
    /// Provides access to filter tuning parameters for each illness.
    @EnvironmentObject var tuningVM: FilterTuningViewModel
    /// Controls the visibility of the illness-specific tuning panel.
    @State private var showSettingsPanel = false

    /// Main view body. Renders camera frames, overlays, and interactive controls.
    var body: some View {
        ZStack {
            // Determine if the device is in landscape orientation.
            let isLandscape = orientationObserver.orientation.isLandscape
            if isLandscape {
                // Cardboard mode: render stereoscopic left/right panels.
                if isCardboardMode {
                    ZStack {
                        // Capa de imagen con efecto estereoscópico
                        CardboardView(
                            cameraService: cameraViewModel.cameraService,
                            illness: mainViewModel.selectedIllness,
                            centralFocus: mainViewModel.centralFocus,
                            filterEnabled: mainViewModel.filterEnabled,
                            illnessSettings: mainViewModel.currentIllnessSettings,
                            deviceOrientation: orientationObserver.orientation
                        )
<<<<<<< HEAD
                        // Floating menu overlay for filter tuning and settings.
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
                        // Slider overlay for central focus adjustment.
                        if menuExpanded {
                            BottomSliderOverlay(value: $globalViewModel.centralFocus)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .zIndex(1)
                        }
                        // Illness-specific tuning panel overlay.
                        if showSettingsPanel {
                            IllnessTuningPanel(isPresented: $showSettingsPanel, illness: globalViewModel.selectedIllness)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .padding(.trailing, 12)
                                .padding(.bottom, 12)
                                .zIndex(3)
                        }
=======
                        .ignoresSafeArea() // solo la imagen ignora safe area

                        // Floating menu overlay (respeta safe area)
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded)
                                .padding(.leading, 16)
                                .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .zIndex(2)
>>>>>>> illness-filters-temp
                    }
                } else {
                    // Standard camera view (single panel).
                    ZStack {
<<<<<<< HEAD
                        CameraImageView(
                            image: cameraViewModel.cameraService.currentFrame,
                            panel: .full,
                            illness: globalViewModel.selectedIllness,
                            centralFocus: globalViewModel.centralFocus
                        )
                        .ignoresSafeArea()
                        // Floating menu and slider overlays.
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
                        // Illness-specific tuning panel overlay.
                        if showSettingsPanel {
                            IllnessTuningPanel(isPresented: $showSettingsPanel, illness: globalViewModel.selectedIllness)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                .padding(.trailing, 12)
                                .padding(.bottom, 12)
                                .zIndex(3)
                        }
=======
                        // Capa de imagen con filtros (rotación corregida en CameraImageView)
                        CameraImageView(
                            image: cameraViewModel.cameraService.currentFrame,
                            panel: .full,
                            illness: mainViewModel.selectedIllness,
                            centralFocus: mainViewModel.centralFocus,
                            filterEnabled: mainViewModel.filterEnabled,
                            illnessSettings: mainViewModel.currentIllnessSettings
                        )
                        .ignoresSafeArea() // solo la imagen ignora safe area

                        // Floating menu overlay (respeta safe area)
                        VStack {
                            Spacer()
                            FloatingMenu(expanded: $menuExpanded)
                                .padding(.leading, 16)
                                .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .zIndex(2)
>>>>>>> illness-filters-temp
                    }
                }
            } else {
                // Portrait mode: prompt user to rotate device for camera experience.
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
                        // Removed UIKit feedback, use SwiftUI haptics
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
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
<<<<<<< HEAD
        // Hide tuning panel when menu is collapsed.
        .onChange(of: menuExpanded) { oldValue, newValue in
            if !newValue { showSettingsPanel = false }
        }
        // Start camera session when view appears.
        .onAppear { cameraViewModel.startSession() }
        // Stop camera session when view disappears.
        .onDisappear { cameraViewModel.stopSession() }
    }
}

// MARK: - Overlay and Tuning Panel Components

/// BottomSliderOverlay displays a slider for adjusting the central focus value.
private struct BottomSliderOverlay: View {
    /// Binding to the central focus value.
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

/// IllnessTuningPanel displays the appropriate tuning panel for the selected illness.
private struct IllnessTuningPanel: View {
    /// Controls panel presentation.
    @Binding var isPresented: Bool
    /// The selected illness for tuning.
    let illness: Illness?
    /// Provides access to tuning parameters.
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

/// PanelContainer provides a styled container for tuning panels.
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

/// SliderRow displays a labeled slider for a tuning parameter.
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

// MARK: - Individual illness tuning panels

/// CataractsTuningPanel provides sliders for cataracts filter parameters.
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

/// RetinopathyTuningPanel provides sliders for diabetic retinopathy filter parameters.
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

/// DeuteranopiaTuningPanel provides sliders for color blindness filter parameters.
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

/// AstigmatismTuningPanel provides sliders for astigmatism filter parameters.
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

/// GlaucomaTuningPanel provides sliders for glaucoma filter parameters.
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

/// MacularTuningPanel provides sliders for macular degeneration filter parameters.
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
=======
        // Start camera session when view appears.
        .onAppear {
            cameraViewModel.startSession()
        }
        // Stop camera session when view disappears.
        .onDisappear { cameraViewModel.stopSession() }
    }
}

#Preview {
    CameraView(isCardboardMode: .constant(false))
        .environmentObject(MainViewModel())
        .environmentObject(AppRouter())
        .environmentObject(DeviceOrientationObserver.shared)
}

>>>>>>> illness-filters-temp
