# Video 360° — SceneKit + Core Image

## Overview

VisionExperience reproduce video 360° equirectangular dentro de una esfera invertida de SceneKit, con filtros de enfermedad visual aplicados en tiempo real sobre cada frame.

## Arquitectura

```
AVPlayer (muted)
  └── AVPlayerItemVideoOutput
        └── CADisplayLink (60fps)
              └── copyPixelBuffer
                    └── CIProcessor (filtros)
                          └── SCNSphere (textura diffuse)
```

## Flujo de datos

1. **AVPlayer** reproduce el video 360° (silenciado — el audio va por otro canal)
2. **AVPlayerItemVideoOutput** permite extraer pixel buffers del video
3. **CADisplayLink** sincroniza la extracción de frames con el refresh rate de la pantalla
4. Cada frame se filtra con **CIProcessor** (mismos filtros que la cámara)
5. El resultado se aplica como textura `diffuse` a una **SCNSphere invertida** (normales hacia dentro)
6. El usuario mira "desde dentro" de la esfera → experiencia 360°

## Head tracking

- **AirPods (prioridad):** `CMHeadphoneMotionManager` via `HeadphoneHeadOrientationProvider`
- **Fallback:** `CMMotionManager` del teléfono via `HeadOrientationProvider`
- Botón "Recenter" para alinear yaw

## Sincronización video/audio

- Play/Pause: sincroniza `AVPlayer` con `SpatialAudioService.setPlaying()`
- Seek: `AVPlayer.seek(to:)` + `SpatialAudioService.seek(to:)` se disparan juntos
- El AVPlayer está **muted** para evitar doble audio

## Archivos clave

- `App/Presentation/InmersiveVideo/ImmersiveVideoView.swift` — Vista completa
- `App/Utils/CIProcessor.swift` — Filtros sobre frames del video
- `App/Utils/HeadphoneHeadOrientationProvider.swift` — Head tracking AirPods
- `App/Utils/HeadOrientationProvider.swift` — Head tracking teléfono

## Rendimiento

- `hasNewPixelBuffer` evita procesar frames duplicados
- `autoreleasepool` en el bucle de CADisplayLink
- Limpieza en `dismantleUIView` para evitar leaks
