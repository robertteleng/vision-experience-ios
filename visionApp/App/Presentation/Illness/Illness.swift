import Foundation
import SwiftUI

enum IllnessFilterType: String, Codable, CaseIterable, Identifiable {
    case cataracts
    case glaucoma
    case macularDegeneration
    var id: String { rawValue }
}

struct Illness: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let description: String
    let filterType: IllnessFilterType
}
