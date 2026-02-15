# Guía de Documentación — VisionExperience

Guía para cualquier persona que se una al proyecto. Explica qué es cada archivo, para qué sirve y en qué orden leerlos.

---

## Estructura General

```
vision-experience-ios/
├── CLAUDE.md                          # Reglas para AI/devs (leer primero)
├── README.md                          # Documentación completa del proyecto
├── VisionExperience.xcodeproj/        # Proyecto Xcode
├── vision-experience-ui.pen           # Diseño visual (Pencil MCP)
├── docs/
│   ├── DOCUMENTATION_GUIDE.md         # ← Este archivo
│   ├── WORKFLOW.md                    # Git flow, naming, testing, dependencias
│   ├── IMPLEMENTATION_PLAN.md         # Roadmap por fases con hitos
│   ├── UI_SPEC.md                     # Spec visual (colores, tipografía, componentes)
│   ├── learning/
│   │   ├── README.md                  # Índice de guías técnicas
│   │   ├── filters/                   # Filtros visuales y cámara
│   │   │   ├── core_image_filters.md  # Pipeline Core Image, filtros por enfermedad
│   │   │   └── camera_capture.md      # AVFoundation, captura de frames
│   │   └── immersive/                 # Experiencia 360° inmersiva
│   │       ├── video_360.md           # SceneKit esfera, CADisplayLink, filtros
│   │       └── spatial_audio.md       # AVAudioEngine, HRTF, head tracking
│   └── project/
│       └── CHANGELOG.md               # Historial de desarrollo
├── VisionExperience/                  # Código fuente
│   └── App/
│       ├── VisionExperienceApp.swift  # Entry point (@main)
│       ├── Domain/                    # Modelos de datos
│       ├── Extensions/                # Extensiones de tipos
│       ├── Presentation/              # Vistas y ViewModels (MVVM)
│       │   ├── Main/                  # HomeView, MainView, MainViewModel
│       │   ├── Navigation/            # AppRouter, AppCoordinator
│       │   ├── Camera/                # Vista cámara + filtros en vivo
│       │   ├── CardBoard/             # Vista estereoscópica VR
│       │   ├── Illness/               # Selección de enfermedad
│       │   ├── InmersiveVideo/        # Video 360° + audio espacial
│       │   ├── Splash/                # Splash con Lottie
│       │   └── Components/            # UI reutilizable
│       ├── Services/                  # CameraService, SpeechRecognition, SpatialAudio
│       └── Utils/                     # CIProcessor, CIConfig, head tracking
├── VisionExperienceTests/
└── VisionExperienceUITests/
```

---

## Archivos Raíz

### CLAUDE.md
**Para quién:** Claude Code, IAs, y desarrolladores.

Contiene las reglas del proyecto: identidad, constraints, arquitectura, convenciones de naming, organización de archivos, enfermedades simuladas, dependencias aprobadas, formato de commits, y reglas de interacción.

**Cuándo leerlo:** Antes de escribir cualquier línea de código. Es el primer archivo que debe leer un agente AI.

### README.md
**Para quién:** Todos. Es el punto de entrada.

Contiene todo lo necesario para entender y trabajar en el proyecto:
- Qué es VisionExperience y para qué sirve
- Características principales
- Arquitectura MVVM con diagramas Mermaid
- Flujos de navegación
- Estructura del proyecto
- Enfermedades simuladas (cataratas, glaucoma, macular, túnel)
- Comandos de voz
- Instalación y configuración
- Guía de desarrollo

**Cuándo leerlo:** Siempre. Es lo primero que debe leer cualquier persona nueva.

### vision-experience-ui.pen
**Para quién:** Diseño visual de la UI.

Archivo de diseño editable con Pencil MCP. Contiene las pantallas, componentes, colores y tipografía del proyecto. Solo se puede leer/editar con las herramientas MCP de Pencil (`batch_get`, `batch_design`, `get_screenshot`).

**Cuándo usarlo:** Al diseñar nuevas pantallas o modificar la UI existente.

---

## docs/ — Documentación Técnica

### docs/DOCUMENTATION_GUIDE.md
Este archivo. Mapa de toda la documentación.

### docs/WORKFLOW.md
**Para quién:** Desarrolladores que contribuyen código.

Convenciones de naming, estructura de Views y Services, patrones DO/DON'T, git flow, formato de commits, testing, y dependencias aprobadas.

