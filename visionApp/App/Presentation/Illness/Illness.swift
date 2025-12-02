import Foundation
import SwiftUI

<<<<<<< HEAD


=======
>>>>>>> illness-filters-temp
struct Illness: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let description: String
    let filterType: IllnessFilterType
}
