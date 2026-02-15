//  HomeView.swift
//  VisionExperience

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Text("Welcome to VisionExperience")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 32)
            Button(action: { router.currentRoute = .illnessList }) {
                FloatingGlassButton(title: "Illness", iconName: "cross.case", action: {})
            }
            Button(action: { router.currentRoute = .immersiveVideo }) {
                FloatingGlassButton(title: "Immersive Experiences", iconName: "sparkles", action: {})
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
