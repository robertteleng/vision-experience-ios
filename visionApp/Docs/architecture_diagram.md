# visionApp – Arquitectura y estructura (ASCII)

visionApp/
├── Presentation/
│   ├── Views/
│   │   ├── CameraView.swift              (Vista principal de cámara; orquesta UI y navegación)
│   │   ├── CardboardView.swift           (Render estereoscópico: panel izquierdo/derecho)
│   │   ├── CameraImageView.swift         (Render de imagen + procesado CI por enfermedad)
│   │   └── FloatingMenu.swift            (Menú flotante con sliders y panel de filtros)
│   │
│   ├── ViewModels/
│   │   ├── MainViewModel.swift           (Estado global: enfermedad, toggles, ajustes, voz)
│   │   └── CameraViewModel.swift         (Puente entre UI y CameraService)
│   │
│   └── Components/
│       └── GlassSlider.swift             (Slider con estilo “glass”)
│
├── Domain/
│   ├── Models/
│   │   ├── Illness.swift                 (Modelo de enfermedad)
│   │   └── FilterSettings.swift          (Ajustes por filtro + IllnessSettings wrapper)
│   │
│   └── Enums/
│       ├── IllnessFilterType.swift       (Tipos de filtros: cataracts, glaucoma, macular, tunnel)
│       ├── Panel.swift                   (Panel de render: left, right, full)
│       └── CameraError.swift             (Errores de cámara)
│
├── Services/
│   ├── Camera/
│   │   ├── CameraService.swift           (AVCaptureSession + frames CGImage publicados)
│   │   └── DeviceOrientationObserver.swift (Observador de orientación de dispositivo)
│   │
│   └── Speech/
│       └── SpeechRecognitionService.swift (Reconocimiento de voz; publica lastCommand)
│
└── ImageProcessing/
    └── CIProcessor.swift                 (Procesado Core Image por enfermedad y ajustes)

Referenciados pero no provistos en esta revisión:
- AppRouter (usado en CameraView y FloatingMenu)
- Entry point de la app (visionAppApp.swift o similar)
- UIDevice+Orientation.swift (mencionado previamente, no proporcionado aquí)
- Recursos (Assets.xcassets, etc.)

## Capas y responsabilidades

- Presentation (UI)
  - CameraView: decide entre modo normal y Cardboard; gestiona menú flotante y navegación.
  - CardboardView: presenta dos paneles (izq/der) con CameraImageView.
  - CameraImageView: recorta por Panel y aplica procesado de imagen (CIProcessor).
  - FloatingMenu: controles de navegación (AppRouter), activación de filtros y ajustes; incluye CompactFiltersPanel y GlassSlider.

- ViewModels
  - MainViewModel: estado global (selectedIllness, filterEnabled, centralFocus, isCardboardMode), ajustes por filtro y comandos de voz (SpeechRecognitionService).
  - CameraViewModel: enlaza CameraService con la UI (currentFrame, error) y controla start/stop de la sesión.

- Domain
  - Illness, IllnessFilterType: modelo y enumeración de filtros.
  - FilterSettings + IllnessSettings: configuración detallada por enfermedad.
  - Panel, CameraError: utilidades de dominio.

- Services
  - CameraService: configuración y flujo de frames de cámara (AVCaptureSession, AVCaptureVideoDataOutput).
  - SpeechRecognitionService: reconocimiento de voz (SFSpeechRecognizer + AVAudioEngine).
  - DeviceOrientationObserver: orientación del dispositivo (NotificationCenter).

- ImageProcessing
  - CIProcessor: aplica efectos Core Image parametrizados por IllnessSettings y centralFocus.

## Diagrama de dependencias (archivos principales)

[CameraView.swift]
├─ usa -> MainViewModel (EnvironmentObject)
├─ usa -> CameraViewModel (StateObject)
├─ usa -> DeviceOrientationObserver (EnvironmentObject)
├─ usa -> AppRouter (EnvironmentObject) [referenciado]
├─ muestra -> CardboardView (si modo cardboard)
├─ muestra -> CameraImageView (si modo normal)
└─ contiene -> FloatingMenu

[CardboardView.swift]
├─ usa -> CameraService (ObservedObject a través de CameraViewModel)
└─ muestra -> CameraImageView (panel .left) + CameraImageView (panel .right)

[CameraImageView.swift]
├─ entrada -> CGImage?, Panel, Illness?, centralFocus, filterEnabled, IllnessSettings?
└─ llama -> CIProcessor.shared.apply(...)

[FloatingMenu.swift]
├─ usa -> MainViewModel (ajusta centralFocus, filterEnabled, settings por filtro)
├─ usa -> AppRouter (navegación) [referenciado]
└─ contiene -> CompactFiltersPanel + GlassSlider

[MainViewModel.swift]
├─ mantiene -> selectedIllness, filterEnabled, centralFocus, isCardboardMode
├─ mantiene -> CataractsSettings, GlaucomaSettings, MacularDegenerationSettings, TunnelVisionSettings
├─ deriva -> currentIllnessSettings (IllnessSettings)
└─ integra -> SpeechRecognitionService (comandos) + AVSpeechSynthesizer (respuesta)

[CameraViewModel.swift]
├─ mantiene -> currentFrame (CGImage?), error (CameraError?)
└─ usa -> CameraService (start/stop + Combine sobre frames/errores)

[CameraService.swift]
├─ publica -> currentFrame (CGImage), error (CameraError)
└─ gestiona -> AVCaptureSession, AVCaptureVideoDataOutput

[CIProcessor.swift]
└─ aplica -> efectos (cataracts, glaucoma, macularDegeneration, tunnelVision) con IllnessSettings + centralFocus

[SpeechRecognitionService.swift]
├─ publica -> lastCommand (Combine)
└─ usa -> SFSpeechRecognizer, AVAudioEngine

## Flujo de datos (cámara → UI → procesado)

CameraService --(CGImage frames)--> CameraViewModel --(Published)--> CameraView/CardboardView
   └─ error(CameraError) ---------------------------------------------> UI (manejo de errores)

CameraView -> CameraImageView -> CIProcessor.apply(...) -> Imagen procesada en pantalla

MainViewModel <-> FloatingMenu/CompactFiltersPanel
   ├─ Ajusta: centralFocus, filterEnabled
   └─ Ajustes por filtro (Cataracts/Glaucoma/Macular/Tunnel) -> afectan a CIProcessor

SpeechRecognitionService --(lastCommand)--> MainViewModel --(actualiza)--> selectedIllness

## Puntos de extensión

- Añadir un nuevo filtro:
  1) Agregar caso en IllnessFilterType.
  2) Crear Settings específicos en FilterSettings y extender IllnessSettings.
  3) Implementar rama en CIProcessor.apply(...) para el nuevo filtro.
  4) Añadir sliders en CompactFiltersPanel (FloatingMenu) y estado en MainViewModel.
  5) Opcional: comandos de voz en SpeechRecognitionService/MainViewModel.

- Integrar otra fuente de frames (p. ej., vídeo local):
  - Implementar un servicio alternativo que publique CGImage y enchufarlo a CameraViewModel.

- Navegación:
  - Centralizar rutas y transiciones en AppRouter (referenciado) para vistas adicionales (lista de enfermedades, ajustes globales, etc.).
