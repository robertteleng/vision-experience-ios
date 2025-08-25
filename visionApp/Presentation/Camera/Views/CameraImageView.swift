import SwiftUI

enum CameraPanel {
    case left, right
}

struct CameraImageView: View {
    let image: UIImage?
    let panel: CameraPanel

    func croppedImage(_ image: UIImage?, panel: CameraPanel) -> UIImage? {
        guard let cgImage = image?.cgImage else { return nil }
        let halfWidth = cgImage.width / 2
        let height = cgImage.height
        let rect: CGRect
        if panel == .left {
            rect = CGRect(x: 0, y: 0, width: halfWidth, height: height)
        } else {
            rect = CGRect(x: halfWidth, y: 0, width: halfWidth, height: height)
        }
        guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: croppedCGImage)
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let cropped = croppedImage(image, panel: panel) {
                    Image(uiImage: cropped)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Color.black
                }
            }
        }
    }
}
