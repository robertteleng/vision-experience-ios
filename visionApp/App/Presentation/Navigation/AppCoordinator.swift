//
//  AppCoordinator.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 15/9/25.
//
//  Coordinador principal que maneja la inyección de dependencias
//  y la comunicación entre ViewModels siguiendo el patrón MVVM + Coordinator
//

import SwiftUI
import Combine

class AppCoordinator: ObservableObject, SpeechRecognitionDelegate {
    // MARK: - ViewModels
    @Published var mainViewModel: MainViewModel
    @Published var speechViewModel: SpeechRecognitionViewModel
    @Published var router: AppRouter
    @Published var orientationObserver: DeviceOrientationObserver
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Inicializar dependencias
        self.mainViewModel = MainViewModel()
        self.speechViewModel = SpeechRecognitionViewModel()
        self.router = AppRouter()
        self.orientationObserver = DeviceOrientationObserver.shared
        
        // Configurar conexiones
        setupConnections()
        setupSpeechIntegration()
        setupRouteManagement()
    }
    
    // MARK: - Setup Methods
    
    private func setupConnections() {
        // Conectar speech recognition delegate
        speechViewModel.delegate = self
        
        // Configurar navegación
        mainViewModel.navigateToIllnessList = { [weak self] in
            self?.router.currentRoute = .illnessList
        }
        
        print("🔗 App coordinator connections established")
    }
    
    private func setupSpeechIntegration() {
        // Sincronizar contexto del speech con la ruta actual
        router.$currentRoute
            .sink { [weak self] route in
                let appRoute: AppRoute = {
                    switch route {
                    case .splash: return .splash
                    case .illnessList: return .illnessList
                    case .camera: return .camera
                    case .home: return .home
                    case .immersiveVideo: return .immersiveVideo
                    }
                }()
                self?.mainViewModel.updateCurrentRoute(appRoute)
                self?.speechViewModel.updateContext(appRoute)
                self?.handleSpeechActivation(for: appRoute)
            }
            .store(in: &cancellables)
        
        // Observar cambios en modo VR para speech
        mainViewModel.$isCardboardMode
            .sink { [weak self] _ in
                self?.handleSpeechActivation(for: self?.mainViewModel.currentRoute ?? .splash)
            }
            .store(in: &cancellables)
        
        // Observar cambios de orientación
        orientationObserver.$orientation
            .sink { [weak self] _ in
                self?.handleSpeechActivation(for: self?.mainViewModel.currentRoute ?? .splash)
            }
            .store(in: &cancellables)
    }
    
    private func setupRouteManagement() {
        // Auto-navegación cuando se selecciona enfermedad
        mainViewModel.$selectedIllness
            .sink { [weak self] illness in
                if illness != nil && self?.router.currentRoute == .illnessList {
                    self?.router.currentRoute = .camera
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Speech Activation Logic
    
    private func handleSpeechActivation(for route: AppRoute) {
        let shouldListen: Bool = {
            switch route {
            case .splash:
                return false // No speech en splash
            case .illnessList:
                return true // Siempre activo para selección
            case .camera:
                return true // Siempre activo en cámara (VR o normal)
            case .home:
                return false // No speech en home
            case .immersiveVideo:
                return false // No speech en video inmersivo
            }
        }()
        
        if shouldListen && !speechViewModel.isListening {
            print("🎤 Activating speech for route: \(route)")
            speechViewModel.startListening()
        } else if !shouldListen && speechViewModel.isListening {
            print("🛑 Deactivating speech for route: \(route)")
            speechViewModel.stopListening()
        }
    }
    
    // MARK: - SpeechRecognitionDelegate
    
    func speechRecognition(didDetectCommand command: VoiceCommand) {
        print("🗣️ Command received: \(command)")
        
        switch command {
        case .selectIllness(let filterType):
            mainViewModel.selectIllness(by: filterType)
            
        case .increaseIntensity:
            mainViewModel.increaseIntensity()
            
        case .decreaseIntensity:
            mainViewModel.decreaseIntensity()
            
        case .enableFilter:
            mainViewModel.enableFilter()
            
        case .disableFilter:
            mainViewModel.disableFilter()
            
        case .enableVR:
            mainViewModel.enableVRMode()
            
        case .disableVR:
            mainViewModel.disableVRMode()
            
        case .navigateBack:
            mainViewModel.navigateBack()
            
        case .requestHelp:
            // El speech viewmodel ya maneja el feedback de ayuda
            break
        }
    }
    
    // MARK: - Public Methods
    
    func startApp() {
        print("🚀 Starting app with coordinator pattern")
        // La activación automática de speech se maneja en setupSpeechIntegration
    }
    
    func simulateVoiceCommand(_ text: String) {
        speechViewModel.simulateCommand(text)
    }
    
    // MARK: - Cleanup
    
    deinit {
        speechViewModel.stopListening()
        cancellables.forEach { $0.cancel() }
    }
}
