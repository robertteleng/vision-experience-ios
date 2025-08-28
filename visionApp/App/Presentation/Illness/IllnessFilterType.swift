//
//  IllnessFilterType.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 28/8/25.
//

enum IllnessFilterType: String, Codable, CaseIterable, Identifiable {
    case cataracts
    case glaucoma
    case macularDegeneration
    // New common conditions
    case diabeticRetinopathy
    case colorBlindnessDeuteranopia
    case astigmatism
    var id: String { rawValue }
}
