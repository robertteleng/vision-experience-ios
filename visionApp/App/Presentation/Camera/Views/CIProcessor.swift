//
//  CIProcessor.swift
//  visionApp
//
//  Created by Roberto Rojo Sahuquillo on 25/8/25.
//
//  Procesador simple de Core Image que aplica efectos específicos de enfermedades a una UIImage.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

final class CIProcessor {
    static let shared = CIProcessor() // Instancia única (singleton) del procesador
    
    private let context = CIContext(options: nil) // Contexto de Core Image para realizar operaciones
    
    private init() {} // Inicializador privado para evitar la creación de instancias adicionales
    
    /// Aplica efecto a un CGImage y devuelve CGImage (sin UIKit).
    func apply(
        illness: Illness?, // Enfermedad a la cual se aplicará el efecto
        centralFocus: Double, // Foco central para el efecto
        to image: CGImage, // Imagen de entrada
        panelSize: CGSize, // Tamaño del panel para la imagen
        centerOffsetNormalized: CGPoint = .zero // Desplazamiento normalizado para centrar el efecto
    ) -> CGImage {
        guard let illness = illness else { return image } // Si no hay enfermedad, se devuelve la imagen original
        
        let inputCI = CIImage(cgImage: image) // Crea un CIImage a partir del CGImage original
        let clampedFocus = max(0.0, min(1.0, centralFocus)) // Asegura que el foco esté entre 0 y 1
        
        // Calcula la posición central de la imagen
        let baseCenter = CGPoint(x: inputCI.extent.midX, y: inputCI.extent.midY)
        // Calcula el desplazamiento en píxeles basado en el desplazamiento normalizado
        let offsetPx = CGPoint(
            x: centerOffsetNormalized.x * inputCI.extent.width,
            y: centerOffsetNormalized.y * inputCI.extent.height
        )
        // Combina la posición central y el desplazamiento para determinar el centro del efecto
        let effectCenter = CGPoint(x: baseCenter.x + offsetPx.x, y: baseCenter.y + offsetPx.y)
        
        let outputCI: CIImage // Imagen de salida donde se aplicarán los efectos
        switch illness.filterType {
        case .cataracts: // Efectos para cataratas
            // 1. Desenfoque para visión nublada
            let blur = CIFilter.gaussianBlur() // Crea un filtro de desenfoque gaussiano
            blur.inputImage = inputCI // Asigna la imagen de entrada
            blur.radius = Float(clampedFocus * 20.0) // Ajusta el radio del desenfoque según el foco
            let blurred = blur.outputImage?.clamped(to: inputCI.extent) ?? inputCI // Limita el desenfoque a los bordes de la imagen
            
            // 2. Reducción de contraste: las personas con cataratas tienen problemas para distinguir detalles
            let colorControls = CIFilter.colorControls() // Crea un filtro para ajustar color y contraste
            colorControls.inputImage = blurred // Asigna la imagen desenfocada
            colorControls.contrast = Float(1.0 - clampedFocus * 0.4) // Reduce el contraste
            colorControls.saturation = Float(1.0 - clampedFocus * 0.3) // Reduce la saturación
            
            // 3. Colores desvaídos o amarillentos -> le ponemos un color amarillento
            let colorMatrix = CIFilter.colorMatrix() // Crea un filtro de matriz de color
            colorMatrix.inputImage = colorControls.outputImage ?? blurred // Asigna la imagen ajustada
            colorMatrix.rVector = CIVector(x: 1.0, y: 0, z: 0, w: 0) // Componente rojo
            colorMatrix.gVector = CIVector(x: 0, y: 1.0 - CGFloat(clampedFocus * 0.1), z: 0, w: 0) // Componente verde
            colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.0 - CGFloat(clampedFocus * 0.2), w: 0) // Componente azul
            
            outputCI = colorMatrix.outputImage ?? blurred // Establece la imagen de salida
        
        case .glaucoma: // Efectos para el glaucoma
            let vignette = CIFilter.vignette() // Crea un filtro de viñeteado
            vignette.inputImage = inputCI // Asigna la imagen de entrada
            vignette.intensity = Float(0.8 + clampedFocus * 1.2) // Ajusta la intensidad
            vignette.radius = Float(0.8 + clampedFocus * 1.0) // Ajusta el radio
            let first = vignette.outputImage ?? inputCI // Aplica el viñeteado

            let vignetteEffect = CIFilter.vignetteEffect() // Crea un filtro de efecto de viñeteado
            vignetteEffect.inputImage = first // Asigna la imagen con viñeteado
            vignetteEffect.center = effectCenter // Establece el centro del efecto
            let minSide = min(inputCI.extent.width, inputCI.extent.height) // Encuentra el lado más corto de la imagen
            vignetteEffect.radius = Float(minSide * (2 * (1.0 - clampedFocus))) // Ajusta el radio del efecto
            vignetteEffect.intensity = Float(clampedFocus) // Ajusta la intensidad del efecto
            outputCI = vignetteEffect.outputImage ?? first // Establece la imagen de salida

        case .macularDegeneration: // Efectos para la degeneración macular
            let minSide = min(inputCI.extent.width, inputCI.extent.height) // Encuentra el lado más corto de la imagen
            let innerRadius = CGFloat(clampedFocus * 60) // Radio interno ajustable
            let outerRadius = CGFloat(innerRadius + minSide * (0.5 * clampedFocus)) // Radio externo ajustable
            
            // 1. Creamos un gradiente radial
            let radial = CIFilter.radialGradient() // Crea un filtro de gradiente radial
            radial.center = effectCenter // Establece el centro del gradiente
            radial.radius0 = Float(innerRadius) // Radio interno del gradiente
            radial.radius1 = Float(outerRadius) // Radio externo del gradiente
            radial.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)  // Centro transparente
            radial.color1 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)  // Borde blanco
            let gradient = radial.outputImage?.cropped(to: inputCI.extent) ?? inputCI // Recorta el gradiente a los límites de la imagen
            
            // 2. Aplicamos desenfoque a la imagen original
            let blurFilter = CIFilter.gaussianBlur() // Crea un filtro de desenfoque
            blurFilter.inputImage = inputCI // Asigna la imagen original
            blurFilter.radius = Float(clampedFocus * 5) // Ajusta el radio de desenfoque según el foco
            let blurredImage = blurFilter.outputImage?.clamped(to: inputCI.extent) ?? inputCI // Limita el desenfoque a los bordes de la imagen
            
            // 3. Oscurecer la imagen
            let darkColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0.65) // Color oscuro con cierta opacidad
            let darkOverlay = CIImage(color: darkColor).cropped(to: inputCI.extent) // Crea una capa oscura
            
            // 4. Crea un efecto de distorsión central
            let distortion = CIFilter.twirlDistortion() // Crea un filtro de distorsión
            distortion.inputImage = gradient // Asigna el gradiente como entrada
            distortion.center = CGPoint(x: effectCenter.x, y: effectCenter.y) // Establece el centro de distorsión
            distortion.radius = Float(innerRadius) // Establece el radio de distorsión
            distortion.angle = Float(clampedFocus * Double.pi) // Ajusta el ángulo de distorsión
            
            // 5. Combina todo
            let blend = CIFilter.blendWithMask() // Crea un filtro para combinar imágenes con máscara
            blend.inputImage = blurredImage // Imagen con efecto de desenfoque
            blend.backgroundImage = darkOverlay // Capa oscura
            blend.maskImage = distortion.outputImage // Máscara distorsionada
            
            outputCI = blend.outputImage ?? inputCI // Establece la imagen de salida
        
        case .tunnelVision: // Efectos para la visión túnel
                            
            let minSide = min(inputCI.extent.width, inputCI.extent.height) // Encuentra el lado más corto de la imagen

            // Radio mínimo del túnel (aproximadamente 1 cm como porcentaje del lado más corto)
            let minTunnelRadiusPercentage: CGFloat = 0.05 // 5%
            let minTunnelRadius = minSide * minTunnelRadiusPercentage // Calcula el radio mínimo en píxeles

            // Radio máximo del túnel (toda la imagen)
            let maxTunnelRadius = minSide / 1.6  // Un poco menos que la mitad del lado más corto

            // Convertir el clampedFocus en un radio que podemos aplicar al túnel
            let tunnelRadius = minTunnelRadius + (maxTunnelRadius - minTunnelRadius) * (1-clampedFocus) // Radio ajustado
            
            // Calcular el feather en relación al radio del túnel (ajustar estos valores)
            let feather = tunnelRadius * (0.12 + 0.08 * (1.0 - clampedFocus)) // Ajusta el factor
            
            let outerRadius = tunnelRadius + feather // Radio externo del túnel

            // Desenfoque sobre la imagen original
            let blurFilter = CIFilter.gaussianBlur() // Crea un filtro de desenfoque
            blurFilter.inputImage = inputCI // Asigna la imagen original
            blurFilter.radius = Float(4 + (1.0 - clampedFocus) * 10.0) // Ajusta el radio de desenfoque
            let blurred = blurFilter.outputImage?.clampedToExtent().cropped(to: inputCI.extent) ?? inputCI // Aplica el desenfoque

            // Crea un gradiente radial para la máscara
            let radial = CIFilter.radialGradient() // Crea un filtro de gradiente radial
            radial.center = effectCenter // Establece el centro del gradiente
            radial.radius0 = Float(tunnelRadius) // Radio interno del túnel
            radial.radius1 = Float(outerRadius) // Radio externo del túnel
            radial.color0 = CIColor(red: 1, green: 1, blue: 1, alpha: 1) // Color blanco para el centro
            radial.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 1) // Color negro para el borde
            let mask = radial.outputImage?.cropped(to: inputCI.extent) ?? inputCI // Recorta la máscara a los límites de la imagen

            // Combinación de la imagen desenfocada con la máscara
            let multiply = CIFilter.multiplyCompositing() // Crea un filtro para multiplicar imágenes
            multiply.inputImage = mask // Máscara
            multiply.backgroundImage = blurred // Imagen desenfocada
            let darkenedPeripheral = multiply.outputImage?.cropped(to: inputCI.extent) ?? blurred // Capa oscurecida en los bordes

            // Combina la imagen original con la imagen oscurecida
            let composite = CIFilter.blendWithMask() // Crea un filtro de mezcla con máscara
            composite.inputImage = inputCI // Imagen original
            composite.backgroundImage = darkenedPeripheral // Imagen oscurecida
            composite.maskImage = mask // Máscara
            outputCI = composite.outputImage ?? inputCI // Establece la imagen de salida

        }
        
        // Crea un CGImage a partir de la salida de CIImage
        return context.createCGImage(outputCI, from: inputCI.extent) ?? image
    }
}


