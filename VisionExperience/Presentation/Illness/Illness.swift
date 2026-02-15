import Foundation
import SwiftUI

struct Illness: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let description: String
    let filterType: IllnessFilterType
}
