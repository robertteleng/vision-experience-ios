//
//  CameraView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

/// Enum representing all navigation routes in the app.
enum AppRoute {
    case home
    case splash
    case illnessList
    case camera
    case immersiveVideo // New route for 360º video with spatial audio
}

/// AppRouter manages navigation state for the app.
class AppRouter: ObservableObject {
    @Published var currentRoute: AppRoute = .home
    // Métodos para navegar, push/pop, etc. si lo necesitas
}
