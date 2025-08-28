//
//  visionApp.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 4/8/25.
//
//  This file defines the main entry point for the visionApp SwiftUI application.
//  It sets up the root scene and injects shared environment objects for navigation,
//  view models, and device orientation observation. The @main attribute marks this
//  struct as the application's entry point.
//

import SwiftUI

/// The main application struct for visionApp.
/// - Sets up the root scene and injects shared environment objects.
@main
struct visionApp: App {
    /// Router for managing navigation between views.
    var router = AppRouter()
    /// Main view model containing app state and logic.
    var mainViewModel = MainViewModel()
    /// View model for filter tuning functionality.
    var filterTuningViewModel = FilterTuningViewModel()
    var body: some Scene {
        WindowGroup {
            // The root view of the app.
            MainView()
                // Injects a shared device orientation observer.
                .environmentObject(DeviceOrientationObserver.shared)
                // Injects the navigation router.
                .environmentObject(router)
                // Injects the main view model.
                .environmentObject(mainViewModel)
                // Injects the filter tuning view model.
                .environmentObject(filterTuningViewModel)
        }
    }
}
