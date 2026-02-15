# Camera Capture — AVFoundation

## Overview

VisionExperience usa **AVFoundation** para capturar video en tiempo real desde la cámara del dispositivo. `CameraService` encapsula toda la lógica de captura y publica frames como `CGImage`.

## Arquitectura

```
AVCaptureSession
  └── AVCaptureDeviceInput (cámara trasera)
  └── AVCaptureVideoDataOutput
        └── delegate → CameraService
              └── @Published currentFrame: CGImage?
```

## Flujo

1. `CameraService` configura `AVCaptureSession` con la cámara trasera
2. `AVCaptureVideoDataOutput` entrega frames en un `DispatchQueue` dedicado (`VisionExperience.camera.captureQueue`)
3. Cada frame (`CMSampleBuffer`) se convierte a `CGImage` via `CIContext`
4. El `CGImage` se publica como `@Published` para que las vistas SwiftUI reaccionen

## Permisos

La app requiere permiso de cámara (`NSCameraUsageDescription`) y micrófono (`NSMicrophoneUsageDescription`) configurados en el Info.plist generado automáticamente.

## Archivos clave

- `App/Services/CameraService.swift` — Servicio principal de captura
- `App/Extensions/CameraService+Extensions.swift` — Extensiones para orientación y configuración
- `App/Services/CameraError.swift` — Tipos de error de cámara

## Orientación

La orientación de la captura se actualiza según la orientación del dispositivo. `DeviceOrientationObserver` detecta cambios y `CameraService+Extensions` aplica la rotación correcta a la conexión de video.

## Consideraciones

- La sesión de captura se ejecuta en un hilo secundario dedicado
- `CIContext` se comparte (singleton en el servicio) para eficiencia
- Hay que llamar `session.startRunning()` y `session.stopRunning()` en el ciclo de vida correcto
