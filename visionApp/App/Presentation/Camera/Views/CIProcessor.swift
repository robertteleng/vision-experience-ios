//
//  CIProcessor.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//
//  Simple Core Image processor that applies illness-specific effects to a UIImage.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

final class CIProcessor {
    static let shared = CIProcessor()
    
    private let context = CIContext(options: nil)
    
    private init() {}
    
    /// Applies effect to a CGImage and returns CGImage (UIKit-free).
    func apply(
        illness: Illness?,
        centralFocus: Double,
        to image: CGImage,
        panelSize: CGSize,
        centerOffsetNormalized: CGPoint = .zero
    ) -> CGImage {
        guard let illness = illness else { return image }
        
        let inputCI = CIImage(cgImage: image)
        let clampedFocus = max(0.0, min(1.0, centralFocus))
        
        let baseCenter = CGPoint(x: inputCI.extent.midX, y: inputCI.extent.midY)
        let offsetPx = CGPoint(
            x: centerOffsetNormalized.x * inputCI.extent.width,
            y: centerOffsetNormalized.y * inputCI.extent.height
        )
        let effectCenter = CGPoint(x: baseCenter.x + offsetPx.x, y: baseCenter.y + offsetPx.y)
        
        let outputCI: CIImage
        switch illness.filterType {
        case .cataracts:
            // 1. Desenfoque para visión nublada
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = inputCI
            blur.radius = Float(clampedFocus * 20.0)  // ISMA: Esto empezaba en 5, por eso con el slider al mínimo ya se veía borroso. Así va de 0 a 20
            let blurred = blur.outputImage?.clamped(to: inputCI.extent) ?? inputCI // Esto es para evitar que los bordes de la imagen se expandan al desenfocar y los limita a los de la imagen original https://developer.apple.com/documentation/coreimage/ciimage/clamped(to:)
            
            // 2. Reducción de contraste: tienen problemas para distinguir detalles
            let colorControls = CIFilter.colorControls()
            colorControls.inputImage = blurred
            colorControls.contrast = Float(1.0 - clampedFocus * 0.4)  // Reduce contraste
            colorControls.saturation = Float(1.0 - clampedFocus * 0.3)  // Reduce saturación
            
            // 3. Colores desvaídos o amarillentos -> le ponemos un color amarillento
            let colorMatrix = CIFilter.colorMatrix()
            colorMatrix.inputImage = colorControls.outputImage ?? blurred
            colorMatrix.rVector = CIVector(x: 1.0, y: 0, z: 0, w: 0)
            colorMatrix.gVector = CIVector(x: 0, y: 1.0 - CGFloat(clampedFocus * 0.1), z: 0, w: 0)
            colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.0 - CGFloat(clampedFocus * 0.2), w: 0)
            
            outputCI = colorMatrix.outputImage ?? blurred
            
//        case .glaucoma:
//            // Obtener la imagen original
//            let currentImage = inputCI
//
//            // 2. Crear una máscara de gradiente radial con variaciones
//            let radialGradient = CIFilter.radialGradient()
//            radialGradient.center = effectCenter
//            
//            // Ajustar los radios en función de clampedFocus
//            let minRadius = Float(min(inputCI.extent.width, inputCI.extent.height) * 0.1) // Área clara
//            let maxRadius = Float(min(inputCI.extent.width, inputCI.extent.height) * 0.8) // Borde más amplio
//
//            // Calcular los radios en función de clampedFocus
//            radialGradient.radius0 = minRadius + (maxRadius - minRadius) * Float((1 - clampedFocus)) // Radio interior (transparente) se reduce
//            radialGradient.radius1 = maxRadius // Radio exterior permanece constante
//
//            radialGradient.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 1) // Negro en los bordes
//            radialGradient.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 0) // Totalmente transparente
//
//            guard let maskImage = radialGradient.outputImage?.cropped(to: inputCI.extent) else {
//                print("Error: No se pudo crear la máscara de gradiente radial.")
//                return context.createCGImage(currentImage, from: inputCI.extent) ?? image
//            }
//
//            // 3. Combinar la imagen desenfocada con la imagen original usando la máscara
//            let composite = CIFilter.blendWithAlphaMask()
//            composite.inputImage = currentImage           // Imagen original
//            composite.maskImage = maskImage               // Máscara para mezclar
//
//            guard let outputImage = composite.outputImage else {
//                print("Error: No se pudo crear la imagen final.")
//                return context.createCGImage(currentImage, from: inputCI.extent) ?? image
//            }
//            
//            print("Clamped Focus: \(clampedFocus)")
            
//            // 4. Oscurecer la imagen combinando con un overlay oscuro
//            let darkOverlay = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 1)) // Ajusta el alpha
//            let darkImage = darkOverlay.cropped(to: inputCI.extent)
//
//            // 5. Combinar la imagen final con la capa oscura
//            let finalComposite = CIFilter.blendWithAlphaMask()
//            finalComposite.inputImage = outputImage
//            finalComposite.backgroundImage = darkImage
//            finalComposite.maskImage = maskImage // Usar la misma máscara para oscurecer
//
//            guard let finalOutputImage = finalComposite.outputImage else {
//                print("Error: No se pudo crear la imagen final con oscurecimiento.")
//                return context.createCGImage(currentImage, from: inputCI.extent) ?? image
//            }
//            
//            outputCI = finalOutputImage
            
        case .glaucoma:
        
            let vignette = CIFilter.vignette()
            vignette.inputImage = inputCI
            vignette.intensity = Float(0.8 + clampedFocus * 1.2)
            vignette.radius = Float(0.8 + clampedFocus * 1.0)
            let first = vignette.outputImage ?? inputCI

            let vignetteEffect = CIFilter.vignetteEffect()
            vignetteEffect.inputImage = first
            vignetteEffect.center = effectCenter
            let minSide = min(inputCI.extent.width, inputCI.extent.height)
            vignetteEffect.radius = Float(minSide * (2 * (1.0 - clampedFocus)))
            vignetteEffect.intensity = Float(0.7 + 0.8 * clampedFocus)
            outputCI = vignetteEffect.outputImage ?? first


        case .macularDegeneration:
            let minSide = min(inputCI.extent.width, inputCI.extent.height)
            let innerRadius = CGFloat(10 + clampedFocus * 60)
            let outerRadius = CGFloat(innerRadius + minSide * (0.2 + 0.25 * clampedFocus))
            
            // 1. Creamos un gradiente radial
            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(innerRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)  // Centro transparente
            radial.color1 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)  // Borde blanco
            let gradient = radial.outputImage?.cropped(to: inputCI.extent) ?? inputCI
            
