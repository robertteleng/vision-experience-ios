# Plan de Implementacion — VisionExperience

Simulador de enfermedades visuales en tiempo real con realidad inmersiva.

---

## Fase 1: Core — Camara + Filtros (Completada)

**Objetivo**: App funcional con camara en vivo y filtros Core Image por enfermedad.

### Hito 1.1 — Captura de camara
- [x] `CameraService` con `AVCaptureSession`
- [x] Output de frames como `CGImage` via `@Published`
- [x] Manejo de permisos (`NSCameraUsageDescription`)
- [x] `CIContext` compartido para rendimiento
- [x] Queue dedicada para captura

### Hito 1.2 — Pipeline de filtros Core Image
- [x] `CIProcessor` con cadenas de filtros por enfermedad
- [x] 10 enfermedades implementadas:
  - Cataratas, Glaucoma, Degeneracion Macular, Vision Tunel
  - Hemianopsia, Vision Borrosa, Escotoma Central
  - Retinopatia Diabetica, Deuteranopia, Astigmatismo
- [x] `FilterSettings` con parametros ajustables por enfermedad
- [x] Intensidad global (`centralFocus`) controlable

### Hito 1.3 — Navegacion y UI base
- [x] `AppRouter` con enum de rutas
- [x] `AppCoordinator` como contenedor de DI
- [x] `SplashView` con animacion Lottie
- [x] `IllnessListView` — selector de enfermedades
- [x] `CameraView` — vista de camara con filtros en vivo
- [x] `FloatingMenu` — controles flotantes con glassmorphism
- [x] `CompactFiltersPanel` — ajustes finos por enfermedad

---

## Fase 2: Experiencia Inmersiva (Completada)

**Objetivo**: Modo VR con Cardboard y video 360 con audio espacial.

### Hito 2.1 — Modo Cardboard/VR
- [x] `CardboardView` — vista estereoscopica (left/right panels)
- [x] Filtros aplicados independientemente a cada panel
- [x] `VRSettings` — distancia interpupilar, distorsion barrel, zoom
- [x] Activacion automatica en landscape

### Hito 2.2 — Video 360
- [x] `ImmersiveVideoView` con SceneKit (esfera invertida)
- [x] AVPlayer para reproduccion de video equirectangular
- [x] CADisplayLink para sincronizacion de textura
- [x] Filtros Core Image sobre la textura del video
- [x] Head tracking con CMMotionManager

### Hito 2.3 — Audio Espacial
- [x] `SpatialAudioService` con AVAudioEngine + AVAudioEnvironmentNode
- [x] HRTF (Head-Related Transfer Function) para posicion 3D
- [x] Head tracking con AirPods (`CMHeadphoneMotionManager`)
- [x] Fallback a giroscopio del telefono
- [x] Sincronizacion play/pause/seek con AVPlayer

---

## Fase 3: Control por Voz (Completada)

**Objetivo**: Control manos libres de la app con comandos de voz.

### Hito 3.1 — Reconocimiento de voz
- [x] `SpeechRecognitionService` con Speech framework
- [x] `SpeechRecognitionViewModel` — estado y comandos
- [x] Integracion con `AppCoordinator` para routing

### Hito 3.2 — Comandos implementados
- [x] Seleccion de enfermedad por nombre
- [x] Ajuste de intensidad (increase/decrease)
- [x] Activacion/desactivacion de filtros
- [x] Toggle modo VR/Cardboard
- [x] Navegacion (back)
- [x] Activacion automatica por ruta (camera = siempre activo)

---

## Fase 4: Pulido y Documentacion (En progreso)

**Objetivo**: Documentacion completa, design system, optimizaciones.

### Hito 4.1 — Documentacion
- [x] README.md completo (arquitectura, features, setup)
- [x] CLAUDE.md (reglas para AI/devs)
- [x] DOCUMENTATION_GUIDE.md (mapa de docs)
- [x] WORKFLOW.md (convenciones, git flow)
- [x] IMPLEMENTATION_PLAN.md (este archivo)
- [x] learning/ (guias tecnicas: filters, immersive)
- [x] project/CHANGELOG.md
- [x] UI_SPEC.md (spec visual desde .pen)

### Hito 4.2 — Design System
- [x] vision-experience-ui.pen (5 pantallas completas)
- [x] Componentes reutilizables en .pen
- [x] Tokens de color y tipografia definidos
- [x] Screenshots de referencia

### Hito 4.3 — Optimizaciones pendientes
- [ ] Profiling con Instruments (Core Image, GPU, memory)
- [ ] Optimizar cadena de filtros para enfermedades complejas
- [ ] Reducir latencia en modo Cardboard (2 renders por frame)
- [ ] Battery impact en sesiones largas

### Hito 4.4 — Testing
- [ ] Unit tests para FilterSettings y domain models
- [ ] Unit tests para ViewModels
- [ ] Integration tests para CameraService
- [ ] UI tests para navigation flows
- [ ] Cobertura minima: 60% domain + services

---

## Fase 5: Futuro (Planificada)

### Posibles mejoras
- [ ] Mas enfermedades visuales (nistagmo, daltonismo protan/tritan)
- [ ] Grabacion de video con filtros aplicados
- [ ] Compartir capturas de pantalla filtradas
- [ ] Modo presentacion para aulas
- [ ] Localizacion completa (ES, EN, FR)
- [ ] iPad support con layout adaptativo
- [ ] Accessibility improvements (VoiceOver, Dynamic Type)

---

## Notas

- **Core Image es el bottleneck**: Todo filtro pasa por `CIProcessor`. Optimizar aqui tiene el mayor impacto.
- **Un solo AVCaptureSession**: iOS no permite multiples sesiones. Cardboard mode procesa el mismo frame 2 veces.
- **Audio espacial requiere auriculares**: HRTF solo funciona con auriculares. Sin ellos, el audio es mono.
- **Comandos de voz en ingles**: Speech framework funciona mejor en ingles para los comandos tecnicos (illness names).
