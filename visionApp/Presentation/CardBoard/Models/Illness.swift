import Foundation
import SwiftUI

struct Illness: Identifiable {
    let id: UUID = UUID()
    let name: String
    let description: String
    let filterType: IllnessFilterType
}

enum IllnessFilterType: String, CaseIterable {
    case glaucoma
    case cataracts
    case macularDegeneration
    case retinitisPigmentosa
    // Puedes añadir más tipos de filtro aquí
}
