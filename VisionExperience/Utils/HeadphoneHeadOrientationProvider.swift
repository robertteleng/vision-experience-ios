import Foundation
import CoreMotion
import Combine

final class HeadphoneHeadOrientationProvider: ObservableObject {
    private let manager = CMHeadphoneMotionManager()
    private let queue = OperationQueue()

    @Published private(set) var yaw: Float = 0
    @Published private(set) var pitch: Float = 0
    @Published private(set) var roll: Float = 0
    @Published private(set) var isActive: Bool = false

    private var yawOffset: Float = 0 // degrees

    func start() {
        guard manager.isDeviceMotionAvailable else { isActive = false; return }
        if manager.isDeviceMotionActive { isActive = true; return }
        manager.startDeviceMotionUpdates(to: queue) { [weak self] motion, _ in
            guard let self = self, let m = motion else { return }
            let r2d: Float = 180.0 / .pi
            var yawDeg = Float(m.attitude.yaw) * r2d
            let pitchDeg = Float(m.attitude.pitch) * r2d
            let rollDeg = Float(m.attitude.roll) * r2d
            // Apply recenter offset to yaw
            yawDeg -= self.yawOffset
            DispatchQueue.main.async {
                self.yaw = yawDeg
                self.pitch = pitchDeg
                self.roll = rollDeg
                self.isActive = true
            }
        }
    }

    func stop() {
        guard manager.isDeviceMotionActive else { isActive = false; return }
        manager.stopDeviceMotionUpdates()
        isActive = false
    }

    func recenter() {
        // Capture current yaw as the new forward
        if let m = manager.deviceMotion {
            let r2d: Float = 180.0 / .pi
            yawOffset = Float(m.attitude.yaw) * r2d
        }
    }
}
