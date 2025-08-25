import SwiftUI

struct ColorOverlay: View {
    let illness: Illness?
    var centralFocus: Double = 0.5

    var overlayColor: Color {
        switch illness?.filterType {
        case .cataracts:
            return Color.white.opacity(0.6)
        case .glaucoma:
            return Color.black.opacity(0.5)
        case .macularDegeneration:
            return Color.yellow.opacity(0.4)
        default:
            return Color.clear
        }
    }

    var body: some View {
        if illness?.filterType == .glaucoma {
            RadialGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                center: .center,
                startRadius: CGFloat(centralFocus * 50),
                endRadius: CGFloat(centralFocus * 200)
            )
            .blendMode(.multiply)
        } else {
            Rectangle()
                .fill(overlayColor)
                .blendMode(.multiply)
        }
    }
}
