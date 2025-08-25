//
//  visionAppApp.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 4/8/25.
//

import SwiftUI

@main
struct visionAppApp: App {
    var router = AppRouter()
    var globalViewModel = GlobalViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DeviceOrientationObserver.shared)
                .environmentObject(router)
                .environmentObject(globalViewModel)
        }
    }
}
