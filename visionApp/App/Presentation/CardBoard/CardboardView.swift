import SwiftUI
import AVFoundation
//import App.Presentation.Components.Panel // Import shared Panel enum

struct CardboardView: View {
    @ObservedObject var cameraService: CameraService
    let illness: Illness?
    let centralFocus: Double
    @State var deviceOrientation: UIDeviceOrientation

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ZStack {
                    CameraImageView(
                        image: cameraService.currentFrame,
                        panel: .left, // Use shared Panel enum
                        illness: illness,
                        centralFocus: centralFocus
                )
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                    .ignoresSafeArea()
                    ColorOverlay(illness: illness, centralFocus: centralFocus, panel: .left)
                        .ignoresSafeArea()
                    if cameraService.currentFrame == nil {
                        Text("No frame LEFT")
                            .foregroundColor(.white)
                            .background(Color.red)
                    }
                }
                ZStack {
                    CameraImageView(
                        image: cameraService.currentFrame,
                        panel: .right, // Use shared Panel enum
                        illness: illness,
                        centralFocus: centralFocus
                    )
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                    .ignoresSafeArea()
                    ColorOverlay(illness: illness, centralFocus: centralFocus, panel: .right)
                        .ignoresSafeArea()
                    if cameraService.currentFrame == nil {
                        Text("No frame RIGHT")
                            .foregroundColor(.white)
                            .background(Color.blue)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// Cataracts preview
#Preview {
    CardboardView(
        cameraService: CameraViewModel().cameraService,
        illness: Illness(name: "Cataracts", description: "Simula visión con cataratas.", filterType: .cataracts),
        centralFocus: 20,
        deviceOrientation: .portrait
    )
}
