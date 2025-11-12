//
//  MainViewModel.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedIllness: Illness?
    @Published var filterEnabled: Bool = true
    @Published var centralFocus: Double = 0.5
    @Published var isCardboardMode: Bool = false
    @Published var vrSettings: VRSettings = .defaults
    @Published var currentRoute: AppRoute = .splash
    
    // MARK: - Illness-specific settings
    @Published var cataractsSettings: CataractsSettings = .defaults
    @Published var glaucomaSettings: GlaucomaSettings = .defaults
    @Published var macularDegenerationSettings: MacularDegenerationSettings = .defaults
    @Published var tunnelVisionSettings: TunnelVisionSettings = .defaults
    @Published var hemianopsiaSettings: HemianopsiaSettings = .defaults
    
    // MARK: - Computed Properties
    var currentIllnessSettings: IllnessSettings? {
        guard let type = selectedIllness?.filterType else { return nil }
        switch type {
        case .cataracts:
            return .cataracts(cataractsSettings)
        case .glaucoma:
            return .glaucoma(glaucomaSettings)
        case .macularDegeneration:
            return .macular(macularDegenerationSettings)
        case .tunnelVision:
            return .tunnel(tunnelVisionSettings)
        case .hemianopsia:
            return .hemianopsia(hemianopsiaSettings)
        }
    }
    
    // MARK: - Navigation
    var navigateToIllnessList: (() -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lista de enfermedades
    let illnesses: [Illness] = [
        Illness(name: "Visión borrosa", description: "Simula visión borrosa por cataratas.", filterType: .cataracts),
        Illness(name: "Reducción periférica", description: "Simula reducción del campo visual periférico por glaucoma.", filterType: .glaucoma),
        Illness(name: "Escotoma central", description: "Simula pérdida de visión central por degeneración macular.", filterType: .macularDegeneration),
        Illness(name: "Hemianopsia", description: "Simula pérdida de visión en la mitad del campo visual.", filterType: .hemianopsia),
        Illness(name: "Visión en túnel", description: "Simula reducción concéntrica del campo visual.", filterType: .tunnelVision)
    ]
    
    // MARK: - Initialization
    init() {
        setupObservers()
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        // Observar cambios en la enfermedad seleccionada para logging
        $selectedIllness
            .sink { illness in
                if let illness = illness {
                    print("🏥 Selected illness: \(illness.name)")
                }
            }
            .store(in: &cancellables)
        
        // Observar cambios en el modo VR
        $isCardboardMode
            .sink { isVR in
                print("📱 VR Mode: \(isVR ? "ON" : "OFF")")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func updateCurrentRoute(_ route: AppRoute) {
        currentRoute = route
        print("📍 Route updated to: \(route)")
    }
    
    func selectIllness(by filterType: IllnessFilterType) {
        let illness: Illness
        switch filterType {
        case .cataracts:
            illness = Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts)
        case .glaucoma:
            illness = Illness(name: "Glaucoma", description: "Simula visión con glaucoma.", filterType: .glaucoma)
        case .macularDegeneration:
            illness = Illness(name: "Macular Degeneration", description: "Simula degeneración macular.", filterType: .macularDegeneration)
        case .tunnelVision:
            illness = Illness(name: "Tunnel Vision", description: "Simula visión en túnel.", filterType: .tunnelVision)
        case .hemianopsia:
            illness = Illness(name: "Hemianopsia", description: "Simula pérdida de visión en la mitad del campo visual.", filterType: .hemianopsia)
        }
        selectedIllness = illness
    }
    
    func increaseIntensity() {
        let oldValue = centralFocus
        centralFocus = min(1.0, centralFocus + 0.3)
        if centralFocus > oldValue {
            print("🔺 Intensity increased to \(String(format: "%.1f", centralFocus))")
        }
    }
    
    func decreaseIntensity() {
        let oldValue = centralFocus
        centralFocus = max(0.0, centralFocus - 0.3)
        if centralFocus < oldValue {
            print("🔻 Intensity decreased to \(String(format: "%.1f", centralFocus))")
        }
    }
    
    func enableFilter() {
        guard !filterEnabled else { return }
        filterEnabled = true
        print("✅ Filter enabled")
    }
    
    func disableFilter() {
        guard filterEnabled else { return }
        filterEnabled = false
        print("❌ Filter disabled")
    }
    
    func enableVRMode() {
        guard !isCardboardMode else { return }
        isCardboardMode = true
        print("🥽 VR mode enabled")
    }
    
    func disableVRMode() {
        guard isCardboardMode else { return }
        isCardboardMode = false
        print("📱 VR mode disabled")
    }
    
    func navigateBack() {
        if currentRoute == .camera {
            navigateToIllnessList?()
            print("🔙 Navigating back to illness list")
        }
    }
    
    func resetAllSettings() {
        cataractsSettings = .defaults
        glaucomaSettings = .defaults
        macularDegenerationSettings = .defaults
        tunnelVisionSettings = .defaults
        hemianopsiaSettings = .defaults
        centralFocus = 0.5
        filterEnabled = true
        print("🔄 All settings reset to defaults")
    }
    
    // MARK: - Cleanup
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
