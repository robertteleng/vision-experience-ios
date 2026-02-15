# Guía de Documentación — VisionExperience

Guía para cualquier persona que se una al proyecto. Explica qué es cada archivo, para qué sirve y en qué orden leerlos.

---

## Estructura General

```
VisionExperience/
├── README.md                    # Documentación principal del proyecto
├── ARCHITECTURE.md              # Arquitectura técnica detallada (Mermaid)
├── DIAGRAMS.md                  # Referencia rápida de diagramas (Mermaid)
├── INDEX.md                     # Índice con versiones ASCII para Xcode
├── DOCUMENTATION_GUIDE.md       # ← Este archivo
├── VisionExperience.xcodeproj/         # Proyecto Xcode
├── VisionExperience/
│   ├── App/
│   │   ├── VisionExperience.swift              # Entry point
│   │   ├── Domain/                      # Modelos de datos
│   │   │   ├── FilterSettings.swift
│   │   │   ├── IllnessSettings.swift
│   │   │   └── VRSettings.swift
│   │   ├── Extensions/                  # Extensiones de tipos
│   │   ├── Presentation/                # Vistas y ViewModels (MVVM)
│   │   │   ├── Main/                    # HomeView, MainView, MainViewModel
│   │   │   ├── Navigation/              # AppRouter, FilterTuningViewModel
│   │   │   ├── Camera/                  # Vista cámara + filtros en vivo
│   │   │   ├── CardBoard/               # Vista estereoscópica VR
│   │   │   ├── Illness/                 # Selección de enfermedad
│   │   │   ├── InmersiveVideo/          # Video 360° + audio espacial
│   │   │   ├── Splash/                  # Splash con Lottie
│   │   │   └── Components/              # UI reutilizable
│   │   ├── Services/                    # Lógica de negocio
│   │   │   ├── CameraService.swift      # Captura AVFoundation
│   │   │   ├── SpeechRecognitionService.swift  # Comandos de voz
│   │   │   └── SpatialAudioService.swift       # Audio espacial HRTF
│   │   └── Utils/                       # Utilidades
│   │       ├── CIProcessor.swift        # Pipeline Core Image
│   │       ├── CIConfig.swift           # Configuración de filtros
│   │       ├── DeviceOrientationObserver.swift
│   │       ├── HeadOrientationProvider.swift
│   │       └── HeadphoneHeadOrientationProvider.swift
│   ├── Assets/                          # Recursos
│   │   ├── Assets.xcassets/
│   │   ├── Animations/                  # Lottie (eyeAnimation.json)
│   │   └── Brand/                       # Logos UMH, FONCE
│   └── Docs/                            # Documentación legacy (PlantUML)
│       ├── Architecture.md
│       ├── architecture_diagram.md
│       ├── voice_commands_guide.md
│       └── Diagrams/                    # 10 archivos .puml
└── VisionExperienceTests/
```

---

## Archivos de Documentación

### README.md
**Para quién:** Todos. Es el punto de entrada.

Contiene:
- Qué es VisionExperience (simulador de enfermedades visuales en tiempo real)
- Características principales (cámara, Cardboard/VR, voz, filtros)
- Arquitectura general (MVVM en capas)
- Enfermedades simuladas (cataratas, glaucoma, degeneración macular, visión túnel)
- Comandos de voz
- Instalación y configuración
- Guía de desarrollo

**Formato:** Mermaid (se renderiza en GitHub).

**Cuándo leerlo:** Siempre. Es lo primero que debe leer cualquier persona nueva.

### ARCHITECTURE.md
**Para quién:** Desarrolladores que necesitan entender los detalles técnicos.

Contiene:
- Arquitectura en capas (Presentation → Domain → Services → iOS Frameworks)
- Patrones de diseño (MVVM, Coordinator, Observer)
- Flujos de datos con Combine
- Pipeline de Core Image (CGImage → CIImage → filtros → render)
- Video 360° + audio espacial (AVPlayer, SceneKit, AVAudioEngine, HRTF)
- Gestión de estado y ciclo de vida
- 45 diagramas técnicos Mermaid

**Cuándo leerlo:** Antes de modificar cualquier servicio, pipeline o flujo de datos.

### DIAGRAMS.md
**Para quién:** Referencia rápida para cualquier dev.

Contiene 12 diagramas Mermaid compactos:
- Navegación principal
- Arquitectura en capas
- Flujo de cámara
- Reconocimiento de voz
- Modelo de datos
- Procesamiento de filtros
- Estados del router
- ViewModels
- Patrón MVVM
- Inyección de dependencias
- Pipeline Core Image
- Jerarquía de vistas

**Cuándo leerlo:** Para consulta rápida de cualquier flujo o relación.

### INDEX.md
**Para quién:** Devs que trabajan desde Xcode (sin renderizado Mermaid).

Contiene versiones ASCII de los diagramas principales para visualización directa en Xcode o cualquier editor de texto plano.

**Cuándo leerlo:** Si no tienes acceso a GitHub para ver los Mermaid.

---

## Documentación Legacy — VisionExperience/Docs/

> Estos archivos están **supersedidos** por la documentación raíz con Mermaid. Se mantienen como referencia pero no son la fuente de verdad.

