# visionApp

## Descripción General
visionApp es una aplicación iOS desarrollada en SwiftUI que simula enfermedades visuales mediante filtros aplicados en tiempo real a la imagen de la cámara. Incluye un modo Cardboard/VR para visualización inmersiva, reconocimiento de voz para control por comandos, y una arquitectura modular basada en MVVM.

---

## Índice
- [Características principales](#características-principales)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Guía de instalación y ejecución](#guía-de-instalación-y-ejecución)
- [Arquitectura y patrones](#arquitectura-y-patrones)
- [Guía de desarrollo](#guía-de-desarrollo)
  - [Navegación y estado global](#navegación-y-estado-global)
  - [Gestión de la cámara](#gestión-de-la-cámara)
  - [Simulación de enfermedades](#simulación-de-enfermedades)
  - [Modo Cardboard/VR](#modo-cardboardvr)
  - [Reconocimiento de voz](#reconocimiento-de-voz)
  - [Animaciones y recursos visuales](#animaciones-y-recursos-visuales)
- [Pruebas y calidad](#pruebas-y-calidad)
- [Documentación adicional](#documentación-adicional)
- [Preguntas frecuentes](#preguntas-frecuentes)
- [Contacto y soporte](#contacto-y-soporte)

---

## Características principales
- **Simulación de enfermedades visuales**: Selección de patologías y aplicación de filtros en tiempo real sobre la imagen de la cámara.
- **Modo Cardboard/VR**: Visualización en dos paneles para gafas tipo Cardboard.
- **Reconocimiento de voz**: Permite activar filtros y navegar mediante comandos de voz.
- **Interfaz adaptativa**: La UI se adapta a la orientación del dispositivo y muestra mensajes claros cuando es necesario girar el móvil.
- **Animaciones y recursos visuales**: Pantalla de bienvenida con animación Lottie y branding personalizado.

---

## Estructura del proyecto

```
visionApp/
├── ContentView.swift
├── visionAppApp.swift
├── Assets/
│   ├── Animations/
│   │   └── eyeAnimation.json
│   ├── Assets.xcassets/
│   └── Brand/
│       └── logo.png
├── Docs/
│   ├── architecture.md
│   ├── Architecture.png
│   └── architecture.puml
├── Extensions/
│   ├── CameraService+Extensions.swift
│   └── Image+Extensions.swift
├── Presentation/
│   ├── Camera/
│   │   ├── Components/
│   │   │   ├── ColorOverlay.swift
│   │   │   ├── FloatingGlassButton.swift
│   │   │   ├── FloatingMenu.swift
│   │   │   ├── FloatingMenuIcon.swift
│   │   │   ├── GlassSlider.swift
│   │   └── Views/
│   │       ├── CameraImageView.swift
│   │       ├── CameraPreviewView.swift
│   │       └── CameraView.swift
│   ├── CardBoard/
│   │   ├── Models/
│   │   │   └── Illness.swift
│   │   └── Views/
│   │       ├── CardboardView.swift
│   │       └── IllnessListView.swift
│   ├── Navigation/
│   │   └── NavigationViewModel.swift
│   └── Splash/
│       └── Views/
│           ├── LottieView.swift
│           └── SplashView.swift
├── Services/
│   ├── CameraService.swift
│   └── SpeechRecognitionService.swift
├── Utilities/
│   └── DeviceOrientationObserver.swift
├── visionApp.xcodeproj/
├── visionAppTests/
└── visionAppUITests/
```

---

## Guía de instalación y ejecución
1. Clona el repositorio.
2. Abre `visionApp.xcodeproj` en Xcode.
3. Ejecuta en un dispositivo físico (recomendado para pruebas de cámara y orientación).
4. Concede permisos de cámara y micrófono.

---

## Arquitectura y patrones
- **MVVM**: Separación clara entre vistas (SwiftUI), modelos de dominio y ViewModels.
- **Servicios**: Lógica de cámara y reconocimiento de voz en archivos independientes.
- **Extensiones**: Funcionalidades extra para servicios y modelos.
- **Componentes reutilizables**: Menús flotantes, sliders, overlays y animaciones.

---

## Guía de desarrollo

### Navegación y estado global
- La navegación se gestiona en `ContentView.swift` usando `NavigationViewModel`.
- El enum `AppScreen` define las pantallas principales.
- El estado global (enfermedad seleccionada, modo Cardboard, enfoque central) se gestiona en el ViewModel.

### Gestión de la cámara
- El servicio `CameraService.swift` gestiona la sesión de cámara, permisos y captura de frames.
- La vista `CameraPreviewView.swift` muestra el vídeo en vivo usando `AVCaptureVideoPreviewLayer`.
- La rotación se gestiona con `videoRotationAngle` (iOS 17+) y `CGAffineTransform` (anteriores).
- El frame capturado se publica como `UIImage` para su uso en overlays y Cardboard.

### Simulación de enfermedades
- El modelo `Illness.swift` define cada enfermedad y su filtro asociado.
- La lista de enfermedades se muestra en `IllnessListView.swift`.
- Al seleccionar una enfermedad, se actualiza el estado global y se aplica el filtro en la cámara.
- El filtro se implementa en `ColorOverlay.swift` y se aplica en tiempo real.

### Modo Cardboard/VR
- El modo Cardboard se activa desde la UI (botón de gafas).
- `CardboardView.swift` divide la imagen de la cámara en dos paneles, cada uno con su overlay.
- Se utiliza una sola instancia de la cámara para evitar conflictos con `AVCaptureVideoPreviewLayer`.
- El layout se adapta automáticamente a la orientación landscape.

### Reconocimiento de voz
- El servicio `SpeechRecognitionService.swift` gestiona la inicialización, permisos y comandos de voz.
- El ViewModel reacciona a los comandos y actualiza la navegación o el filtro.
- El reconocimiento de voz está desacoplado del ViewModel para facilitar la reutilización.

### Animaciones y recursos visuales
- La pantalla de bienvenida usa `LottieView.swift` para mostrar animaciones.
- El branding se gestiona en la carpeta `Assets/Brand/`.
- Los recursos visuales se organizan en `Assets.xcassets` y `Animations/`.

---

## Pruebas y calidad
- **visionAppTests/**: Pruebas unitarias para lógica de negocio y servicios.
- **visionAppUITests/**: Pruebas de interfaz y flujos principales.
- Se recomienda probar en dispositivo físico para validar la cámara y la orientación.

---

## Documentación adicional
- **Docs/architecture.md**: Explica la arquitectura y las decisiones de diseño.
- **Docs/Architecture.png**: Diagrama visual de la arquitectura.
- **Docs/architecture.puml**: Diagrama PlantUML editable.

---

## Preguntas frecuentes

**¿Por qué la cámara aparece girada o invertida?**
- Revisa la lógica de rotación en `CameraPreviewView.swift` y asegúrate de que los ángulos para landscapeLeft y landscapeRight están correctamente mapeados.

**¿Por qué no se ven dos paneles en modo Cardboard?**
- Verifica que `CardboardView.swift` usa una sola instancia de la cámara y divide la imagen correctamente.

**¿Cómo añado una nueva enfermedad/filtro?**
- Añade una nueva entrada en `Illness.swift` y actualiza la lógica de filtro en `ColorOverlay.swift`.

**¿Cómo se gestionan los comandos de voz?**
- Implementa la lógica en `SpeechRecognitionService.swift` y suscríbete a los cambios en el ViewModel.

---

## Contacto y soporte
Para dudas, sugerencias o soporte, contacta a Roberto Rojo Sahuquillo.

---

**visionApp** © 2025 Roberto Rojo Sahuquillo. Todos los derechos reservados.

