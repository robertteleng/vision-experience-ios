//  ImmersiveMockView.swift
//  visionApp
//  Pantalla mock en blanco para experiencias inmersivas

import SwiftUI

struct InmersiveExperienceView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Immersive Experiences")
                .font(.title)
                .foregroundColor(.gray)
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}
