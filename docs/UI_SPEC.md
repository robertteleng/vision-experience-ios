# UI Spec — VisionExperience

Especificacion visual generada desde `vision-experience-ui.pen`. Referencia para implementar y mantener la interfaz de usuario.

---

## Design Tokens

### Colores — Backgrounds

| Token | Hex | Uso |
|-------|-----|-----|
| `bg-page` | `#0B0B0E` | Fondo principal de la app |
| `bg-card` | `#16161A` | Fondo de cards, paneles, menus |
| `bg-elevated` | `#1A1A1E` | Fondo de elementos elevados |

### Colores — Texto

| Token | Hex | Uso |
|-------|-----|-----|
| `text-primary` | `#FAFAF9` | Titulos, texto principal |
| `text-secondary` | `#6B6B70` | Subtitulos, labels secundarios |
| `text-tertiary` | `#4A4A50` | Texto deshabilitado, hints |

### Colores — Bordes

| Token | Hex | Uso |
|-------|-----|-----|
| `border-subtle` | `#2A2A2E` | Bordes de cards, separadores, tracks de sliders |

### Colores — Accents

| Token | Hex | Uso |
|-------|-----|-----|
| `accent-blue` | `#007AFF` | Acciones primarias, sliders activos, boton de filtros |
| `accent-green` | `#32D583` | Estado activo, indicadores positivos, slider focus |
| `accent-coral` | `#E85A4F` | Boton immersive, badge 360, barra de progreso video |
| `accent-indigo` | `#6366F1` | Boton illness, elementos de seleccion |
| `accent-amber` | `#FFB547` | Warnings, estados pendientes |

### Colores — Especiales

| Color | Hex | Uso |
|-------|-----|-----|
| LIVE red | `#FF3B30` | Badge LIVE en camera view |
| HRTF purple | `#AF52DE` | Badge HRTF en spatial audio |
| Overlay | `#00000080` | Overlays semi-transparentes (badges, botones sobre video) |

---

## Tipografia

### Fuentes

| Rol | Fuente | Peso | Uso |
|-----|--------|------|-----|
| Display | Fraunces | 700 (Bold) | Titulos principales, headings de pantalla |
| Body | DM Sans | 400 (Regular) | Texto general, labels, badges |
| Body | DM Sans | 500 (Medium) | Labels enfatizados |
| Body | DM Sans | 700 (Bold) | Badges, botones, titulos de seccion |

### Escala

| Elemento | Fuente | Tamano | Peso |
|----------|--------|--------|------|
| Titulo pantalla | Fraunces | 28px | Bold |
| Subtitulo pantalla | DM Sans | 14px | Regular |
| Titulo seccion | DM Sans | 14px | Bold |
| Nombre enfermedad | DM Sans | 15px | Medium |
| Label slider | DM Sans | 11px | Regular |
| Valor slider | DM Sans | 11px | Regular |
| Badge texto | DM Sans | 11px | Bold |
| Status texto | DM Sans | 10px | Regular |
| Boton texto | DM Sans | 16px | Bold |

---

## Componentes

### Botones

#### Boton Primario (Gradient)
- **Illness**: Fill `#6366F1`, cornerRadius 16, padding 16x48
- **Immersive**: Fill `#E85A4F`, cornerRadius 16, padding 16x48
- Ambos con shadow glow del color del fondo (20% opacidad, blur 20)
- Texto: DM Sans 16px Bold, blanco
- Width: `fill_container` con maxWidth ~300px

#### Boton Flotante (Icon)
- Size: 40x40
- Fill: `#2A2A2E` (inactivo), `#007AFF` (activo)
- CornerRadius: 12
- Icon: 16-18px, centrado, blanco

#### Boton Circular (Back/Play)
- Back: 36x36, fill `#00000080`, cornerRadius 18
- Play: 80x80, fill `#FFFFFF20`, stroke `#FFFFFF40` 2px, cornerRadius 40

### Cards

#### Disease Row
- Width: `fill_container`
- Fill: `#16161A`
- CornerRadius: 12
- Padding: 14px horizontal, 14px vertical
- Layout: horizontal, gap 12, alignItems center
- Contenido: Icon (20x20, color por enfermedad) + Nombre (15px Medium) + Chevron (right-aligned, `#4A4A50`)

#### Floating Panel (Filters/Audio)
- Fill: `#16161ACC` (80% opacidad)
- CornerRadius: 16
- Padding: 16px horizontal, 14px vertical
- Layout: vertical, gap 10-12
- Backdrop: glassmorphism en la app real

### Badges

#### LIVE Badge
- Fill: `#FF3B30`
- CornerRadius: 6
- Padding: 8x4
- Contenido: Dot (6x6 ellipse blanca) + "LIVE" (11px Bold blanco)

#### Disease Badge
- Fill: `#00000080`
- CornerRadius: 6
- Padding: 10x4
- Texto: 12px Medium, `text-primary`

#### 360° Badge
- Fill: `#E85A4F`
- CornerRadius: 8
- Padding: 10x4
- Texto: 11px Bold blanco

#### HRTF Badge
- Fill: `#AF52DE33` (20% opacidad)
- CornerRadius: 6
- Padding: 8x3
- Texto: 10px Bold, `#AF52DE`

### Sliders

- Track: height 4, fill `#2A2A2E`, cornerRadius 2
- Fill: height 4, fill `accent-blue` o `accent-green`, cornerRadius 2
- Thumb: 14x14 ellipse, fill blanco
- Label row: justifyContent space_between
  - Nombre: 11px Regular, `text-secondary`
  - Valor: 11px Regular, `text-primary`

### Floating Menu

