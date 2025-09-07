//
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
}
