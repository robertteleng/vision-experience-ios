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
            let cfg = CIConfig.shared
            let startRadius = max(10.0, focus * cfg.glauStartRadiusScale)
            let endRadius = max(startRadius + cfg.glauEndRadiusExtra, focus * cfg.glauEndRadiusScale)
            let edgeAlpha = min(1.0, cfg.glauEdgeAlphaMax)
            if let grad = CIFilter(name: "CIRadialGradient", parameters: [
                kCIInputCenterKey: CIVector(cgPoint: center),
                "inputRadius0": startRadius,
                "inputRadius1": endRadius,
                "inputColor0": CIColor(red: 0, green: 0, blue: 0, alpha: 0),
                "inputColor1": CIColor(red: 0, green: 0, blue: 0, alpha: edgeAlpha)
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
            let cfg = CIConfig.shared
            let radius = max(cfg.mdSpotRadiusMin, focus * cfg.mdSpotRadiusScale)
            if let spot = CIFilter(name: "CIRadialGradient", parameters: [
                kCIInputCenterKey: CIVector(cgPoint: center),
                "inputRadius0": radius * cfg.mdSpotInnerFactor,
                "inputRadius1": radius,
                "inputColor0": CIColor(red: 1, green: 0.9, blue: 0.2, alpha: cfg.mdSpotColorAlpha),
                "inputColor1": CIColor(red: 1, green: 0.9, blue: 0.2, alpha: 0)
            ])?.outputImage?.cropped(to: extent) {
                if let comp = CIFilter(name: "CIMultiplyCompositing", parameters: [kCIInputImageKey: spot, kCIInputBackgroundImageKey: output])?.outputImage {
                    output = comp
                }
            }
            if let blur = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey: clamped, kCIInputRadiusKey: cfg.mdBlurBase + focus * cfg.mdBlurScale])?.outputImage,
               let mask = CIFilter(name: "CIRadialGradient", parameters: [
                kCIInputCenterKey: CIVector(cgPoint: center),
                "inputRadius0": radius * cfg.mdMaskInnerFactor,
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
        case .diabeticRetinopathy:
            let cfg = CIConfig.shared
            // Grainy speckles + slight vignette to simulate hemorrhages and uneven vision
            if let noise = CIFilter(name: "CIRandomGenerator")?.outputImage?
                .transformed(by: CGAffineTransform(scaleX: max(0.6, 1.2 - 0.6 * focus), y: max(0.6, 1.2 - 0.6 * focus)))
                .cropped(to: extent),
               let tinted = CIFilter(name: "CIColorMonochrome", parameters: [
                kCIInputImageKey: noise,
                kCIInputColorKey: CIColor(red: 0.35, green: 0.05, blue: 0.05, alpha: 1.0),
                kCIInputIntensityKey: 1.0
               ])?.outputImage,
               let noiseAlpha = CIFilter(name: "CIColorMatrix", parameters: [
                kCIInputImageKey: tinted,
                "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: min(1.0, cfg.drSpeckleOpacityMax * (0.5 + 0.5 * focus))),
                "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)
               ])?.outputImage?.cropped(to: extent),
               let comp = CIFilter(name: "CISourceOverCompositing", parameters: [
                kCIInputImageKey: noiseAlpha,
                kCIInputBackgroundImageKey: output
               ])?.outputImage?.cropped(to: extent) {
                output = comp
            }
            if let vig = CIFilter(name: "CIVignette", parameters: [
                kCIInputImageKey: output,
                kCIInputIntensityKey: cfg.drVignetteIntensityBase + cfg.drVignetteIntensityScale * focus,
                kCIInputRadiusKey: cfg.drVignetteRadiusBase + cfg.drVignetteRadiusScale * focus
            ])?.outputImage?.cropped(to: extent) {
                output = vig
            }
        case .colorBlindnessDeuteranopia:
            // Deuteranopia approximation via color matrix, blended by strength * focus
            let cfg = CIConfig.shared
            if let transformed = CIFilter(name: "CIColorMatrix", parameters: [
                kCIInputImageKey: output,
                "inputRVector": CIVector(x: 0.625, y: 0.375, z: 0, w: 0),
                "inputGVector": CIVector(x: 0.70, y: 0.30, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1.0, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.0),
                "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)
            ])?.outputImage?.cropped(to: extent),
               let alphaAdj = CIFilter(name: "CIColorMatrix", parameters: [
                kCIInputImageKey: transformed,
                "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: max(0.0, min(1.0, cfg.deuteranopiaStrengthMax * focus))),
                "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)
               ])?.outputImage,
               let mix = CIFilter(name: "CISourceOverCompositing", parameters: [
                kCIInputImageKey: alphaAdj,
                kCIInputBackgroundImageKey: output
               ])?.outputImage?.cropped(to: extent) {
                output = mix
            }
        case .astigmatism:
            let cfg = CIConfig.shared
            // Directional blur + slight ghosting/doubling
            let angle = cfg.astigAngleDegrees * .pi / 180.0
            let blurRadius = cfg.astigMotionRadiusBase + cfg.astigMotionRadiusScale * focus
            if let motion = CIFilter(name: "CIMotionBlur", parameters: [
                kCIInputImageKey: output,
                kCIInputRadiusKey: blurRadius,
                kCIInputAngleKey: angle
            ])?.outputImage?.cropped(to: extent) {
                output = motion
            }
            // ghost: slightly shifted original blended over
            let dx = 2.0 + 6.0 * focus
            let shifted = clamped.transformed(by: CGAffineTransform(translationX: dx, y: 0)).cropped(to: extent)
            if let alphaShift = CIFilter(name: "CIColorMatrix", parameters: [
                kCIInputImageKey: shifted,
                "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: cfg.astigGhostAlphaBase + cfg.astigGhostAlphaScale * focus),
                "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)
               ])?.outputImage,
               let comp = CIFilter(name: "CISourceOverCompositing", parameters: [
                kCIInputImageKey: alphaShift,
                kCIInputBackgroundImageKey: output
               ])?.outputImage?.cropped(to: extent) {
                output = comp
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
