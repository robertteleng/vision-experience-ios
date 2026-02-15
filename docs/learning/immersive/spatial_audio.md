# Audio Espacial — AVAudioEngine + HRTF

## Overview

VisionExperience implementa audio espacial usando **AVAudioEngine** con **AVAudioEnvironmentNode** para crear una experiencia HRTF (Head-Related Transfer Function) que posiciona el audio en el espacio 3D relativo a la cabeza del usuario.

## Arquitectura

```
AVAssetReader (audio track del video)
  └── Mix a mono float32
        └── AVAudioEngine
              └── AVAudioEnvironmentNode (HRTF)
                    └── Output (auriculares)
```

## Flujo

1. **AVAssetReader** decodifica la pista de audio del mismo video 360°
2. El audio se mezcla a **mono float32** (requisito para spatialización)
3. Se envía a **AVAudioEngine** con un **AVAudioEnvironmentNode**
4. El nodo aplica **HRTF spatialization** según la orientación de la cabeza
5. El audio sale por los auriculares con posición espacial

## Head tracking para audio

El mismo sistema de head tracking que usa el video 360° alimenta al `AVAudioEnvironmentNode`:

- **AirPods:** `CMHeadphoneMotionManager` (más preciso, menor latencia)
- **Fallback:** `CMMotionManager` del teléfono
- "Recenter" alinea el yaw de referencia

## API principal — SpatialAudioService

| Método | Qué hace |
|--------|----------|
| `setPlaying(Bool)` | Play/pause sincronizado con video |
| `seek(to: CMTime)` | Seek sincronizado con AVPlayer |
| `setGain(Float)` | Control de volumen |
| `setMuted(Bool)` | Silenciar/activar |

## Archivos clave

- `App/Services/SpatialAudioService.swift` — Servicio completo de audio espacial
- `App/Utils/HeadphoneHeadOrientationProvider.swift` — Datos de orientación AirPods
- `App/Utils/HeadOrientationProvider.swift` — Datos de orientación teléfono

## Consideraciones

- AVPlayer se silencia (`isMuted = true`) para evitar doble audio
- Interrupciones de audio (llamadas, etc.) requieren manejo de `AVAudioSession`
- El seek debe ser atómico: video + audio a la vez
