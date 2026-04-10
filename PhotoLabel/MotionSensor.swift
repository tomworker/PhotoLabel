//
//  MotionSensor.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/09/15.
//

import SwiftUI
import CoreMotion

class MotionSensor: NSObject, ObservableObject {
    @Published var orientation: String = "V"
    var xAcc: Double = 0.0
    var yAcc: Double = 0.0
    var zAcc: Double = 0.0
    var xGrv: Double = 0.0
    var yGrv: Double = 0.0
    var zGrv: Double = 0.0
    let motionManager = CMMotionManager()
    
    override init() {
        super.init()
        start()
    }
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates(to: .init()) { [weak self] (motion, error) in
            guard let self = self else { return }
            if let safeMotion = motion {
                self.updateMotionData(deviceMotion: safeMotion)
            }
        }
    }
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    private func updateMotionData(deviceMotion: CMDeviceMotion) {
        xAcc = deviceMotion.userAcceleration.x
        yAcc = deviceMotion.userAcceleration.y
        zAcc = deviceMotion.userAcceleration.z
        xGrv = deviceMotion.gravity.x
        yGrv = deviceMotion.gravity.y
        zGrv = deviceMotion.gravity.z
        updateGravity(x: xGrv, y: yGrv)
    }
    private func updateGravity(x: Double, y: Double) {
        let newOrientation = (abs(x) > abs(y)) ? "H" : "V"
        if newOrientation != self.orientation {
            DispatchQueue.main.async {
                self.orientation = newOrientation
            }
        }
    }
}
