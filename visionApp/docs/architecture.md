visionApp/
├── App/
│   └── visionAppApp.swift           // Punto de entrada
├── Presentation/
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── SplashView.swift
│   │   ├── IllnessListView.swift
│   │   └── CameraView.swift
│   ├── ViewModels/
│   │   └── NavigationViewModel.swift
│   └── Components/
│       └── LottieView.swift
├── Domain/
│   ├── Models/
│   │   └── Illness.swift
│   └── Enums/
│       └── AppScreen.swift
├── Services/
│   ├── Speech/
│   │   └── SpeechRecognitionService.swift
│   └── TTS/
│       └── TextToSpeechService.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Animations/
│   │   └── eyeAnimation.json
│   └── logo.png
├── Extensions/
│   └── UIDevice+Orientation.swift
└── Utilities/
    └── FeedbackGenerator.swift
