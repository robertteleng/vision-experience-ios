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
    case tunnelVision // Added tunnel vision filter type
    var id: String { rawValue }
}
