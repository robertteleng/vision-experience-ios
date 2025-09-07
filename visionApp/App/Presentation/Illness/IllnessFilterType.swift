//
<<<<<<< HEAD
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
=======
//  IllnessFilterType.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 3/9/25.
//

enum IllnessFilterType: String, Codable, CaseIterable, Identifiable {
    case cataracts                 // Puede representar “visión borrosa” si ajustas sus parámetros
    case glaucoma                  // Reducción periférica (visión en túnel)
    case macularDegeneration       // Alteraciones centrales/degenerativas
    case tunnelVision              // Reducción periférica de campo visual
    case centralScotoma            // Escotoma central
    case hemianopsia               // Hemianopsia (izquierda/derecha/superior/inferior)
    case blurryVision              // Visión borrosa pura (opcional, separada de cataracts)
    
    var id: String { rawValue }
>>>>>>> illness-filters-temp
}
