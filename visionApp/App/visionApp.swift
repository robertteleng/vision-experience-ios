//
//  visionApp.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 4/8/25.
//

import SwiftUI

@main
struct visionApp: App {
    var router = AppRouter()
    var mainViewModel = MainViewModel()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(DeviceOrientationObserver.shared)
                .environmentObject(router)
                .environmentObject(mainViewModel)
        }
    }
}
