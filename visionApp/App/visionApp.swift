//
//  App.swift
//  visionApp
//
// Created by Roberto Rojo Sahuquillo on 4/8/25.
//
//  Updated to use dependency injection with AppCoordinator
//

import SwiftUI

@main
struct VisionApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appCoordinator.router)
                .environmentObject(appCoordinator.mainViewModel)
                .environmentObject(appCoordinator.speechViewModel)
                .environmentObject(appCoordinator.orientationObserver)
                .onAppear {
                    appCoordinator.startApp()
                }
        }
    }
}
