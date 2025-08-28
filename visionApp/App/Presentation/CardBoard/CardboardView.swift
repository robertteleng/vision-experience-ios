import SwiftUI
import AVFoundation

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
                        panel: .left,
                        illness: illness,
                        centralFocus: centralFocus
                    )
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
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
                        panel: .right,
                        illness: illness,
                        centralFocus: centralFocus
                    )
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
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
