//
//  CameraView.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 5/8/25.
//

import SwiftUI

enum AppRoute {
    case splash, illnessList, camera
}

class AppRouter: ObservableObject {
    @Published var currentRoute: AppRoute = .splash
    // Métodos para navegar, push/pop, etc. si lo necesitas
}
