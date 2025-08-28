//
//  Untitled.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 28/8/25.
//

import Foundation

enum IllnessFilterType: String, Codable, CaseIterable, Identifiable {
    case glaucoma
    case cataracts
    case diabeticRetinopathy
    case deuteranopia
    case astigmatism
    case macularDegeneration
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .glaucoma: return "Glaucoma"
        case .cataracts: return "Cataracts"
        case .diabeticRetinopathy: return "Diabetic Retinopathy"
        case .deuteranopia: return "Deuteranopia"
        case .astigmatism: return "Astigmatism"
        case .macularDegeneration: return "Macular Degeneration"
        }
    }
}
