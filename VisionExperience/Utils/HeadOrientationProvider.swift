import Foundation
import CoreMotion
import Combine

final class HeadOrientationProvider: ObservableObject {
    private let motion = CMMotionManager()
    private let queue = OperationQueue()
    @Published private(set) var yaw: Float = 0
    @Published private(set) var pitch: Float = 0
    @Published private(set) var roll: Float = 0

    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
        guard motion.isDeviceMotionAvailable else { return }
        // Prefer Z vertical for stable horizon; corrected if available
        let ref: CMAttitudeReferenceFrame = CMMotionManager.availableAttitudeReferenceFrames().contains(.xArbitraryCorrectedZVertical) ? .xArbitraryCorrectedZVertical : .xArbitraryZVertical
        motion.startDeviceMotionUpdates(using: ref, to: queue) { [weak self] dm, _ in
            guard let self = self, let dm = dm else { return }
            // Convert radians to degrees; AVAudio expects degrees
            let r2d: Float = 180.0 / .pi
            let yawDeg = Float(dm.attitude.yaw) * r2d
            let pitchDeg = Float(dm.attitude.pitch) * r2d
            let rollDeg = Float(dm.attitude.roll) * r2d
            DispatchQueue.main.async {
                self.yaw = yawDeg
                self.pitch = pitchDeg
                self.roll = rollDeg
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        motion.stopDeviceMotionUpdates()
        isRunning = false
    }

    deinit { stop() }
}