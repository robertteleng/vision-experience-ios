# CLAUDE.md — VisionExperience

## Project Identity

- **App**: VisionExperience — Simulador de enfermedades visuales en tiempo real
- **What it does**: Aplica filtros Core Image sobre la cámara para simular cómo ve una persona con cataratas, glaucoma, degeneración macular, etc. Incluye modo Cardboard VR, video 360° con audio espacial, y control por voz
- **Target user**: Estudiantes de medicina, profesionales de la salud, público general (concienciación)
- **Language**: Code and commits in English. UI text in Spanish
- **Bundle ID**: `com.robert.rjsh.VisionExperience`

## Critical Constraints

| # | Constraint | Why |
|---|-----------|-----|
| 1 | **iOS 18+ only** | Latest SwiftUI, Core Image, Speech APIs |
| 2 | **All processing on-device** | Privacy, no cloud dependency |
| 3 | **SPM only** | No CocoaPods, no Carthage |
| 4 | **Core Image for filters** | Real-time GPU-accelerated filtering on camera frames |
| 5 | **Single external dependency: Lottie** | Splash animation only — everything else is Apple frameworks |

## Architecture Overview

```
iPhone Camera                    VisionExperience App
┌──────────────┐                ┌─────────────────────────────────────────┐
│ AVCapture     │ ────frames──▶ │ CameraService (AVCaptureSession)        │
│ Session       │               │   ↓                                     │
└──────────────┘                │ CIProcessor (Core Image filter chain)   │
                                │   ↓                                     │
                                │ CameraViewModel (processed CGImage)     │
                                │   ↓                                     │
                                │ SwiftUI Views (Camera / Cardboard / VR) │
                                └─────────────────────────────────────────┘

360° Video Mode:
  AVPlayer → SceneKit sphere → CIFilter on texture → head tracking (CMMotion)
  AVAudioEngine + AVAudioEnvironmentNode → HRTF spatial audio (AirPods)
```

### Pattern: MVVM + Coordinator

```
AppCoordinator (owns all services and ViewModels)
  ├── AppRouter (navigation state)
  ├── MainViewModel (illness selection, filter state)
  ├── SpeechRecognitionViewModel (voice commands)
  └── DeviceOrientationObserver (landscape/portrait)
```

## Architecture Rules

### DO

- Use **SwiftUI** for all views
- Use **ObservableObject + @Published** for ViewModels (current pattern)
- Use **@EnvironmentObject** for dependency injection from AppCoordinator
- Use **Core Image** (CIFilter) for all real-time image processing
- Use **early returns** (`guard`) over nested `if/else`
- Use **structs** for models, **classes** for services and ViewModels
- Keep services stateless where possible — state lives in ViewModels

### DO NOT

| Bad | Good | Why |
|-----|------|-----|
| Singletons (`shared`, `static let`) | Dependency injection via AppCoordinator | Testability |
| `try!`, `as!`, `implicitly unwrapped` | `guard let`, `if let` | Crash-free code |
| `print()` for debugging | `enableDebugLogs` flag in CameraService | Conditional logging |
| Firebase, Realm, Alamofire | Apple frameworks | Minimal dependencies |
| Creating CIContext per frame | Shared `CIContext` in CameraService | Performance |
| Multiple camera sessions | Single `AVCaptureSession` | iOS allows only one |

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Types (struct, class, enum, protocol) | PascalCase | `CameraService`, `FilterSettings` |
| Functions, variables, properties | camelCase | `startSession()`, `blurRadius` |
| Files | PascalCase matching type | `CameraService.swift` |
| Enums cases | camelCase | `.cataracts`, `.glaucoma` |
| Dispatch queue labels | Reverse domain | `"VisionExperience.camera.captureQueue"` |

## File Organization

```
VisionExperience/
├── App/
│   ├── VisionExperienceApp.swift      # @main entry point
│   ├── Domain/                         # Data models (structs, enums)
│   │   ├── FilterSettings.swift        # Per-illness filter parameters
│   │   ├── IllnessSettings.swift       # Enum wrapper for all settings
│   │   └── VRSettings.swift            # Cardboard VR parameters
│   ├── Services/                       # Business logic
│   │   ├── CameraService.swift         # AVCaptureSession + frame output
│   │   ├── CameraError.swift           # Camera error enum
│   │   ├── SpeechRecognitionService.swift  # Speech-to-text
│   │   └── SpatialAudioService.swift   # AVAudioEngine + HRTF
│   ├── Extensions/
│   │   ├── CameraService+Extensions.swift  # Orientation updates
│   │   └── Image+Extensions.swift
│   ├── Utils/
│   │   ├── CIConfig.swift              # Core Image configuration
│   │   ├── DeviceOrientationObserver.swift
│   │   ├── HeadOrientationProvider.swift       # Phone gyroscope
│   │   ├── HeadphoneHeadOrientationProvider.swift  # AirPods head tracking
│   │   └── VoiceCommandsTestView.swift
│   └── Presentation/
│       ├── Navigation/
│       │   ├── AppRouter.swift          # Route enum + @Published state
│       │   ├── AppCoordinator.swift     # DI container + speech integration
│       │   ├── FilterTuningViewModel.swift
│       │   └── SpeechRecognitionViewModel.swift
│       ├── Main/
│       │   ├── MainView.swift           # Root view (route switch)
│       │   ├── MainViewModel.swift      # Illness + filter state
│       │   └── HomeView.swift           # Welcome screen
│       ├── Camera/
│       │   ├── CameraViewModel.swift
│       │   └── Views/
│       │       ├── CameraView.swift     # Main camera screen
│       │       ├── CameraPreviewView.swift
│       │       ├── CameraImageView.swift
│       │       └── CIProcessor.swift    # Core Image filter chain
│       ├── Illness/
│       │   ├── Illness.swift            # Illness model
│       │   ├── IllnessFilterType.swift  # Filter type enum
│       │   └── IllnessListView.swift    # Disease selector
│       ├── Splash/Views/
│       │   ├── SplashView.swift         # Lottie animation + logos
│       │   └── LottieView.swift         # UIViewRepresentable wrapper
│       ├── CardBoard/
│       │   └── CardboardView.swift      # Stereoscopic VR mode
│       ├── InmersiveVideo/
│       │   └── ImmersiveVideoView.swift # 360° video on SceneKit sphere
│       └── Components/                  # Reusable UI
│           ├── CompactFiltersPanel.swift
│           ├── FloatingGlassButton.swift
│           ├── FloatingMenu.swift
│           ├── FloatingMenuIcon.swift
│           ├── GlassSlider.swift
│           └── Panel.swift
├── Assets/
│   ├── Assets.xcassets/                # App icon, colors, logos
│   ├── Animations/eyeAnimation.json    # Lottie splash animation
│   └── Brand/                          # Logo PNGs
└── LICENSE
```

