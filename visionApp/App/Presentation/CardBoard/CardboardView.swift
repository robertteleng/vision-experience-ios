import SwiftUI
import AVFoundation
//import App.Presentation.Components.Panel // Import shared Panel enum

struct CardboardView: View {
    @ObservedObject var cameraService: CameraService
    let illness: Illness?
    let centralFocus: Double
    let filterEnabled: Bool
    let illnessSettings: IllnessSettings?
    @State var deviceOrientation: UIDeviceOrientation
    let vrSettings: VRSettings
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) { // Cambiar spacing a 0
                // Panel izquierdo
                ZStack {
                    CameraImageView(
                        image: cameraService.currentFrame,
                        panel: .left,
                        illness: illness,
                        centralFocus: centralFocus,
                        filterEnabled: filterEnabled,
                        illnessSettings: illnessSettings,
                        vrSettings: vrSettings
                    )
                    
                    if cameraService.currentFrame == nil {
                        Text("No frame LEFT")
                            .foregroundColor(.white)
                            .background(Color.red)
                    }
                }
                .frame(width: geometry.size.width / 2, height: geometry.size.height)
                
                // Panel derecho
                ZStack {
                    CameraImageView(
                        image: cameraService.currentFrame,
                        panel: .right,
                        illness: illness,
                        centralFocus: centralFocus,
                        filterEnabled: filterEnabled,
                        illnessSettings: illnessSettings,
                        vrSettings: vrSettings
                    )
                    
                    if cameraService.currentFrame == nil {
                        Text("No frame RIGHT")
                            .foregroundColor(.white)
                            .background(Color.blue)
                    }
                }
                .frame(width: geometry.size.width / 2, height: geometry.size.height)
            }
        }
        .ignoresSafeArea(.all) // Ignorar TODAS las safe areas
        .statusBar(hidden: true) // Ocultar la barra de estado si es necesario
    }
}


//// Cataracts preview
//#Preview {
//    CardboardView(
//        cameraService: CameraViewModel().cameraService,
//        illness: Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts),
//        centralFocus: 0.5,
//        filterEnabled: true,
//        illnessSettings: .cataracts(.defaults),
//        deviceOrientation: .portrait,
//        vrSettings: .defaults
//    )
//}

