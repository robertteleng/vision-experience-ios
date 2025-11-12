//
//  IllnessFilterType.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 3/9/25.
//

enum IllnessFilterType: String, Codable, CaseIterable, Identifiable {
    case cataracts
    case glaucoma
    case macularDegeneration
    case tunnelVision // Visión en túnel
    case hemianopsia // Nueva opción para hemianopsia
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
        }
    }
}
