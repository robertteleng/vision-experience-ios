# 📊 visionApp - Diagramas Rápidos

> Visualización rápida de todos los diagramas de arquitectura y flujos

---

## 🎯 Navegación Principal

```mermaid
flowchart LR
    A[App Launch] -->|2s| B[Splash]
    B --> C[Home]
    C -->|Illness| D[List]
    C -->|Immersive| E[360° Video]
    D -->|Select| F[Camera]
    F -->|VR Toggle| G[Cardboard]
    F -->|Back| D
    G -->|Exit| D
```

## 🏗️ Arquitectura en Capas

```mermaid
graph TB
    UI[SwiftUI Views] --> VM[ViewModels]
    VM --> Domain[Models & Enums]
    VM --> Services[Services]
    Services --> iOS[iOS Frameworks]
```

## 🎥 Flujo de Cámara

```mermaid
sequenceDiagram
    Camera->>CameraService: Capture frame
    CameraService->>CameraViewModel: Publish CGImage
    CameraViewModel->>CameraView: Update state
    CameraView->>CIProcessor: Apply filter
    CIProcessor->>Display: Show result
```

## 🎤 Reconocimiento de Voz

```mermaid
flowchart TD
    A[Voice Command] --> B{Parse}
    B -->|Illness| C[Change Filter]
    B -->|Intensity| D[Adjust ±20%]
    B -->|Toggle| E[On/Off]
    B -->|Exit| F[Navigate Back]
```

## 🧬 Modelo de Datos

```mermaid
classDiagram
    Illness --> IllnessFilterType
    IllnessSettings --> CataractsSettings
    IllnessSettings --> GlaucomaSettings
    IllnessSettings --> MacularSettings
    IllnessSettings --> TunnelSettings
```

## 🎨 Procesamiento de Filtros

```mermaid
flowchart LR
    A[CGImage] --> B{Filter Type}
    B -->|Cataracts| C1[Blur + Contrast + Yellow]
    B -->|Glaucoma| C2[Vignette + Darkening]
    B -->|Macular| C3[Central Blur + Twirl]
    B -->|Tunnel| C4[Peripheral Blur]
    C1 --> D[Output]
    C2 --> D
    C3 --> D
    C4 --> D
```

## 🔄 Estados del Router

```mermaid
stateDiagram-v2
    [*] --> splash
    splash --> home
    home --> illnessList
    home --> immersiveVideo
    illnessList --> camera
    camera --> illnessList
```

## 📱 ViewModels

```mermaid
graph TB
    MVM[MainViewModel<br/>Global State] --> CVM[CameraViewModel<br/>Camera Control]
    MVM --> TVM[FilterTuningViewModel<br/>Settings]
    MVM --> SVM[SpeechViewModel<br/>Voice Commands]
```

## 🎛️ Patrón MVVM

```mermaid
graph LR
    V[View] -->|Binding| VM[ViewModel]
    VM -->|Published| V
    VM --> M[Model]
    VM --> S[Service]
```

## 🔌 Inyección de Dependencias

```mermaid
graph TD
    App[visionApp] -->|environmentObject| Router
    App -->|environmentObject| MainVM
    App -->|environmentObject| Orientation
    Router --> AllViews[All Views]
    MainVM --> AllViews
```

## ⚡ Pipeline de Core Image

```mermaid
flowchart TD
    A[CGImage] --> B[CIImage]
    B --> C[Apply Filters]
    C --> D[CIContext Render]
    D --> E[CGImage Output]
```

## 📊 Jerarquía de Vistas

```mermaid
graph TB
    Main[MainView] --> Splash[SplashView]
    Main --> Home[HomeView]
    Main --> List[IllnessListView]
    Main --> Camera[CameraView]
    Camera --> Normal[CameraImageView]
    Camera --> Cardboard[CardboardView]
    Camera --> Menu[FloatingMenu]
```

---

## 📖 Documentación Completa

- **README.md**: Documentación general, instalación y guías
- **ARCHITECTURE.md**: Arquitectura técnica detallada
- **Docs/**: Documentación adicional y recursos

---

**Tip**: Estos diagramas se renderizan automáticamente en GitHub con sintaxis Mermaid
