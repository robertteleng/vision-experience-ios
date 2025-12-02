# 🏗️ visionApp - Arquitectura Técnica Detallada

> Documentación técnica completa de la arquitectura, patrones de diseño y flujos de datos

---

## 📋 Índice

- [Overview de Arquitectura](#overview-de-arquitectura)
- [Capa de Presentación](#capa-de-presentación)
- [Capa de Dominio](#capa-de-dominio)
- [Capa de Servicios](#capa-de-servicios)
- [Flujos de Datos](#flujos-de-datos)
- [Patrones de Diseño](#patrones-de-diseño)
- [Gestión de Estado](#gestión-de-estado)
- [Procesamiento de Imagen](#procesamiento-de-imagen)
- [Ciclo de Vida](#ciclo-de-vida)

---

## Overview de Arquitectura

### Arquitectura en Capas

```mermaid
graph TB
    subgraph "UI Layer - SwiftUI"
        V1[MainView]
        V2[SplashView]
        V3[IllnessListView]
        V4[CameraView]
        V5[CardboardView]
        V6[Components]
    end
    
    subgraph "Presentation Layer - ViewModels"
        VM1[MainViewModel]
        VM2[CameraViewModel]
        VM3[FilterTuningViewModel]
        VM4[SpeechRecognitionViewModel]
    end
    
    subgraph "Domain Layer - Business Logic"
        D1[Illness]
        D2[FilterSettings]
        D3[IllnessSettings]
        D4[IllnessFilterType]
        D5[VRSettings]
    end
    
    subgraph "Service Layer - Infrastructure"
        S1[CameraService]
        S2[SpeechRecognitionService]
        S3[CIProcessor]
        S4[DeviceOrientationObserver]
    end
    
    subgraph "Foundation - iOS Frameworks"
        F1[AVFoundation]
        F2[Speech]
        F3[CoreImage]
        F4[SwiftUI]
        F5[Combine]
    end
    
    V1 --> VM1
    V4 --> VM2
    V6 --> VM3
    
    VM1 --> D1
    VM1 --> D2
    VM2 --> S1
    VM1 --> S2
    
    S1 --> F1
    S2 --> F2
    S3 --> F3
    VM1 --> F5
    
    D2 --> D3
    D1 --> D4
    
    style V1 fill:#4A90E2
    style VM1 fill:#7B68EE
    style D1 fill:#50C878
    style S1 fill:#FF6B6B
    style F1 fill:#FFA500
```

### Clean Architecture Aplicada

```mermaid
graph LR
    subgraph "Entities"
        E[Domain Models]
    end
    
    subgraph "Use Cases"
        U[Business Logic<br/>ViewModels]
    end
    
    subgraph "Interface Adapters"
        I[Views<br/>Coordinators]
    end
    
    subgraph "Frameworks & Drivers"
        F[Services<br/>iOS APIs]
    end
    
    E --> U
    U --> I
    I --> F
    
    style E fill:#50C878
    style U fill:#7B68EE
    style I fill:#4A90E2
    style F fill:#FF6B6B
```

---

## Capa de Presentación

### Jerarquía de Vistas

```mermaid
graph TD
    App[visionApp.swift<br/>@main] --> Main[MainView<br/>NavigationView]
    
    Main --> Router{AppRouter<br/>currentRoute}
    
    Router -->|.splash| Splash[SplashView<br/>Lottie Animation]
    Router -->|.home| Home[HomeView<br/>Main Menu]
    Router -->|.illnessList| List[IllnessListView<br/>Disease Selection]
    Router -->|.camera| Camera[CameraView<br/>Live Simulation]
    Router -->|.immersiveVideo| Immersive[ImmersiveVideoView<br/>360° Experience]
    
    Camera --> Mode{Cardboard Mode?}
    Mode -->|Yes| Cardboard[CardboardView<br/>Stereo Panels]
    Mode -->|No| Normal[CameraImageView<br/>Full Screen]
    
    Camera --> Menu[FloatingMenu<br/>Controls]
    Menu --> Filters[CompactFiltersPanel]
    Menu --> Sliders[GlassSlider]
    
    Cardboard --> Left[CameraImageView<br/>Left Panel]
    Cardboard --> Right[CameraImageView<br/>Right Panel]
    
    style App fill:#4A90E2
    style Camera fill:#FF6B6B
    style Menu fill:#50C878
```

### ViewModels y Responsabilidades

```mermaid
classDiagram
    class MainViewModel {
        +selectedIllness: Illness?
        +filterEnabled: Bool
        +centralFocus: Double
        +isCardboardMode: Bool
        +isSpeechEnabled: Bool
        +cataractsSettings: CataractsSettings
        +glaucomaSettings: GlaucomaSettings
        +macularSettings: MacularSettings
        +tunnelSettings: TunnelSettings
        +currentIllnessSettings: IllnessSettings
        +speak(String)
        -setupSpeechBinding()
    }
    
    class CameraViewModel {
        +currentFrame: CGImage?
        +error: CameraError?
        +cameraService: CameraService
        +startCamera()
        +stopCamera()
        -handleFrame(CGImage)
        -handleError(Error)
    }
    
    class FilterTuningViewModel {
        +cataractsSettings: CataractsSettings
        +glaucomaSettings: GlaucomaSettings
        +macularSettings: MacularSettings
        +tunnelSettings: TunnelSettings
        +resetToDefaults()
        +applyPreset(String)
    }
    
    class SpeechRecognitionViewModel {
        +isListening: Bool
        +lastCommand: String
        +startListening()
        +stopListening()
        +processCommand(String)
    }
    
    MainViewModel --> SpeechRecognitionViewModel
    CameraViewModel --> CameraService
    FilterTuningViewModel ..> MainViewModel : updates
    
    style MainViewModel fill:#7B68EE
    style CameraViewModel fill:#FF6B6B
    style FilterTuningViewModel fill:#50C878
```

### Ciclo de Vida de CameraView

```mermaid
sequenceDiagram
    participant V as CameraView
    participant VM as CameraViewModel
    participant CS as CameraService
    participant CI as CIProcessor
    participant UI as Display
    
    V->>VM: onAppear
    VM->>CS: startSession()
    CS->>CS: Configure AVCaptureSession
    CS->>CS: Start capture
    
    loop Frame Capture
        CS->>CS: captureOutput(sampleBuffer)
        CS->>CS: Convert to CGImage
        CS->>VM: publish(currentFrame)
        VM->>V: Update @Published
        V->>CI: apply(filter, settings)
        CI->>CI: Process with Core Image
        CI->>UI: Display processed frame
    end
    
    V->>VM: onDisappear
    VM->>CS: stopSession()
    CS->>CS: Stop capture
```

---

## Capa de Dominio

### Modelo de Datos

```mermaid
classDiagram
    class Illness {
        +id: UUID
        +name: String
        +description: String
        +filterType: IllnessFilterType
    }
    
    class IllnessFilterType {
        <<enumeration>>
        cataracts
        glaucoma
        macularDegeneration
        tunnelVision
        hemianopsia
        diabeticRetinopathy
        colorBlindness
        astigmatism
    }
    
    class IllnessSettings {
        +filterType: IllnessFilterType
        +cataractsSettings: CataractsSettings?
        +glaucomaSettings: GlaucomaSettings?
        +macularSettings: MacularSettings?
        +tunnelSettings: TunnelSettings?
        +hemianopsiaSettings: HemianopsiaSettings?
    }
    
    class CataractsSettings {
        +blurRadius: Double
        +contrastReduction: Double
        +saturationReduction: Double
        +blueReduction: Double
        +defaults: CataractsSettings
    }
    
    class GlaucomaSettings {
        +vignetteIntensity: Double
        +vignetteRadiusFactor: Double
        +effectRadiusFactor: Double
        +defaults: GlaucomaSettings
    }
    
    class MacularDegenerationSettings {
        +innerRadius: Double
        +outerRadiusFactor: Double
        +blurRadius: Double
        +darkAlpha: Double
        +twirlAngle: Double
        +defaults: MacularDegenerationSettings
    }
    
    class TunnelVisionSettings {
        +minRadiusPercent: Double
        +maxRadiusFactor: Double
        +blurRadius: Double
        +featherFactorBase: Double
        +defaults: TunnelVisionSettings
    }
    
    class HemianopsiaSettings {
        +leftSideAffected: Bool
        +featherFactor: Double
        +defaults: HemianopsiaSettings
    }
    
    Illness --> IllnessFilterType
    IllnessSettings --> IllnessFilterType
    IllnessSettings --> CataractsSettings
    IllnessSettings --> GlaucomaSettings
    IllnessSettings --> MacularDegenerationSettings
    IllnessSettings --> TunnelVisionSettings
    IllnessSettings --> HemianopsiaSettings
    
    style Illness fill:#50C878
    style IllnessFilterType fill:#4A90E2
    style IllnessSettings fill:#7B68EE
```

### Patrón Settings por Enfermedad

```mermaid
graph LR
    A[MainViewModel] -->|filterType| B{IllnessSettings}
    
    B -->|.cataracts| C[CataractsSettings]
    B -->|.glaucoma| D[GlaucomaSettings]
    B -->|.macularDegeneration| E[MacularSettings]
    B -->|.tunnelVision| F[TunnelSettings]
    B -->|.hemianopsia| G[HemianopsiaSettings]
    
    C --> H[CIProcessor]
    D --> H
    E --> H
    F --> H
    G --> H
    
    H --> I[Filtered CGImage]
    
    style A fill:#7B68EE
    style B fill:#50C878
    style H fill:#9370DB
    style I fill:#FF6B6B
```

---

## Capa de Servicios

### CameraService - Arquitectura

```mermaid
graph TB
    subgraph "CameraService"
        Init[init]
        Setup[setupCaptureSession]
        Start[startSession]
        Output[captureOutput]
        Stop[stopSession]
    end
    
    subgraph "AVFoundation"
        Device[AVCaptureDevice]
        Session[AVCaptureSession]
        Input[AVCaptureDeviceInput]
        VideoOutput[AVCaptureVideoDataOutput]
    end
    
    subgraph "Published Properties"
        Frame[currentFrame: CGImage]
        Error[error: CameraError]
    end
    
    subgraph "Subscribers"
        VM[CameraViewModel]
        View[CameraView]
    end
    
    Init --> Setup
    Setup --> Device
    Setup --> Session
    Setup --> Input
    Setup --> VideoOutput
    
    Start --> Session
    Session --> Output
    Output --> Frame
    Output --> Error
    
    Frame --> VM
    Error --> VM
    VM --> View
    
    Stop --> Session
    
    style CameraService fill:#FF6B6B
    style AVFoundation fill:#FFA500
    style Published fill:#50C878
```

### SpeechRecognitionService - Flujo

```mermaid
sequenceDiagram
    participant App as App
    participant SRS as SpeechService
    participant SF as SFSpeechRecognizer
    participant AE as AVAudioEngine
    participant VM as MainViewModel
    
    App->>SRS: requestAuthorization()
    SRS->>SF: requestAuthorization()
    SF-->>SRS: .authorized
    
    App->>SRS: startRecognition()
    SRS->>AE: Start audio engine
    SRS->>SF: recognitionTask(with: request)
    
    loop Audio Processing
        AE->>SF: Audio buffer
        SF->>SRS: Recognition result
        SRS->>SRS: Extract command
        SRS->>VM: publish(lastCommand)
        VM->>VM: Parse command
        VM->>VM: Execute action
        VM->>App: Update state
    end
    
    App->>SRS: stopRecognition()
    SRS->>AE: Stop audio engine
    SRS->>SF: Cancel task
```

### CIProcessor - Pipeline de Filtros

```mermaid
flowchart TD
    Input[CGImage Input] --> Context[CIContext]
    Context --> CIImg[CIImage]
    
    CIImg --> Switch{Filter Type}
    
    Switch -->|Cataracts| Cat[Gaussian Blur]
    Cat --> Cat2[Contrast Adjust]
    Cat2 --> Cat3[Saturation Adjust]
    Cat3 --> Cat4[Color Matrix<br/>Yellow Tint]
    
    Switch -->|Glaucoma| Gla[Vignette Effect]
    Gla --> Gla2[Radial Gradient]
    Gla2 --> Gla3[Composite]
    
    Switch -->|Macular| Mac[Radial Gradient<br/>Center]
    Mac --> Mac2[Gaussian Blur<br/>Central]
    Mac2 --> Mac3[Twirl Distortion]
    Mac3 --> Mac4[Dark Overlay]
    
    Switch -->|Tunnel| Tun[Radial Gradient<br/>Inverted]
    Tun --> Tun2[Gaussian Blur<br/>Peripheral]
    Tun2 --> Tun3[Composite Mask]
    
    Switch -->|Hemianopsia| Hem[Linear Gradient<br/>Half Field]
    Hem --> Hem2[Black Overlay]
    Hem2 --> Hem3[Feather Edge]
    
    Cat4 --> Output[CGImage Output]
    Gla3 --> Output
    Mac4 --> Output
    Tun3 --> Output
    Hem3 --> Output
    
    style Input fill:#4A90E2
    style Switch fill:#50C878
    style Output fill:#FF6B6B
    style Context fill:#9370DB
```

---

## Flujos de Datos

### Flujo de Datos Principal (Combine)

```mermaid
graph TB
    subgraph "Publishers"
        CS[CameraService<br/>@Published currentFrame]
        SS[SpeechService<br/>@Published lastCommand]
        DO[DeviceOrientation<br/>@Published orientation]
    end
    
    subgraph "ViewModels (Subscribers)"
        CVM[CameraViewModel<br/>sink + assign]
        MVM[MainViewModel<br/>sink + process]
    end
    
    subgraph "Views (Observers)"
        CV[CameraView<br/>@ObservedObject]
        MV[MainView<br/>@EnvironmentObject]
    end
    
    subgraph "State Updates"
        U1[UI Redraw]
        U2[Filter Apply]
        U3[Navigation Change]
    end
    
    CS -->|Combine| CVM
    SS -->|Combine| MVM
    DO -->|NotificationCenter| MVM
    
    CVM --> CV
    MVM --> MV
    
    CV --> U1
    CV --> U2
    MV --> U3
    
    style CS fill:#FF6B6B
    style CVM fill:#7B68EE
    style CV fill:#4A90E2
    style U2 fill:#50C878
```

### Flujo de Reconocimiento de Voz

```mermaid
flowchart TD
    A[Usuario pronuncia comando] --> B[AVAudioEngine captura audio]
    B --> C[SFSpeechRecognizer procesa]
    C --> D[Extrae texto del comando]
    
    D --> E{Tipo de Comando}
    
    E -->|Enfermedad| F[Parse illness name]
    F --> F1[Update selectedIllness]
    F1 --> F2[Navigate to camera]
    F2 --> F3[Apply filter]
    F3 --> Z[Feedback]
    
    E -->|Intensidad| G[Parse intensity word]
    G --> G1[Calculate delta ±20%]
    G1 --> G2[Update centralFocus]
    G2 --> G3[Reprocess frame]
    G3 --> Z
    
    E -->|Toggle| H[Parse on/off]
    H --> H1[Toggle filterEnabled]
    H1 --> H2[Show/hide effect]
    H2 --> Z
    
    E -->|Exit| I[Parse exit command]
    I --> I1[Set isCardboardMode false]
    I1 --> I2[Navigate back]
    I2 --> Z
    
    Z --> Z1[Haptic feedback]
    Z --> Z2[TTS response]
    Z --> Z3[Visual update]
    
    style A fill:#4A90E2
    style D fill:#50C878
    style Z fill:#FF6B6B
```

### Flujo de Procesamiento de Frame

```mermaid
sequenceDiagram
    participant Cam as Camera Hardware
    participant AVF as AVFoundation
    participant CS as CameraService
    participant VM as CameraViewModel
    participant V as CameraView
    participant CI as CIProcessor
    participant GPU as Metal/GPU
    participant Screen as Display
    
    Cam->>AVF: Capture frame
    AVF->>CS: captureOutput(sampleBuffer)
    CS->>CS: Convert CMSampleBuffer
    CS->>CS: Create CGImage
    
    CS->>VM: Publish currentFrame
    Note over CS,VM: Combine pipeline
    
    VM->>V: State update
    V->>V: body recomputes
    
    alt Filter Enabled
        V->>CI: apply(illness, settings, image)
        CI->>GPU: CIContext render
        GPU->>CI: Processed CGImage
        CI->>V: Return filtered image
    else Filter Disabled
        V->>V: Use original frame
    end
    
    V->>Screen: Image(decorative: cgImage)
    Screen->>Screen: Display to user
    
    Note over Cam,Screen: ~60 FPS (16.67ms per frame)
```

---

## Patrones de Diseño

### 1. MVVM (Model-View-ViewModel)

```mermaid
graph LR
    subgraph "View"
        V[CameraView<br/>SwiftUI]
    end
    
    subgraph "ViewModel"
        VM[CameraViewModel<br/>ObservableObject]
    end
    
    subgraph "Model"
        M[Illness<br/>FilterSettings]
    end
    
    subgraph "Service"
        S[CameraService]
    end
    
    V -->|Binding| VM
    VM -->|Published| V
    VM --> M
    VM --> S
    
    style V fill:#4A90E2
    style VM fill:#7B68EE
    style M fill:#50C878
    style S fill:#FF6B6B
```

### 2. Coordinator Pattern (Navegación)

```mermaid
classDiagram
    class AppRouter {
        +currentRoute: AppRoute
        +navigate(to: AppRoute)
        +push(route: AppRoute)
        +pop()
    }
    
    class AppRoute {
        <<enumeration>>
        splash
        home
        illnessList
        camera
        immersiveVideo
    }
    
    class MainView {
        @EnvironmentObject router: AppRouter
        body: some View
    }
    
    class IllnessListView {
        @EnvironmentObject router: AppRouter
        selectIllness()
    }
    
    class CameraView {
        @EnvironmentObject router: AppRouter
        navigateBack()
    }
    
    AppRouter --> AppRoute
    MainView --> AppRouter
    IllnessListView --> AppRouter
    CameraView --> AppRouter
    
    style AppRouter fill:#7B68EE
    style AppRoute fill:#50C878
```

### 3. Observer Pattern (Combine)

```mermaid
graph TB
    subgraph "Observable"
        P1[@Published var currentFrame]
        P2[@Published var lastCommand]
        P3[@Published var selectedIllness]
    end
    
    subgraph "Observers"
        O1[CameraView]
        O2[MainViewModel]
        O3[FloatingMenu]
    end
    
    subgraph "Actions"
        A1[UI Update]
        A2[Parse Command]
        A3[Apply Filter]
    end
    
    P1 -->|objectWillChange| O1
    P2 -->|objectWillChange| O2
    P3 -->|objectWillChange| O3
    
    O1 --> A1
    O2 --> A2
    O3 --> A3
    
    style P1 fill:#FF6B6B
    style O1 fill:#4A90E2
    style A1 fill:#50C878
```

### 4. Strategy Pattern (Filtros)

```mermaid
classDiagram
    class CIProcessor {
        <<singleton>>
        +apply(illness, settings, image) CGImage?
        -applyCataracts() CGImage?
        -applyGlaucoma() CGImage?
        -applyMacular() CGImage?
        -applyTunnel() CGImage?
    }
    
    class FilterStrategy {
        <<interface>>
        +apply(to: CGImage, settings: Settings) CGImage?
    }
    
    class CataractsStrategy {
        +apply(to: CGImage, settings: CataractsSettings)
    }
    
    class GlaucomaStrategy {
        +apply(to: CGImage, settings: GlaucomaSettings)
    }
    
    class MacularStrategy {
        +apply(to: CGImage, settings: MacularSettings)
    }
    
    CIProcessor ..> FilterStrategy
    FilterStrategy <|.. CataractsStrategy
    FilterStrategy <|.. GlaucomaStrategy
    FilterStrategy <|.. MacularStrategy
    
    style CIProcessor fill:#9370DB
    style FilterStrategy fill:#50C878
```

### 5. Dependency Injection (EnvironmentObject)

```mermaid
graph TD
    App[visionApp.swift] -->|inject| E1[@EnvironmentObject router]
    App -->|inject| E2[@EnvironmentObject mainViewModel]
    App -->|inject| E3[@EnvironmentObject orientationObserver]
    App -->|inject| E4[@EnvironmentObject filterTuningVM]
    
    E1 --> V1[MainView]
    E2 --> V1
    E3 --> V1
    E4 --> V1
    
    V1 --> V2[CameraView]
    V1 --> V3[IllnessListView]
    V1 --> V4[SplashView]
    
    E1 --> V2
    E2 --> V2
    E3 --> V2
    E4 --> V2
    
    style App fill:#4A90E2
    style E1 fill:#7B68EE
    style V1 fill:#50C878
```

---

## Gestión de Estado

### Estado Global (MainViewModel)

```mermaid
graph TB
    subgraph "User Interactions"
        UI1[Select Illness]
        UI2[Toggle Filter]
        UI3[Adjust Slider]
        UI4[Voice Command]
        UI5[Toggle VR Mode]
    end
    
    subgraph "MainViewModel State"
        S1[selectedIllness: Illness?]
        S2[filterEnabled: Bool]
        S3[centralFocus: Double]
        S4[isCardboardMode: Bool]
        S5[cataractsSettings]
        S6[glaucomaSettings]
        S7[macularSettings]
        S8[tunnelSettings]
    end
    
    subgraph "Derived State"
        D1[currentIllnessSettings]
        D2[shouldShowVRButton]
        D3[isLandscape]
    end
    
    subgraph "Side Effects"
        E1[Navigate to Camera]
        E2[Apply Filter]
        E3[Update UI]
        E4[TTS Feedback]
        E5[Haptic Feedback]
    end
    
    UI1 --> S1
    UI2 --> S2
    UI3 --> S3
    UI4 --> S1
    UI4 --> S2
    UI5 --> S4
    
    S1 --> D1
    S4 --> D2
    
    S1 --> E1
    S2 --> E2
    S3 --> E3
    UI4 --> E4
    UI4 --> E5
    
    style MainViewModel fill:#7B68EE
    style Derived fill:#50C878
    style Side fill:#FF6B6B
```

### Estado Local (CameraViewModel)

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Configuring: startCamera()
    Configuring --> Ready: Session configured
    Configuring --> Error: Configuration failed
    
    Ready --> Capturing: Session started
    Capturing --> Ready: Frame received
    Capturing --> Error: Capture failed
    
    Error --> Idle: Reset
    Capturing --> Stopped: stopCamera()
    Stopped --> [*]
    
    note right of Capturing
        Publishes currentFrame
        ~60 FPS
    end note
    
    note right of Error
        Publishes CameraError
        Shows error UI
    end note
```

---

## Procesamiento de Imagen

### Core Image Pipeline Detallado

```mermaid
flowchart TD
    Start[CGImage from Camera] --> CI1[CIImage cgImage]
    
    CI1 --> Check{Filter Type?}
    
    Check -->|Cataracts| C1[CIFilter.gaussianBlur<br/>radius: blurRadius]
    C1 --> C2[CIFilter.colorControls<br/>contrast: -contrastReduction<br/>saturation: -saturationReduction]
    C2 --> C3[CIFilter.colorMatrix<br/>blue: -blueReduction]
    C3 --> End
    
    Check -->|Glaucoma| G1[CIFilter.vignette<br/>intensity: vignetteIntensity<br/>radius: vignetteRadiusFactor]
    G1 --> G2[CIFilter.radialGradient<br/>center: image.center<br/>radius: effectRadius]
    G2 --> G3[CIFilter.blendWithMask]
    G3 --> End
    
    Check -->|Macular| M1[CIFilter.radialGradient<br/>innerRadius<br/>outerRadius]
    M1 --> M2[CIFilter.gaussianBlur<br/>radius: blurRadius]
    M2 --> M3[CIFilter.twirlDistortion<br/>center: image.center<br/>angle: twirlAngle]
    M3 --> M4[CIFilter.multiply<br/>black overlay: darkAlpha]
    M4 --> End
    
    Check -->|Tunnel| T1[CIFilter.radialGradient<br/>minRadius: minRadiusPercent<br/>maxRadius: maxRadiusFactor]
    T1 --> T2[CIFilter.gaussianBlur<br/>radius: blurRadius]
    T2 --> T3[CIFilter.blendWithMask<br/>feather: featherFactorBase]
    T3 --> End
    
    Check -->|Hemianopsia| H1[CIFilter.linearGradient<br/>side: leftSideAffected]
    H1 --> H2[CIFilter.multiply<br/>black half]
    H2 --> H3[CIFilter.gaussianBlur<br/>feather: featherFactor]
    H3 --> End
    
    End[CIContext.createCGImage] --> Output[CGImage Output]
    
    style Start fill:#4A90E2
    style Check fill:#50C878
    style End fill:#9370DB
    style Output fill:#FF6B6B
```

### Performance Optimization

```mermaid
graph TB
    subgraph "Optimization Strategies"
        O1[Metal CIContext<br/>GPU Acceleration]
        O2[Image Downsampling<br/>For Heavy Filters]
        O3[Filter Caching<br/>Reuse CIFilter Instances]
        O4[Combine Operators<br/>debounce/throttle]
        O5[Background Queue<br/>Async Processing]
    end
    
    subgraph "Metrics"
        M1[Target: 60 FPS]
        M2[Frame Budget: 16.67ms]
        M3[Filter Time: <10ms]
        M4[UI Update: <6ms]
    end
    
    O1 --> M3
    O2 --> M3
    O3 --> M3
    O4 --> M2
    O5 --> M2
    
    M3 --> M1
    M4 --> M1
    M2 --> M1
    
    style O1 fill:#FF6B6B
    style M1 fill:#50C878
```

---

## Ciclo de Vida

### App Lifecycle

```mermaid
sequenceDiagram
    participant System as iOS System
    participant App as visionApp
    participant Router as AppRouter
    participant VM as MainViewModel
    participant Camera as CameraService
    participant Speech as SpeechService
    
    System->>App: Launch
    App->>Router: Initialize (currentRoute = .home)
    App->>VM: Initialize (inject services)
    App->>App: Setup EnvironmentObjects
    
    App->>Router: Navigate to .splash
    Router->>App: Show SplashView
    
    Note over App: 2 second animation
    
    Router->>Router: Auto-navigate to .illnessList
    
    User->>App: Select illness
    VM->>VM: Update selectedIllness
    Router->>Router: Navigate to .camera
    
    App->>Camera: startSession()
    Camera->>Camera: Configure AVFoundation
    Camera->>Camera: Start capturing
    
    User->>App: Toggle Cardboard mode
    VM->>VM: Set isCardboardMode = true
    VM->>Speech: startRecognition()
    
    User->>Speech: Voice command
    Speech->>VM: Publish lastCommand
    VM->>VM: Process command
    VM->>App: Update UI
    
    User->>App: Navigate back
    Router->>Router: Pop to .illnessList
    Camera->>Camera: stopSession()
    Speech->>Speech: stopRecognition()
    
    System->>App: Background
    App->>Camera: Stop session
    App->>Speech: Stop recognition
    
    System->>App: Foreground
    App->>Camera: Restart session
```

### Memory Management

```mermaid
graph TB
    subgraph "Strong References"
        App[visionApp] --> Router[AppRouter]
        App --> MainVM[MainViewModel]
        MainVM --> SpeechService[SpeechRecognitionService]
    end
    
    subgraph "Weak References"
        MainVM -.weak.-> Callback[navigateToIllnessList closure]
        SpeechService -.weak.-> MainVM
    end
    
    subgraph "StateObject (Owned)"
        CameraView --> CameraVM[CameraViewModel]
        CameraVM --> CameraService[CameraService]
    end
    
    subgraph "EnvironmentObject (Shared)"
        Views -.inject.-> Router
        Views -.inject.-> MainVM
        Views -.inject.-> OrientationObserver
    end
    
    subgraph "Unowned/Released"
        CIProcessor --> CGImage[CGImage - Released after frame]
        AVCapture --> SampleBuffer[CMSampleBuffer - Auto-released]
    end
    
    style Strong fill:#FF6B6B
    style Weak fill:#FFA500
    style StateObject fill:#50C878
    style EnvironmentObject fill:#4A90E2
```

---

## Testing Architecture

### Test Pyramid

```mermaid
graph TB
    subgraph "UI Tests"
        UI1[Navigation Flow Tests]
        UI2[User Interaction Tests]
        UI3[Screenshot Tests]
    end
    
    subgraph "Integration Tests"
        I1[ViewModel + Service Tests]
        I2[Camera Capture Tests]
        I3[Filter Pipeline Tests]
    end
    
    subgraph "Unit Tests"
        U1[Model Tests]
        U2[Settings Tests]
        U3[Filter Logic Tests]
        U4[Command Parser Tests]
        U5[State Management Tests]
    end
    
    UI1 --> I1
    UI2 --> I1
    I1 --> U1
    I2 --> U2
    I3 --> U3
    
    style UI1 fill:#FF6B6B
    style I1 fill:#FFA500
    style U1 fill:#50C878
```

### Testability Pattern

```mermaid
classDiagram
    class CameraServiceProtocol {
        <<protocol>>
        +startSession()
        +stopSession()
        +currentFrame: AnyPublisher
    }
    
    class CameraService {
        +startSession()
        +stopSession()
        +currentFrame: PassthroughSubject
    }
    
    class MockCameraService {
        +startSession()
        +stopSession()
        +currentFrame: PassthroughSubject
        +injectFrame(CGImage)
    }
    
    class CameraViewModel {
        -cameraService: CameraServiceProtocol
        +init(service: CameraServiceProtocol)
    }
    
    CameraServiceProtocol <|.. CameraService
    CameraServiceProtocol <|.. MockCameraService
    CameraViewModel --> CameraServiceProtocol
    
    style CameraServiceProtocol fill:#50C878
    style MockCameraService fill:#FFA500
```

---

## Conclusión

Esta arquitectura proporciona:

✅ **Separación de responsabilidades** clara entre capas  
✅ **Testabilidad** mediante protocolos e inyección de dependencias  
✅ **Escalabilidad** para añadir nuevas enfermedades y features  
✅ **Mantenibilidad** con código modular y documentado  
✅ **Performance** optimizada con Core Image y Metal  
✅ **UX fluida** con Combine y SwiftUI reactivo  

---

**Última actualización**: Diciembre 2025  
**Versión**: 2.0.0
