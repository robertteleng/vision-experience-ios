# visionApp

## Descripción General
visionApp es una aplicación iOS desarrollada en SwiftUI que simula enfermedades visuales mediante filtros aplicados en tiempo real a la imagen de la cámara. La app ahora centraliza la navegación con un router de aplicación y un coordinador de arranque, incorpora un flujo de splash inicial y mantiene un modo Cardboard/VR para visualización inmersiva, además de reconocimiento de voz para control por comandos. Arquitectura modular basada en MVVM con servicios desacoplados.

---co

## Novedades (Agosto 2025)
- Nuevo enrutamiento centralizado con `AppRouter` y orquestación de inicio con `AppCoordinator`.
- Nuevas rutas en `AppRoute`: `splash`, `illnessList`, `camera`.
- `VisionApp` (punto de entrada) inyecta dependencias vía `environmentObject` y llama a `startApp()`.
- `MainViewModel` ahora expone `currentRoute` y helpers de navegación (`updateCurrentRoute`, `navigateBack`).
- Limpieza y alineación de nombres de vistas y servicios (consistencia con Camera/Cardboard/Illness).
- Documentación ampliada de arquitectura y navegación.

---

## Índice
- [Características principales](#características-principales)
- [Novedades (Agosto 2025)](#novedades-agosto-2025)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Guía de instalación y ejecución](#guía-de-instalación-y-ejecución)
- [Arquitectura y patrones](#arquitectura-y-patrones)
- [Guía de desarrollo](#guía-de-desarrollo)
  - [Navegación y estado global](#navegación-y-estado-global)
  - [Enrutamiento con AppRouter](#enrutamiento-con-approuter)
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

