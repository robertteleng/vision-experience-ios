import SwiftUI
import Foundation

struct ColorOverlay: View {
    let illness: Illness?
    var centralFocus: Double = 0.5
    var panel: Panel = .left

    // Optional per-panel center offset to match CameraImageView processing
    private func centerOffsetNormalized(for panel: Panel) -> CGPoint {
        switch panel {
        case .left:
            return CGPoint(x: -0.03, y: 0.0)
        case .right:
            return CGPoint(x: 0.0, y: 0.0)
        case .full:
            return .zero
        }
    }

    var body: some View {
        GeometryReader { geometry in
            // If there is no illness selected, draw nothing
            if let illness = illness {
                // We render a transparent base image and composite the CI-processed overlay result.
                // The camera feed is already drawn underneath (CameraImageView), so this overlay
                // adds illness-specific darkening/blur/tint computed by CIProcessor.
                ZStack {
                    // Create a transparent CGImage with the view size to feed into CIProcessor
                    if let overlayImage = makeOverlayImage(size: geometry.size, illness: illness) {
                        Image(decorative: overlayImage, scale: 1.0, orientation: .up)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .allowsHitTesting(false)
                    } else {
                        Color.clear
                            .allowsHitTesting(false)
                    }
                }
            } else {
                Color.clear
                    .allowsHitTesting(false)
            }
        }
    }

    // Build a transparent CGImage, process it via CIProcessor, and return the result.
    // We use a transparent base so CIProcessor can generate darkening/blur/vignette regions
    // relative to the panel size and center offset.
    private func makeOverlayImage(size: CGSize, illness: Illness) -> CGImage? {
        guard size.width > 0, size.height > 0 else { return nil }

        // Create a transparent CGImage of the required size
        let width = Int(size.width.rounded(.up))
        let height = Int(size.height.rounded(.up))

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // Combine byte order with alpha info (premultipliedFirst)
        let alphaInfo = CGImageAlphaInfo.premultipliedFirst
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.union(CGBitmapInfo(rawValue: alphaInfo.rawValue))

        guard let ctx = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: 0,
                                  space: colorSpace,
                                  bitmapInfo: bitmapInfo.rawValue)
        else { return nil }

        // Fill with transparent
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

        guard let transparentBase = ctx.makeImage() else { return nil }

        // Run CI processing on this transparent base as an overlay generator
        let processed = CIProcessor.shared.apply(
            illness: illness,
            centralFocus: centralFocus,
            to: transparentBase,
            panelSize: size,
            centerOffsetNormalized: centerOffsetNormalized(for: panel)
        )
        return processed
    }
}
