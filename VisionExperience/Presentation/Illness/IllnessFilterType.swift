//
//  IllnessFilterType.swift
//  VisionExperience
//
//  Created by Roberto Rojo Sahuquillo on 3/9/25.
//

enum IllnessFilterType: String, Codable, CaseIterable, Identifiable {
    case cataracts
    case glaucoma
    case macularDegeneration
    case tunnelVision
    case hemianopsia
    case blurryVision
    case centralScotoma
    case diabeticRetinopathy
    case deuteranopia
    case astigmatism
    
    var id: String { rawValue }
}

extension IllnessFilterType {
    var symbolName: String {
        switch self {
        case .cataracts:
            return "eye"
        case .glaucoma:
            return "eyeglasses"
        case .macularDegeneration:
            return "dot.circle"
        case .tunnelVision:
            return "circle"
        case .hemianopsia:
            return "eye.slash"
        case .blurryVision:
            return "cloud"
        case .centralScotoma:
            return "circle.circle"
        case .diabeticRetinopathy:
            return "waveform.path.ecg"
        case .deuteranopia:
            return "paintpalette"
        case .astigmatism:
            return "line.3.crossed.swirl.circle"
        }
    }
    
    var displayName: String {
        switch self {
        case .cataracts:
            return "Cataracts"
        case .glaucoma:
            return "Glaucoma"
        case .macularDegeneration:
            return "Macular Degeneration"
        case .tunnelVision:
            return "Tunnel Vision"
        case .hemianopsia:
            return "Hemianopsia"
        case .blurryVision:
            return "Blurry Vision"
        case .centralScotoma:
            return "Central Scotoma"
        case .diabeticRetinopathy:
            return "Diabetic Retinopathy"
        case .deuteranopia:
            return "Deuteranopia"
        case .astigmatism:
            return "Astigmatism"
        }
    }
}