## Simulated Diseases

| Disease | Filter Type | Key Parameters |
|---------|------------|----------------|
| Cataracts | Blur + brightness + saturation | `blurRadius`, `cloudiness`, `brightness` |
| Glaucoma | Tunnel vignette | `tunnelRadius`, `vignetteFalloff`, `contrast` |
| Macular Degeneration | Central blur + distortion | `centralBlurRadius`, `distortionAmount`, `twirl` |
| Tunnel Vision | Circular mask + edge blur | `tunnelRadius`, `edgeSoftness`, `darknessLevel` |
| Hemianopsia | Half-field darkness | `side`, `transitionSoftness`, `darkness` |
| Blurry Vision | Gaussian blur | `blurAmount`, `clarity` |
| Central Scotoma | Central dark spot | `scotomaRadius`, `darkness`, `edgeBlur` |
| Diabetic Retinopathy | Cataracts variant | Uses `CataractsSettings` |
| Deuteranopia | Color blindness | Uses `CataractsSettings` |
| Astigmatism | Directional blur | Uses `CataractsSettings` |

## Navigation Routes

```swift
enum AppRoute {
    case splash          // Lottie animation → auto-navigate to illnessList
    case home            // Welcome screen
    case illnessList     // Disease selector (speech enabled)
    case camera          // Live camera with filters (speech always active)
    case immersiveVideo  // 360° video with spatial audio
}
```

## Privacy Permissions Required

| Permission | Key | Usage |
|-----------|-----|-------|
| Camera | `NSCameraUsageDescription` | Real-time video capture |
| Microphone | `NSMicrophoneUsageDescription` | Voice commands |
| Speech Recognition | `NSSpeechRecognitionUsageDescription` | Voice command processing |

## Approved Dependencies

### Apple Frameworks
- SwiftUI, UIKit (bridging only)
- AVFoundation, AVFAudio (camera, audio)
- CoreImage (filter processing)
- Speech (voice recognition)
- Combine (reactive bindings)
- SceneKit (360° video sphere)
- CoreMotion (head tracking, device orientation)

### External (SPM)
- **lottie-ios** 4.6.0 — Splash screen animation only

### NEVER
- Firebase, Realm, Alamofire, Kingfisher
- Any cloud-dependent SDK
- Any analytics/tracking SDK
- CocoaPods or Carthage packages

## Git & Commits

### Format
```
type(scope): short description
```

### Types
`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`

### Scopes
`camera`, `filters`, `speech`, `audio`, `ui`, `vr`, `immersive`, `nav`, `models`, `config`

## Documentation Map

| File | Purpose |
|------|---------|
| **CLAUDE.md** | You are here. Rules for AI/devs |
| [README.md](README.md) | Everything: architecture, features, diseases, setup |
| [docs/DOCUMENTATION_GUIDE.md](docs/DOCUMENTATION_GUIDE.md) | What each doc is and reading order |
| [docs/WORKFLOW.md](docs/WORKFLOW.md) | Git flow, naming, testing, conventions |
| [docs/IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) | Roadmap by phases with milestones |
| [docs/UI_SPEC.md](docs/UI_SPEC.md) | Visual spec: colors, typography, components |
| [docs/project/CHANGELOG.md](docs/project/CHANGELOG.md) | Development history |
| [docs/learning/README.md](docs/learning/README.md) | Index of technical guides |
| [docs/learning/filters/](docs/learning/filters/) | Core Image pipeline, camera capture |
| [docs/learning/immersive/](docs/learning/immersive/) | 360° video, spatial audio |

## Interaction Rules

1. **Read this file before writing code**
2. **Read README.md for full context** before making structural decisions
3. **Follow existing patterns** — look at CameraService, CIProcessor, AppCoordinator
4. **Ask before creating files** or making structural decisions
5. **"build" = write code. "review" = only analyze**
6. **If something is unclear, flag it — don't guess**
7. **Diagnose before fixing** — understand the root cause before changing code
8. **Never assume — verify first** — read existing code before modifying
9. **Keep filter logic in CIProcessor** — all Core Image chains go through one place
10. **Speech commands route through AppCoordinator** — never handle voice in views directly
