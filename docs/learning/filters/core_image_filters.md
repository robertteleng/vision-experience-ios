# Core Image Filters — Pipeline de Filtros Visuales

## Overview

VisionExperience usa **Core Image** (framework de Apple) para aplicar filtros visuales en tiempo real sobre los frames de la cámara. Cada enfermedad visual se simula con una cadena específica de `CIFilter`.

## Pipeline

```
CGImage (cámara) → CIImage → CIFilter chain → CIContext.render → CGImage (display)
```

1. **CameraService** publica frames como `CGImage` via `@Published`
2. **CIProcessor** convierte a `CIImage` y aplica la cadena de filtros
3. El resultado se renderiza de vuelta a `CGImage` con un `CIContext` compartido

## Filtros por Enfermedad

| Enfermedad | Filtros CIFilter | Parámetros clave |
|-----------|-----------------|-----------------|
| **Cataratas** | Blur + Contrast + Color tint | blur radius, contrast reduction, yellow tint |
| **Glaucoma** | Vignette + Darkening | vignette intensity, radius |
| **Degeneración Macular** | Central blur + Twirl | center position, blur radius |
| **Visión Túnel** | Peripheral blur | tunnel radius, blur amount |

## Archivos clave

- `App/Presentation/Camera/Views/CIProcessor.swift` — Aplica la cadena de filtros
- `App/Utils/CIConfig.swift` — Configuración y parámetros por filtro
- `App/Domain/FilterSettings.swift` — Modelo con valores de cada parámetro
- `App/Presentation/Illness/IllnessFilterType.swift` — Enum que mapea enfermedad → tipo de filtro

## Consideraciones de rendimiento

- **CIContext** se crea una sola vez y se reutiliza (crear uno por frame es muy costoso)
- Los filtros se aplican en el hilo de captura, no en el main thread
- `autoreleasepool` en el bucle de frames para evitar acumulación de memoria
- Core Image gestiona GPU automáticamente — no hay que manejar Metal directamente

## Cómo añadir un nuevo filtro

1. Añadir caso en `IllnessFilterType`
2. Definir parámetros en `FilterSettings`
3. Implementar la cadena de `CIFilter` en `CIProcessor`
4. Añadir la enfermedad en `Illness.swift`
