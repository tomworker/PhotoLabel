//
//  MotionSensor.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/09/15.
//

import SwiftUI
import CoreMotion

class MotionSensor: NSObject, ObservableObject {
    @Published var isStarted = false
    @Published var xAcc = "0.0"
    @Published var yAcc = "0.0"
    @Published var zAcc = "0.0"
    @Published var xGrv = "0.0"
    @Published var yGrv = "0.0"
    @Published var zGrv = "0.0"
    let motionManager = CMMotionManager()
    
    override init() {
        super.init()
        start()
    }
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion: CMDeviceMotion?, error: Error?) in
                self.updateMotionData(deviceMotion: motion!)
            })
        }
        isStarted = true
    }
    func stop() {
        isStarted = false
        motionManager.stopDeviceMotionUpdates()
    }
    private func updateMotionData(deviceMotion: CMDeviceMotion) {
        xAcc = String(deviceMotion.userAcceleration.x)
        yAcc = String(deviceMotion.userAcceleration.y)
        zAcc = String(deviceMotion.userAcceleration.z)
        xGrv = String(deviceMotion.gravity.x)
        yGrv = String(deviceMotion.gravity.y)
        zGrv = String(deviceMotion.gravity.z)
    }
}
