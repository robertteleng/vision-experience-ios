//
//  IllnessSettings.swift
//  VisionExperience
//
//  Created by Roberto Rojo Sahuquillo on 11/9/25.
//

// MARK: - Settings wrapper by illness type

enum IllnessSettings: Equatable, Codable {
    case cataracts(CataractsSettings)
    case glaucoma(GlaucomaSettings)
    case macular(MacularDegenerationSettings)
    case tunnel(TunnelVisionSettings)
    case hemianopsia(HemianopsiaSettings)
    case blurryVision(BlurryVisionSettings)
    case centralScotoma(CentralScotomaSettings)
    case diabeticRetinopathy(DiabeticRetinopathySettings)
    case deuteranopia(DeuteranopiaSettings)
    case astigmatism(AstigmatismSettings)
}
