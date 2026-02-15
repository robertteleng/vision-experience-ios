# 📚 VisionExperience - Índice de Documentación

> **Nota para Xcode**: Los diagramas Mermaid solo se renderizan en GitHub/GitLab.
> En Xcode verás el código fuente. Para visualizaciones rápidas en Xcode, ver secciones ASCII más abajo.

---

## 📖 Archivos de Documentación

### 🚀 [README.md](README.md)
**Documentación principal del proyecto**
- Descripción general y características
- Instalación y configuración
- Guía de desarrollo
- Comandos de voz
- Simulación de enfermedades
- **54 diagramas Mermaid** (se ven en GitHub)

### 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md)
**Arquitectura técnica detallada**
- Capas de arquitectura (Presentation, Domain, Service)
- Patrones de diseño (MVVM, Coordinator, Observer)
- Flujos de datos con Combine
- Pipeline de Core Image
- Gestión de estado y ciclo de vida
- **45 diagramas técnicos Mermaid** (se ven en GitHub)

### 📊 [DIAGRAMS.md](DIAGRAMS.md)
**Referencia rápida de diagramas**
- Versiones compactas de todos los flujos
- Diagramas simplificados para consulta rápida
- **12 diagramas Mermaid** (se ven en GitHub)

### 📁 [VisionExperience/Docs/](VisionExperience/Docs/)
**Documentación legacy y recursos**
- `architecture_diagram.md` - Arquitectura en ASCII
- `voice_commands_guide.md` - Guía de comandos de voz
- `Architecture.png` - Diagrama visual exportado
- `architecture.puml` - PlantUML source

---

## 🎨 Visualizaciones ASCII (para Xcode)

### Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                    VisionExperience Architecture                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    📱 PRESENTATION LAYER                     │
├─────────────────────────────────────────────────────────────┤
│  MainView    SplashView    IllnessListView    CameraView    │
│      │            │               │                │         │
│      └────────────┴───────────────┴────────────────┘         │
│                         │                                    │
│                    ViewModels                                │
│         MainViewModel  CameraViewModel  FilterTuningVM       │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│                     📦 DOMAIN LAYER                          │
├─────────────────────────────────────────────────────────────┤
│  Illness  IllnessFilterType  FilterSettings  IllnessSettings│
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│                    ⚙️  SERVICE LAYER                         │
├─────────────────────────────────────────────────────────────┤
│  CameraService  SpeechRecognitionService  CIProcessor        │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│                  🍎 iOS FRAMEWORKS                           │
├─────────────────────────────────────────────────────────────┤
│  AVFoundation    Speech    CoreImage    SwiftUI    Combine   │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Navegación

```
App Launch
    │
    ▼
┌──────────┐
│  Splash  │ (2 segundos + animación Lottie)
└────┬─────┘
     │
     ▼
┌──────────┐
│   Home   │
└─┬─────┬──┘
  │     │
  │     └─────────────┐
  │                   │
  ▼                   ▼
┌──────────────┐  ┌──────────────┐
│ IllnessList  │  │  Immersive   │
└──────┬───────┘  │   Video 360° │
       │          └──────────────┘
       ▼
   Seleccionar
   Enfermedad
       │
       ▼
┌──────────────┐
│  CameraView  │
└──────┬───────┘
       │
       ├─────────────┐
       │             │
       ▼             ▼
┌──────────┐   ┌──────────────┐
│  Normal  │   │  Cardboard   │
│   Mode   │   │  (VR) Mode   │
└──────────┘   └──────────────┘
```

### Flujo de Cámara → Filtro → Display

```
┌─────────────┐
│   Camera    │
│  Hardware   │
└──────┬──────┘
       │ 60 FPS
       ▼
┌─────────────────┐
│  CameraService  │
│  AVFoundation   │
└──────┬──────────┘
       │ CGImage
       ▼
┌──────────────────┐
│ CameraViewModel  │
│  @Published      │
└──────┬───────────┘
       │
       ▼
┌─────────────┐      ┌──────────────┐
│ CameraView  │─────▶│ CIProcessor  │
└─────────────┘      │ Core Image   │
       ▲             └──────┬───────┘
       │                    │ Filtered
       │                    ▼
       │             ┌──────────────┐
       │             │   Cataracts  │
       │             │   Glaucoma   │
       │             │   Macular    │
       │             │   Tunnel     │
       │             └──────┬───────┘
       │                    │
       └────────────────────┘
                │
                ▼
         ┌────────────┐
         │  Display   │
         └────────────┘
```

### MVVM Pattern