| Archivo | Qué contiene | Reemplazado por |
|---------|-------------|-----------------|
| Architecture.md | Navegación, pipeline 360°, archivos clave | ARCHITECTURE.md (raíz) |
| architecture_diagram.md | Diagramas ASCII de arquitectura | INDEX.md (raíz) |
| voice_commands_guide.md | Referencia de comandos de voz | README.md (sección Comandos de Voz) |
| Diagrams/*.puml (10 archivos) | Diagramas PlantUML | DIAGRAMS.md (Mermaid) |

---

## Módulos del Código Fuente

### Presentation/ — Vistas y ViewModels

| Módulo | Qué hace |
|--------|----------|
| **Main/** | `HomeView` (pantalla principal), `MainView` (contenedor), `MainViewModel` (estado global) |
| **Navigation/** | `AppRouter` (enrutamiento centralizado), `FilterTuningViewModel` (ajustes de filtros) |
| **Camera/** | Vista de cámara con filtros en tiempo real, `CameraViewModel` controla captura y estado |
| **CardBoard/** | Vista estereoscópica para Google Cardboard, experiencia VR inmersiva |
| **Illness/** | `Illness` (modelo de enfermedad), `IllnessFilterType` (tipos de filtro), `IllnessListView` (selección) |
| **InmersiveVideo/** | Video 360° equirectangular con filtros + audio espacial HRTF |
| **Splash/** | Splash screen con animación Lottie |
| **Components/** | UI reutilizable: FloatingMenu, GlassSlider, CompactFiltersPanel, etc. |

### Services/ — Lógica de Negocio

| Servicio | Qué hace |
|----------|----------|
| **CameraService** | Captura de video con AVFoundation, publica frames como CGImage |
| **SpeechRecognitionService** | Reconocimiento de voz (Speech framework), comandos en inglés |
| **SpatialAudioService** | Audio espacial con AVAudioEngine + AVAudioEnvironmentNode (HRTF) |

### Domain/ — Modelos de Datos

| Modelo | Qué define |
|--------|-----------|
| **FilterSettings** | Parámetros de cada filtro (blur, contrast, vignette, etc.) |
| **IllnessSettings** | Configuración específica por enfermedad |
| **VRSettings** | Configuración del modo Cardboard/VR |

### Utils/ — Utilidades

| Utilidad | Qué hace |
|----------|----------|
| **CIProcessor** | Pipeline Core Image: aplica filtros CIFilter sobre CIImage |
| **CIConfig** | Configuración y parámetros de Core Image |
| **DeviceOrientationObserver** | Observa cambios de orientación del dispositivo |
| **HeadOrientationProvider** | Head tracking via CoreMotion (fallback) |
| **HeadphoneHeadOrientationProvider** | Head tracking via AirPods (CMHeadphoneMotionManager) |

---

## Orden de Lectura Recomendado

### Si eres nuevo en el proyecto:
1. **README.md** — Qué es, por qué existe, cómo instalarlo (15 min)
2. **DIAGRAMS.md** — Visión rápida de todos los flujos (5 min)
3. **ARCHITECTURE.md** — Detalles técnicos profundos (20 min)

### Si vas a trabajar en la cámara o filtros:
1. ARCHITECTURE.md → secciones "Pipeline de Core Image" y "Procesamiento de Imagen"
2. `App/Services/CameraService.swift`
3. `App/Utils/CIProcessor.swift` + `CIConfig.swift`
4. `App/Presentation/Camera/`

### Si vas a trabajar en el video 360° inmersivo:
1. ARCHITECTURE.md → sección "Video 360° + Audio Espacial"
2. `App/Presentation/InmersiveVideo/ImmersiveVideoView.swift`
3. `App/Services/SpatialAudioService.swift`
4. `App/Utils/HeadphoneHeadOrientationProvider.swift`

### Si vas a trabajar en comandos de voz:
1. README.md → sección "Comandos de Voz"
2. `App/Services/SpeechRecognitionService.swift`

### Si vas a añadir una nueva enfermedad visual:
1. `App/Presentation/Illness/Illness.swift` — Modelo con casos existentes
2. `App/Presentation/Illness/IllnessFilterType.swift` — Tipos de filtro
3. `App/Domain/IllnessSettings.swift` — Settings por enfermedad
4. `App/Utils/CIProcessor.swift` — Implementar el nuevo filtro

---

## Stack Tecnológico

| Tecnología | Uso |
|-----------|-----|
| **SwiftUI** | UI declarativa, vistas y navegación |
| **AVFoundation** | Captura de cámara en tiempo real |
| **Core Image** | Procesamiento de filtros visuales |
| **Speech** | Reconocimiento de voz |
| **AVAudioEngine** | Audio espacial HRTF |
| **SceneKit** | Renderizado de esfera 360° |
| **CoreMotion** | Head tracking (dispositivo + AirPods) |
| **Lottie** | Animaciones en splash screen |
| **Combine** | Flujos reactivos de datos |

---

## Convenciones

- **Arquitectura:** MVVM con servicios desacoplados
- **Inyección de dependencias:** vía `@EnvironmentObject`
- **Navegación:** `AppRouter` centralizado con enum de rutas
- **Formato de diagramas:** Mermaid (renderiza en GitHub, legible como texto)
- **Idioma del código:** Inglés
- **Idioma de la documentación:** Español

---

## Fuente de Verdad

> **Documentación raíz (Mermaid)** es la fuente de verdad. Si hay discrepancia con `VisionExperience/Docs/` (PlantUML/ASCII), la documentación raíz gana. Si hay discrepancia entre la documentación y el código, el código gana.
