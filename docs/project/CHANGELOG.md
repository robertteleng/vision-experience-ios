# Changelog — VisionExperience

Registro cronologico de desarrollo, decisiones tecnicas, y cambios significativos.

---

## 2026-02-15 — Fase 4: Documentacion y Limpieza

### Creado
- `vision-experience-ui.pen` — 5 pantallas diseñadas (Splash, Home, Illness List, Camera View, Immersive 360)
- `docs/UI_SPEC.md` — Spec visual: tokens, tipografia, componentes, pantallas, iconografia
- `CLAUDE.md` — Reglas para AI/devs, arquitectura, convenciones, enfermedades simuladas
- `docs/WORKFLOW.md` — Git flow, naming, testing, dependencias
- `docs/IMPLEMENTATION_PLAN.md` — Roadmap por fases con hitos detallados
- `docs/project/CHANGELOG.md` — Este archivo
- `docs/learning/README.md` — Indice de guias tecnicas
- `docs/learning/filters/core_image_filters.md` — Pipeline Core Image por enfermedad
- `docs/learning/filters/camera_capture.md` — AVFoundation y captura de frames
- `docs/learning/immersive/video_360.md` — SceneKit esfera, CADisplayLink, head tracking
- `docs/learning/immersive/spatial_audio.md` — AVAudioEngine, HRTF, AirPods

### Modificado
- Renombrado proyecto completo: `visionApp` -> `VisionExperience`
  - Directorios, targets, bundle IDs, scheme, Swift headers, UI text
  - Bundle ID: `com.robert.rjsh.VisionExperience`
- `README.md` — Actualizado todas las referencias a VisionExperience
- `docs/DOCUMENTATION_GUIDE.md` — Reescrito para estructura real del proyecto

### Eliminado
- `visionApp/Docs/` — Documentacion legacy (PlantUML, ASCII diagrams)
- `visionApp/README.md` — Duplicado del README raiz
- `docs/ARCHITECTURE.md` — Redundante con README (1146 lineas)
- `docs/DIAGRAMS.md` — Redundante con README (diagramas Mermaid)
- `docs/INDEX.md` — ASCII versions de diagramas Mermaid

### Decisiones tecnicas
- **README como fuente de verdad**: Un solo archivo con todo (arquitectura, features, setup). Sin duplicacion en multiples docs.
- **docs/learning/ por dominio**: Guias tecnicas organizadas por area (filters/, immersive/) siguiendo patron de rayban-nav.
- **CLAUDE.md basado en proyecto real**: Cada seccion refleja codigo existente, no especulacion.

---

## 2025-12-17 — Fase 3: Control por Voz

### Creado
- `SpeechRecognitionService` — Reconocimiento de voz con Speech framework
- `SpeechRecognitionViewModel` — Estado y procesamiento de comandos
- `VoiceCommandsTestView` — Vista de testing para comandos de voz
- Integracion de speech con `AppCoordinator` (activacion por ruta)

### Decisiones tecnicas
- **Comandos en ingles**: Speech framework tiene mejor accuracy en ingles para terminos tecnicos/medicos.
- **Activacion por ruta**: Speech se activa automaticamente en camera, se desactiva en splash/home.

---

## 2025-12-15 — Fase 2: Experiencia Inmersiva

### Creado
- `ImmersiveVideoView` — Video 360 con SceneKit (esfera invertida + AVPlayer)
- `SpatialAudioService` — Audio espacial con AVAudioEngine + HRTF
- `HeadphoneHeadOrientationProvider` — Head tracking AirPods
- `HeadOrientationProvider` — Head tracking giroscopio telefono
- `CardboardView` — Vista estereoscopica VR
- `VRSettings` — Parametros ajustables (IPD, barrel distortion, zoom)

### Decisiones tecnicas
- **SceneKit sobre RealityKit**: SceneKit permite esfera invertida con textura de video mas facilmente.
- **HRTF con AVAudioEnvironmentNode**: Audio posicional 3D nativo sin dependencias externas.
- **Dual head tracking**: AirPods (CMHeadphoneMotionManager) como primario, telefono (CMMotionManager) como fallback.

---

## 2025-12-10 — Fase 1: Core (Camara + Filtros)

### Creado
- `CameraService` — AVCaptureSession con output de CGImage
- `CameraService+Extensions` — Manejo de orientacion
- `CIProcessor` — Pipeline de filtros Core Image por enfermedad
- `CIConfig` — Configuracion compartida de Core Image
- 10 filtros de enfermedades visuales:
  - Cataratas, Glaucoma, Degeneracion Macular, Vision Tunel
  - Hemianopsia, Vision Borrosa, Escotoma Central
  - Retinopatia Diabetica, Deuteranopia, Astigmatismo
- `FilterSettings` — Parametros ajustables por enfermedad
- `IllnessSettings` — Enum wrapper para todas las configuraciones
- `Illness` — Modelo con nombre, descripcion, tipo de filtro
- `IllnessFilterType` — Enum con simbolos SF y nombres
- `AppRouter` — Navegacion centralizada con enum de rutas
- `AppCoordinator` — Contenedor de DI y coordinacion
- `MainView`, `HomeView`, `MainViewModel`
- `CameraView`, `CameraPreviewView`, `CameraImageView`
- `CameraViewModel`
- `IllnessListView`
- `SplashView` + `LottieView` (animacion Lottie)
- `FloatingMenu` — Menu flotante con glassmorphism
- `CompactFiltersPanel` — Panel de ajustes finos
- `FloatingGlassButton`, `GlassSlider`, `Panel` — Componentes UI
- `DeviceOrientationObserver` — Observer de orientacion del dispositivo

### Decisiones tecnicas
- **MVVM + Coordinator**: Separacion clara entre vistas, logica, y navegacion.
- **ObservableObject + @Published**: Patron reactivo estandar para SwiftUI.
- **@EnvironmentObject via AppCoordinator**: Inyeccion de dependencias sin singletons.
- **CIContext compartido**: Un solo contexto Core Image reutilizado en todos los frames.
- **Lottie como unica dependencia externa**: Para la animacion del splash. Todo lo demas es Apple frameworks.