```
┌──────────────────────────────────────────────┐
│                    VIEW                       │
│  (SwiftUI - CameraView, MainView, etc.)      │
└────────────┬─────────────────────────────────┘
             │
             │ @ObservedObject
             │ @EnvironmentObject
             │ @Binding
             │
             ▼
┌──────────────────────────────────────────────┐
│                 VIEW MODEL                    │
│  (MainViewModel, CameraViewModel)            │
│                                               │
│  @Published properties                        │
│  - selectedIllness                            │
│  - filterEnabled                              │
│  - currentFrame                               │
│                                               │
│  Methods:                                     │
│  - startCamera()                              │
│  - applyFilter()                              │
│  - processVoiceCommand()                      │
└────────┬──────────────────┬──────────────────┘
         │                  │
         ▼                  ▼
┌─────────────────┐  ┌──────────────────┐
│     MODEL       │  │     SERVICE      │
│                 │  │                  │
│  - Illness      │  │ - CameraService  │
│  - Settings     │  │ - SpeechService  │
│  - FilterType   │  │ - CIProcessor    │
└─────────────────┘  └──────────────────┘
```

### Procesamiento de Filtros

```
CGImage Input
     │
     ▼
┌─────────────┐
│  CIContext  │
└─────┬───────┘
      │
      ▼
  IllnessFilterType?
      │
      ├─── Cataracts ─────▶ Gaussian Blur
      │                     + Contrast ↓
      │                     + Saturation ↓
      │                     + Yellow Tint
      │
      ├─── Glaucoma ──────▶ Vignette Effect
      │                     + Peripheral Darkening
      │                     + Radial Gradient
      │
      ├─── Macular ───────▶ Central Blur
      │                     + Dark Spot
      │                     + Twirl Distortion
      │
      ├─── Tunnel ────────▶ Peripheral Blur
      │                     + Radial Mask
      │                     + Feather Edge
      │
      └─── Hemianopsia ───▶ Half-Field Darkness
                            + Linear Gradient
                            + Feather
      │
      ▼
  CGImage Output
```

### Dependency Injection

```
┌─────────────────────────────────────┐
│        VisionExperience.swift              │
│           @main                     │
└───────────┬─────────────────────────┘
            │
            │ .environmentObject()
            │
            ├─────────────────┐
            │                 │
            ▼                 ▼
    ┌─────────────┐   ┌──────────────┐
    │  AppRouter  │   │  MainViewModel│
    └──────┬──────┘   └──────┬────────┘
           │                 │
           ├─────────────────┤
           │                 │
           ▼                 ▼
    ┌────────────────────────────────┐
    │         All Views              │
    │  (MainView, CameraView, etc.)  │
    └────────────────────────────────┘
```

---

## 🎯 Quick Links

### Para Desarrolladores
- [Añadir nueva enfermedad](README.md#añadir-una-nueva-enfermedad)
- [Testing](ARCHITECTURE.md#testing-architecture)
- [Patrones de diseño](ARCHITECTURE.md#patrones-de-diseño)

### Para Usuarios
- [Instalación](README.md#instalación-y-configuración)
- [Comandos de voz](README.md#comandos-de-voz)
- [Enfermedades simuladas](README.md#enfermedades-simuladas)

### Para Arquitectos
- [Capas de arquitectura](ARCHITECTURE.md#overview-de-arquitectura)
- [Flujos de datos](ARCHITECTURE.md#flujos-de-datos)
- [Gestión de estado](ARCHITECTURE.md#gestión-de-estado)

---

## 📊 Estadísticas del Proyecto

```
Documentación:
  - README.md:         905 líneas, 25KB
  - ARCHITECTURE.md:  1146 líneas, 26KB
  - DIAGRAMS.md:       154 líneas, 3.2KB
  - Total:            2205 líneas, 54KB

Diagramas Mermaid:
  - Totales:          111 diagramas
  - Tipos:            flowchart, sequenceDiagram, classDiagram,
                      stateDiagram-v2, graph TB/LR

Estructura:
  - Views:            ~25 archivos SwiftUI
  - ViewModels:       4 archivos principales
  - Services:         3 servicios core
  - Domain Models:    8 modelos + settings
```

---

## 🎨 Ver Diagramas

### En GitHub
Los diagramas Mermaid se renderizan automáticamente:
1. Ve a: https://github.com/robertteleng/once-experience
2. Navega a la rama: `fix/add-missing-sources`
3. Abre `README.md`, `ARCHITECTURE.md` o `DIAGRAMS.md`
4. Los diagramas se mostrarán renderizados

### En Xcode
- Los diagramas Mermaid aparecen como código fuente
- Usa las visualizaciones ASCII de este archivo
- O consulta `VisionExperience/Docs/Architecture.png`

### En Otros Editores
- **VSCode**: Instalar extensión "Markdown Preview Mermaid Support"
- **IntelliJ/WebStorm**: Soporte nativo de Mermaid
- **Online**: https://mermaid.live/ (pegar código Mermaid)

---

## 🔗 Enlaces Útiles

### GitHub
- **Repositorio**: https://github.com/robertteleng/once-experience
- **Pull Request**: https://github.com/robertteleng/once-experience/pull/new/fix/add-missing-sources

### Recursos Externos
- [Mermaid Syntax](https://mermaid.js.org/intro/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Core Image Filters](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/)

---

**Última actualización**: Diciembre 2, 2025  
**Versión**: 2.0.0  
**Rama**: `fix/add-missing-sources`
