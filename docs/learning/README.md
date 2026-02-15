# Learning — Guías Técnicas

Guías teóricas organizadas por dominio. Cada una explica los conceptos, frameworks y patrones necesarios para trabajar en esa área del proyecto.

---

## Workstreams

### 1. Filtros Visuales — `filters/`

| Guía | Qué Explica |
|------|-------------|
| **core_image_filters.md** | Pipeline Core Image: CIFilter, CIContext, cadenas de filtros, parámetros por enfermedad, rendimiento en tiempo real |
| **camera_capture.md** | AVFoundation: configuración de AVCaptureSession, captura de frames como CGImage, orientación, permisos |

**Orden de lectura:**
1. camera_capture.md (captura de video)
2. core_image_filters.md (procesamiento de filtros)

### 2. Experiencia Inmersiva — `immersive/`

| Guía | Qué Explica |
|------|-------------|
| **spatial_audio.md** | AVAudioEngine + AVAudioEnvironmentNode (HRTF), head tracking con AirPods y CoreMotion, sincronización con video |
| **video_360.md** | Video equirectangular en SceneKit (esfera invertida), CADisplayLink para frames, filtros sobre textura, AVPlayer sin audio |

**Orden de lectura:**
1. video_360.md (renderizado 360°)
2. spatial_audio.md (audio espacial)

---

## Cuándo leer estas guías

- **Antes de tocar CameraService o CIProcessor** → filters/
- **Antes de tocar ImmersiveVideoView o SpatialAudioService** → immersive/
- **Para entender la arquitectura general** → README.md en la raíz del proyecto
