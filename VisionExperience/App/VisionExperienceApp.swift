//
//  VisionExperienceApp.swift
//  VisionExperience
//
// Created by Roberto Rojo Sahuquillo on 4/8/25.
//

import SwiftUI

@main
struct VisionExperienceApp: App {
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