**Cuándo leerlo:** Antes de hacer tu primer PR.

### docs/IMPLEMENTATION_PLAN.md
**Para quién:** Project leads y desarrolladores.

Roadmap completo por fases con hitos detallados y checkboxes de progreso. Muestra qué está hecho, qué falta, y qué viene después.

**Cuándo leerlo:** Para entender el estado del proyecto y planificar trabajo futuro.

### docs/UI_SPEC.md
**Para quién:** Diseñadores y developers de UI.

Especificación visual: colores, tipografía, componentes, pantallas. Generado desde el archivo `.pen`.

**Cuándo leerlo:** Al implementar o modificar la interfaz de usuario.

### docs/project/CHANGELOG.md
**Para quién:** Todos.

Registro cronológico de desarrollo, decisiones técnicas, y cambios significativos organizados por fecha.

**Cuándo leerlo:** Para entender la historia del proyecto y las decisiones tomadas.

### docs/learning/ — Guías Técnicas por Dominio

Guías teóricas organizadas por área del proyecto. Cada una explica los conceptos, frameworks y patrones necesarios.

#### Filtros Visuales — `learning/filters/`

| Guía | Qué Explica |
|------|-------------|
| **core_image_filters.md** | Pipeline Core Image, cadenas de filtros por enfermedad, rendimiento, cómo añadir filtros nuevos |
| **camera_capture.md** | AVFoundation: AVCaptureSession, captura de frames, orientación, permisos |

**Cuándo leerlas:** Antes de tocar `CameraService`, `CIProcessor`, o añadir una enfermedad nueva.

#### Experiencia Inmersiva — `learning/immersive/`

| Guía | Qué Explica |
|------|-------------|
| **video_360.md** | Video equirectangular en SceneKit, CADisplayLink, filtros sobre textura, head tracking |
| **spatial_audio.md** | AVAudioEngine + HRTF, head tracking AirPods/CoreMotion, sincronización video/audio |

**Cuándo leerlas:** Antes de tocar `ImmersiveVideoView` o `SpatialAudioService`.

---

## Orden de Lectura Recomendado

### Si eres nuevo en el proyecto:
1. **CLAUDE.md** — Reglas y constraints (5 min)
2. **README.md** — Todo lo que necesitas saber (20 min)

### Si vas a trabajar en la cámara o filtros:
1. `docs/learning/filters/camera_capture.md`
2. `docs/learning/filters/core_image_filters.md`
3. Código: `App/Services/CameraService.swift` → `App/Presentation/Camera/Views/CIProcessor.swift`

### Si vas a trabajar en el video 360° inmersivo:
1. `docs/learning/immersive/video_360.md`
2. `docs/learning/immersive/spatial_audio.md`
3. Código: `App/Presentation/InmersiveVideo/ImmersiveVideoView.swift` → `App/Services/SpatialAudioService.swift`

### Si vas a añadir una nueva enfermedad visual:
1. `docs/learning/filters/core_image_filters.md` → sección "Cómo añadir un nuevo filtro"
2. Código: `Illness.swift` → `IllnessFilterType.swift` → `FilterSettings.swift` → `CIProcessor.swift`

---

## Flujo de Actualización de UI

Cuando se modifica la UI, hay **2 artefactos que deben mantenerse sincronizados**:

```
vision-experience-ui.pen  ←→  SwiftUI Code
   (diseño visual)              (implementación)
```

1. **Diseñar en .pen** — Usar herramientas MCP de Pencil
2. **Validar** — `get_screenshot` para verificar visualmente
3. **Implementar en SwiftUI** — Seguir el diseño del .pen

> Si hay discrepancia entre el .pen y el código, **el código gana** (es lo que se ejecuta).

---

## Convenciones

- **Arquitectura:** MVVM con servicios desacoplados
- **Inyección de dependencias:** `@EnvironmentObject` via `AppCoordinator`
- **Navegación:** `AppRouter` centralizado con enum de rutas
- **Idioma del código:** Inglés
- **Idioma de la documentación:** Español
- **Diagramas:** Mermaid (en README.md, renderiza en GitHub)

---

## Fuente de Verdad

> **CLAUDE.md** define las reglas. **README.md** es la fuente de verdad del proyecto. **docs/learning/** complementa con profundidad técnica. Si hay discrepancia entre la documentación y el código, el código gana.
