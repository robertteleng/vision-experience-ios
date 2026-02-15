# Workflow — VisionExperience

Convenciones, flujo de trabajo, y reglas para contribuir al proyecto.

---

## Nomenclatura

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Tipos (struct, class, enum, protocol) | PascalCase | `CameraService`, `FilterSettings` |
| Funciones, variables, propiedades | camelCase | `startSession()`, `blurRadius` |
| Archivos Swift | PascalCase, match tipo principal | `CameraService.swift` |
| Enums cases | camelCase | `.cataracts`, `.glaucoma` |
| Dispatch queue labels | Reverse domain | `"VisionExperience.camera.captureQueue"` |
| Tags (git) | lowercase, hyphenated | `v1.0.0` |
| Carpetas | PascalCase para code, lowercase para docs | `Services/`, `filters/` |

---

## Estructura de Views SwiftUI

```swift
struct SomeView: View {
    // MARK: - Dependencies
    @EnvironmentObject var viewModel: SomeViewModel

    // MARK: - State
    @State private var isExpanded = false

    // MARK: - Properties
    private var statusText: String { ... }

    // MARK: - Body
    var body: some View { ... }

    // MARK: - Subviews
    private var headerView: some View { ... }

    // MARK: - Actions
    private func handleTap() { ... }
}
```

Extraer subview si `body` supera ~50 lineas.

---

## Estructura de Services

```swift
class SomeService: NSObject, ObservableObject {
    // MARK: - Published State
    @Published var currentFrame: CGImage?
    @Published var error: SomeError?

    // MARK: - Private
    private let queue = DispatchQueue(label: "VisionExperience.service")

    // MARK: - Public API
    func start() { ... }
    func stop() { ... }

    // MARK: - Private Methods
    private func processFrame(_ buffer: CMSampleBuffer) { ... }
}
```

---

## Patrones

### DO
- Early returns (`guard`) sobre `if/else` anidados
- `@EnvironmentObject` para inyeccion de dependencias via AppCoordinator
- `ObservableObject` + `@Published` para ViewModels y Services
- Composicion sobre herencia
- Core Image para todo procesamiento de imagen en tiempo real
- Un unico `CIContext` compartido (nunca crear por frame)
- Extensions para organizar conformances

### DO NOT
- Singletons (`shared`, `static let`)
- Force unwraps (`!`, `as!`, `try!`)
- `print()` para debugging (usar `enableDebugLogs` flag)
- SDKs prohibidos (Firebase, Realm, Alamofire, etc.)
- Crear multiples `AVCaptureSession` (iOS permite solo una)
- Crear `CIContext` por frame (rendimiento)

---

## Idiomas

| Contexto | Idioma |
|----------|--------|
| Codigo (variables, funciones, tipos) | English |
| Commits | English |
| UI labels | Spanish |
| Documentacion | Spanish |
| Comandos de voz | English |

---

## Git Flow

### Ramas

```
main
 ├── feature/add-new-illness
 ├── feature/improve-vr-mode
 ├── bugfix/fix-camera-orientation
 └── hotfix/crash-on-background
```

### Formato de Commits

```
type(scope): short description
```

**Types**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`

**Scopes**: `camera`, `filters`, `speech`, `audio`, `ui`, `vr`, `immersive`, `nav`, `models`, `config`

**Ejemplos**:
```
feat(filters): add deuteranopia color blindness simulation
feat(speech): implement voice command for intensity adjustment
fix(camera): correct orientation on iPad landscape
refactor(nav): simplify AppCoordinator speech integration
docs(learning): add spatial audio guide
test(filters): add unit tests for cataracts filter chain
perf(camera): reduce CIFilter allocations per frame
```

### Reglas
- Commits pequenos y frecuentes
- Un cambio logico por commit
- Feature branches desde `main`

---

## Testing

### Que testear
- **Domain**: `FilterSettings`, `Illness`, `IllnessFilterType` — unit tests puros
- **Services**: `CameraService`, `SpeechRecognitionService` — integration tests
- **ViewModels**: `MainViewModel`, `CameraViewModel` — unit tests con mocks
- **UI**: `VisionExperienceUITests` — launch tests, navigation flows

### Naming de tests

```swift
func test_cameraService_startsSessionSuccessfully() { ... }
func test_mainViewModel_selectsIllnessAndNavigates() { ... }
func test_filterSettings_cataracts_defaultValues() { ... }
```

---

## Dependencias

### Aprobadas — Apple Frameworks
- SwiftUI, UIKit (bridging only)
- AVFoundation, AVFAudio (camera, audio)
- CoreImage (filter processing)
- Speech (voice recognition)
- Combine (reactive bindings)
- SceneKit (360 video sphere)
- CoreMotion (head tracking, device orientation)

### Aprobadas — Externas (SPM)
- **lottie-ios** 4.6.0 — Splash screen animation only

### Prohibidas
- Firebase, Realm, Alamofire, Kingfisher, SnapKit
- Cualquier SDK que dependa de cloud
- Cualquier SDK de analytics/tracking
- CocoaPods o Carthage

### Principio
Minimas dependencias externas. Apple frameworks primero. Solo agregar externas cuando no hay alternativa viable.
