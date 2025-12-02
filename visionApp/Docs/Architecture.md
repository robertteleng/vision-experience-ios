# visionApp — Architecture & Flow (updated 2025‑08‑28)

This document summarizes the current navigation flow, rendering/audio pipelines, and the main modules/files of the project.

## 1) App Navigation Flow

```mermaid
flowchart TD
  A[SplashView] --> B[HomeView]
  B --> C[IllnessListView]
  B --> D[CameraView]
  B --> E[ImmersiveVideoView\n(360° + filtros + audio espacial)]
  B --> F[CardboardView\n(visor)]

  E -->|Play/Pause| E
  E -->|Seek/Restart| E
```

- Router/state: App/Presentation/Navigation/AppRouter.swift
- Entry point: App/visionApp.swift (hosts MainView -> HomeView)

## 2) 360° Video + Filtros + Audio Espacial

High-level data flow for the immersive experience:

```mermaid
flowchart LR
  subgraph Video
    VURL[Remote 360° Video URL] --> AVP[AVPlayer (muted)]
    AVP --> VOut[AVPlayerItemVideoOutput]
    VOut --> CI[CIProcessor + CIConfig\n(illness filters, centralFocus)]
    CI --> SCN[SceneKit esfera invertida\n(diffuse = filtered frame)]
  end

  subgraph Audio (Spatial)
    VURL --> Reader[AVAssetReader (audio)]
    Reader --> Mono[Mix a mono float32]
    Mono --> Engine[AVAudioEngine]
    Engine --> Env[AVAudioEnvironmentNode\n(HRTF spatialization)]
  end

  subgraph Head Tracking
    HP[HeadphoneHeadOrientationProvider\n(AirPods, if available)] --> Env
    Phone[HeadOrientationProvider\n(CoreMotion fallback)] --> Env
  end
```

- Frames: CADisplayLink pide buffers a AVPlayerItemVideoOutput; cada frame se filtra con CIProcessor según el Illness seleccionado y centralFocus, y se aplica como textura a la esfera de SceneKit.
- Audio: AVAssetReader decodifica la pista de audio del mismo vídeo, mezcla a mono y la envía a AVAudioEngine/AVAudioEnvironmentNode (HRTF). El AVPlayer está silenciado para evitar doble audio.
- Head tracking: si hay AirPods compatibles, se usa CMHeadphoneMotionManager; si no, CoreMotion del teléfono. Botón “Recenter” para alinear yaw.
- Seek/Restart: el slider de Seek y el botón Restart llaman a la vez a AVPlayer.seek(...) y SpatialAudioService.seek(...).

## 3) Archivos clave (módulos)

- Entrada y navegación
  - App/visionApp.swift
  - App/Presentation/Navigation/AppRouter.swift
  - App/Presentation/Main/HomeView.swift
- Inmersivo (360°)
  - App/Presentation/InmersiveVideo/ImmersiveVideoView.swift
  - App/Utils/CIProcessor.swift, App/Utils/CIConfig.swift (filtros)
  - App/Services/SpatialAudioService.swift (AVAssetReader + AVAudioEngine)
  - App/Utils/HeadphoneHeadOrientationProvider.swift (AirPods)
  - App/Utils/HeadOrientationProvider.swift (teléfono)
- Cámara
  - App/Services/CameraService.swift
  - App/Presentation/Camera/... (views + viewmodel)
- Cardboard visor
  - App/Presentation/CardBoard/CardboardView.swift
- Illness (modelo y UI)
  - App/Presentation/Illness/Illness.swift, IllnessFilterType.swift, IllnessListView.swift
- Componentes UI
  - App/Presentation/Components/* (botones flotantes, sliders, etc.)

## 4) Estructura de carpetas (resumen actual)

```text
visionApp/
├─ App/
│  ├─ visionApp.swift
│  ├─ Extensions/
│  ├─ Presentation/
│  │  ├─ Main/ (HomeView, MainView, MainViewModel)
│  │  ├─ Navigation/ (AppRouter, FilterTuningViewModel)
│  │  ├─ InmersiveVideo/ (ImmersiveVideoView)
│  │  ├─ Illness/ (modelos + vistas)
│  │  ├─ Camera/ (views + viewmodel)
│  │  ├─ CardBoard/ (CardboardView)
│  │  └─ Components/ (UI reutilizable)
│  ├─ Services/ (CameraService, SpatialAudioService, SpeechRecognitionService)
│  └─ Utils/ (CIProcessor, CIConfig, Head/Headphone providers, DeviceOrientationObserver)
├─ Assets/
└─ Docs/
```

## 5) Interacciones críticas

- Play/Pause: sincroniza AVPlayer (vídeo) con SpatialAudioService.setPlaying(...).
- Seek: AVPlayer.seek(to:) y SpatialAudioService.seek(to:) se disparan juntos.
- Head tracking: prioridad a AirPods; fallback automático a teléfono; “Recenter” ajusta yaw.
- Rendimiento: hasNewPixelBuffer + autoreleasepool en el bucle de frames; limpieza en dismantleUIView.

## 6) Próximos pasos sugeridos (opcionales)

- UI para volumen/mute del audio espacial (SpatialAudioService.setGain / setMuted).
- Manejo de interrupciones y cambios de ruta de audio (AVAudioSession).
- Fuente de vídeo 360° equirectangular real para mapeo perfecto en esfera.
