//
//  IllnessSettings.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 11/9/25.
//

// MARK: - Settings wrapper by illness type

enum IllnessSettings: Equatable, Codable {
    case cataracts(CataractsSettings)
    case glaucoma(GlaucomaSettings)
    case macular(MacularDegenerationSettings)
    case tunnel(TunnelVisionSettings)
}