- Fill: `#16161A99` (60% opacidad)
- CornerRadius: 16
- Padding: 8px horizontal, 10px vertical
- Layout: vertical, gap 8
- Contenido: 4 botones flotantes apilados verticalmente

---

## Pantallas

### 1. Splash

- **Orientacion**: Portrait (402x874)
- **Fondo**: `bg-page` (#0B0B0E)
- **Contenido**: Centrado vertical
  - Logos row (universidad + proyecto) en la parte superior
  - Icono ojo con glow radial (#6366F1 → transparente)
  - El ojo es un icon_font con halo de luz

### 2. Home

- **Orientacion**: Portrait (402x874)
- **Fondo**: `bg-page`
- **Layout**: vertical, centrado, gap 8
- **Contenido**:
  - Titulo: "Welcome to VisionExperience" — Fraunces 28px Bold
  - Subtitulo: "Simulate visual diseases in real-time" — DM Sans 14px, `text-secondary`
  - Boton Illness: gradient indigo, icon sparkle + texto
  - Boton Immersive: gradient coral, icon + texto
  - Botones con box-shadow glow del color accent

### 3. Illness List

- **Orientacion**: Portrait (402x874)
- **Fondo**: `bg-page`
- **Layout**: vertical, gap 10, padding 20
- **Contenido**:
  - Titulo: "Select Disease" — Fraunces 24px Bold
  - 7 Disease Rows:

| Enfermedad | Color Icon |
|------------|-----------|
| Cataracts | `#007AFF` (blue) |
| Glaucoma | `#32D583` (green) |
| Macular Degeneration | `#FFB547` (amber) |
| Tunnel Vision | `#AF52DE` (purple) |
| Hemianopsia | `#6366F1` (indigo) |
| Blurry Vision | `#6B6B70` (gray) |
| Central Scotoma | `#E85A4F` (coral) |

### 4. Camera View

- **Orientacion**: Landscape (874x402)
- **Fondo**: Feed de camara en vivo (negro cuando inactivo)
- **Layout**: none (posicionamiento absoluto)
- **Contenido**:
  - **Top Bar** (x:16, y:16): LIVE badge + Disease badge + Intensity badge
  - **Floating Menu** (x:16, y:120): 4 botones apilados (Back, Filters, VR, Mic)
  - **Filters Panel** (x:580, y:60): Panel glassmorphism con 3 sliders
    - Blur Radius (blue)
    - Opacity (blue)
    - Central Focus (green)
  - **Bottom Status** (x:80, y:370): Voice Active indicator + FPS counter

### 5. Immersive 360

- **Orientacion**: Portrait (402x874)
- **Fondo**: Video 360° equirectangular (negro cuando inactivo)
- **Layout**: none (posicionamiento absoluto)
- **Contenido**:
  - **Top Gradient**: 120px, negro → transparente
  - **Top Row** (y:52): Back button circular + Title column + 360° badge
  - **Play Button** (centro): 80x80, circular con stroke, icono play
  - **Compass** (derecha): 44x44, muestra orientacion (N/S/E/W)
  - **Spatial Audio Card** (y:660): Panel glassmorphism
    - Header: "Spatial Audio" + HRTF badge
    - Stats row: Source (AirPods Pro), Head Tracking (Active), Position (0°, 0°, 0°)
  - **Bottom Gradient**: 100px, negro → transparente
  - **Progress Bar** (y:830): Track + fill coral
  - **Time Row** (y:842): tiempo actual / duracion total

---

## Iconografia

Los iconos de enfermedades usan SF Symbols en la app real:

| Enfermedad | SF Symbol | Color |
|------------|-----------|-------|
| Cataracts | `eye` | `#007AFF` |
| Glaucoma | `circle.circle` | `#32D583` |
| Macular Degeneration | `dot.circle.and.hand.point.up.left.fill` | `#FFB547` |
| Tunnel Vision | `camera.metering.spot` | `#AF52DE` |
| Hemianopsia | `rectangle.lefthalf.inset.filled` | `#6366F1` |
| Blurry Vision | `drop.fill` | `#6B6B70` |
| Central Scotoma | `record.circle` | `#E85A4F` |
| Diabetic Retinopathy | `circle.hexagongrid.fill` | `#FF9500` |
| Deuteranopia | `paintpalette` | `#34C759` |
| Astigmatism | `rays` | `#8E8E93` |

---

## Modo Oscuro

La app es **dark-only**. No hay modo claro.

- `.preferredColorScheme(.dark)` en ContentView
- Todos los tokens estan definidos para dark mode
- El fondo `#0B0B0E` es mas oscuro que el system dark default de iOS

---

## Glassmorphism

Los paneles flotantes (FilterPanel, FloatingMenu, SpatialAudioCard) usan:

```swift
.background(.ultraThinMaterial)
.background(Color("bg-card").opacity(0.8))
.cornerRadius(16)
```

En el .pen se simula con fill semi-transparente (`#16161ACC` o `#16161A99`).

---

## Notas de Implementacion

- **Camera View es landscape**: Rotacion automatica, layout absolute
- **Immersive 360 es portrait**: Pero el video es equirectangular esfera
- **Sliders en SwiftUI**: Usar `GlassSlider` custom (ya existe en `Components/`)
- **Floating Menu**: Usar `FloatingMenu` component (ya existe)
- **Progress bar**: No existe componente, implementar con `GeometryReader`
- **Fuentes custom (Fraunces/DM Sans)**: Si no estan bundled, fallback a system serif/sans
- **Colores**: Definir en `Assets.xcassets` como named colors para facil acceso

---

## Fuente de Verdad

> El archivo `vision-experience-ui.pen` es la referencia visual. Si hay discrepancia entre este spec y el .pen, **el .pen gana**. Si hay discrepancia entre el .pen y el codigo, **el codigo gana**.