            // 2. Aplicacmos desenfoque a la imagen original
            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = inputCI
            blurFilter.radius = Float(clampedFocus * 10) // Esto lo puedes ajustar según sea necesario para mayor o menor radio de desenfoque
            let blurredImage = blurFilter.outputImage?.clamped(to: inputCI.extent) ?? inputCI
            
            // 3. Oscurecer la imagen
            let darkColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0.65) // Ajusta el alfa para más o menos oscuridad
            let darkOverlay = CIImage(color: darkColor).cropped(to: inputCI.extent)
            
            // 4. eSTO crea un efecto de distorsión central, como el del glaucoma que se intenta tener en el exterior del círculo
            let distortion = CIFilter.twirlDistortion()
            distortion.inputImage = gradient
            distortion.center = CGPoint(x: effectCenter.x, y: effectCenter.y)
            distortion.radius = Float(innerRadius)
            distortion.angle = Float(clampedFocus * Double.pi)
            
            // 5. Como antes, combinamos todo
            let blend = CIFilter.blendWithMask()
            blend.inputImage = blurredImage // Imagen con el efecto de desenfoque
            blend.backgroundImage = darkOverlay // Capa oscura
            blend.maskImage = distortion.outputImage // Máscara distorsionada
            
            outputCI = blend.outputImage ?? inputCI
        
        case .tunnelVision:
            let minSide = min(inputCI.extent.width, inputCI.extent.height)

            // Radio mínimo del túnel (aproximadamente 1 cm como porcentaje del lado más corto)
            let minTunnelRadiusPercentage: CGFloat = 0.05 // 5%
            let minTunnelRadius = minSide * minTunnelRadiusPercentage

            // Radio máximo del túnel (toda la imagen)
            let maxTunnelRadius = minSide / 2.0  // La mitad del lado más corto

            // Convertir el clampedFocus en un radio que podamos aplicar al túnel
            let tunnelRadius = minTunnelRadius + (maxTunnelRadius - minTunnelRadius) * clampedFocus

            // Calcular el feather en relación al radio del túnel (ajustar estos valores)
            let feather = tunnelRadius * (0.12 + 0.08 * (1.0 - clampedFocus)) //ajustar el factor

            let outerRadius = tunnelRadius + feather

            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = inputCI
            blurFilter.radius = Float(4 + (1.0 - clampedFocus) * 10.0)
            let blurred = blurFilter.outputImage?.clampedToExtent().cropped(to: inputCI.extent) ?? inputCI

            let radial = CIFilter.radialGradient()
            radial.center = effectCenter
            radial.radius0 = Float(tunnelRadius)
            radial.radius1 = Float(outerRadius)
            radial.color0 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
            radial.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
            let mask = radial.outputImage?.cropped(to: inputCI.extent) ?? inputCI

            let multiply = CIFilter.multiplyCompositing()
            multiply.inputImage = mask
            multiply.backgroundImage = blurred
            let darkenedPeripheral = multiply.outputImage?.cropped(to: inputCI.extent) ?? blurred

            let composite = CIFilter.blendWithMask()
            composite.inputImage = inputCI
            composite.backgroundImage = darkenedPeripheral
            composite.maskImage = mask
            outputCI = composite.outputImage ?? inputCI

        }
        
        return context.createCGImage(outputCI, from: inputCI.extent) ?? image
    }
}


#Preview {
    let image: UIImage = UIImage(systemName: "photo")!
    let processor = CIProcessor.shared
    
    GeometryReader { geo in
        
        Image(uiImage: UIImage(cgImage: processor.apply(
            illness: Illness(name: "Prueba", description: "Prueba", filterType: .glaucoma),
            centralFocus: 1,
            to: image.cgImage!,
            // Max width and max height for the preview
            panelSize: CGSize(width: geo.size.width, height: geo.size.height),
            centerOffsetNormalized: .zero
        )))
        .resizable()
        .scaledToFit()
        .ignoresSafeArea()
        
    }
    
}
