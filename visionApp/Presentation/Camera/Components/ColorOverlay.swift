import SwiftUI

struct ColorOverlay: View {
    let illness: Illness?
    var centralFocus: Double = 0.5
    var panel: Panel = .left // Nuevo parámetro para saber si es el panel izquierdo o derecho

    enum Panel {
        case left, right
    }

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
        GeometryReader { geometry in
            switch illness?.filterType {
            case .glaucoma:
                RadialGradient(
                    gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                    center: .center,
                    startRadius: CGFloat(centralFocus * 50),
                    endRadius: CGFloat(centralFocus * 200)
                )
                .blendMode(.multiply)
            case .cataracts:
                Rectangle()
                    .fill(overlayColor)
                    .blendMode(.multiply)
                    .blur(radius: CGFloat(centralFocus * 20))
            case .macularDegeneration:
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                    Circle()
                        .fill(overlayColor)
                        .frame(width: CGFloat(centralFocus * 300), height: CGFloat(centralFocus * 300))
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .blendMode(.multiply)
            default:
                Rectangle()
                    .fill(Color.clear)
            }
        }
    }
}
