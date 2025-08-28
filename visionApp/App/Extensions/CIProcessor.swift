// filepath: /Users/robertorojosahuquillo/Desktop/visionApp/visionApp/App/Extensions/CIProcessor.swift
import UIKit
import CoreImage

enum CIProcessingError: Error {
    case failed
}

struct CIProcessor {
    static let shared = CIProcessor()
    private let context = CIContext(options: nil)

    func apply(illness: Illness?, centralFocus: Double, to image: UIImage, panelSize: CGSize) -> UIImage {
        guard let ciInput = CIImage(image: image) else { return image }
        let clamped = ciInput.clampedToExtent()
        let extent = clamped.extent

        var output = clamped
        let focus = max(0.0, min(1.0, centralFocus))
        let w = panelSize.width > 0 ? panelSize.width : extent.width
        let h = panelSize.height > 0 ? panelSize.height : extent.height
        let center = CGPoint(x: w * 0.5, y: h * 0.5)

        switch illness?.filterType {
        case .glaucoma:
            // Create a radial mask to darken periphery (tunnel vision)
            let startRadius = max(10.0, focus * 60.0)
            let endRadius = max(startRadius + 40.0, focus * 260.0)
            if let grad = CIFilter(name: "CIRadialGradient", parameters: [
                kCIInputCenterKey: CIVector(cgPoint: center),
                "inputRadius0": startRadius,
                "inputRadius1": endRadius,
                "inputColor0": CIColor(red: 0, green: 0, blue: 0, alpha: 0),
                "inputColor1": CIColor(red: 0, green: 0, blue: 0, alpha: 1)
            ])?.outputImage?.cropped(to: extent) {
                if let comp = CIFilter(name: "CIMultiplyCompositing", parameters: [kCIInputImageKey: grad, kCIInputBackgroundImageKey: output])?.outputImage {
                    output = comp
                }
            }
        case .cataracts:
            // Blur + bloom + slight desaturation, parameterized via CIConfig
            let cfg = CIConfig.shared
            let blurRadius = focus * 20.0 + 4.0
            if let blur = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey: output, kCIInputRadiusKey: blurRadius])?.outputImage?.cropped(to: extent) {
                output = blur
            }
            let bloomIntensity = cfg.cataractsBloomIntensityBase + cfg.cataractsBloomIntensityScale * focus
            let bloomRadius = cfg.cataractsBloomRadiusBase + cfg.cataractsBloomRadiusScale * focus
            if let bloomed = CIFilter(name: "CIBloom", parameters: [
                kCIInputImageKey: output,
                kCIInputIntensityKey: bloomIntensity,
                kCIInputRadiusKey: bloomRadius
            ])?.outputImage?.cropped(to: extent) {
                output = bloomed
            }
            let saturation = max(0.0, 1.0 - cfg.cataractsDesaturationMax * focus)
            let contrast = 1.0 - cfg.cataractsContrastDropMax * focus
            if let colorAdj = CIFilter(name: "CIColorControls", parameters: [
                kCIInputImageKey: output,
                kCIInputSaturationKey: saturation,
                kCIInputBrightnessKey: 0.0,
                kCIInputContrastKey: contrast
            ])?.outputImage?.cropped(to: extent) {
                output = colorAdj
            }
        case .macularDegeneration:
            // Central yellow spot reducing clarity
            let radius = max(20.0, focus * 220.0)
            if let spot = CIFilter(name: "CIRadialGradient", parameters: [
                kCIInputCenterKey: CIVector(cgPoint: center),
                "inputRadius0": radius * 0.4,
                "inputRadius1": radius,
                "inputColor0": CIColor(red: 1, green: 0.9, blue: 0.2, alpha: 0.7),
                "inputColor1": CIColor(red: 1, green: 0.9, blue: 0.2, alpha: 0)
            ])?.outputImage?.cropped(to: extent) {
                if let comp = CIFilter(name: "CIMultiplyCompositing", parameters: [kCIInputImageKey: spot, kCIInputBackgroundImageKey: output])?.outputImage {
                    output = comp
                }
            }
            // Localized blur to reduce central clarity
            if let blur = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey: clamped, kCIInputRadiusKey: 6 + focus * 8])?.outputImage,
               let mask = CIFilter(name: "CIRadialGradient", parameters: [
                kCIInputCenterKey: CIVector(cgPoint: center),
                "inputRadius0": radius * 0.2,
                "inputRadius1": radius,
                "inputColor0": CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                "inputColor1": CIColor(red: 1, green: 1, blue: 1, alpha: 0)
               ])?.outputImage?.cropped(to: extent),
               let blend = CIFilter(name: "CIBlendWithMask", parameters: [
                kCIInputImageKey: blur.cropped(to: extent),
                kCIInputBackgroundImageKey: output,
                kCIInputMaskImageKey: mask
               ])?.outputImage {
                output = blend
            }
        default:
            break
        }

        if let cg = context.createCGImage(output, from: extent) {
            return UIImage(cgImage: cg)
        }
        return image
    }
}
