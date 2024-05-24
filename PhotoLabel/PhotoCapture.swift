//
//  PhotoCapture.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/09/15.
//

import SwiftUI
import AVFoundation

class PhotoCapture: NSObject, ObservableObject {
    var image: UIImage?
    var isImage = false
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var dataOutput = AVCapturePhotoOutput()
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var photoOrientation = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight ? "H" : "V"
    var baseZoomFactor: CGFloat = 1.0
    var device: AVCaptureDevice?
    var actions = [UInt: (() -> Void)]()
    var tapPoint = CGPoint(x: 0.5, y: 0.5)
    @Published var tapPoint2 = CGPoint(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height / 2))
    var isAutoExposureAutoFocusLocked = false
    var isShowInterestArea = false
    var isShowInterestAreaWeak = false
    var isMoved = false
    var addingPosition = CGFloat(0.0)
    var initialValue = CGFloat(0.0)
    var endedValue = CGFloat(0.0)
    var userAccelarationX = Double(0.0)
    var userAccelarationY = Double(0.0)
    var userAccelarationZ = Double(0.0)
    var interestTimer: Timer?
    var flashMode = "auto"
    var isFlipCameraDevice = false
    var isProcedureRunning = false
    @Published var QRData: [String] = []
    @Published var QRFrame: [CGRect] = []
    @Published var isDetectQR: [Bool] = []

    override init() {
        super.init()
        setupCaptureSession(withPosition: .back)
        reset(zoomReset: true)
    }
    func setupCaptureSession(withPosition cameraPosition: AVCaptureDevice.Position) {
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
        if let cameraDevice = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: cameraPosition) {
            device = cameraDevice
        } else if let cameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: cameraPosition) {
            device = cameraDevice
        } else if let cameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: cameraPosition) {
            device = cameraDevice
        }
        captureSession.beginConfiguration()
        guard let deviceInput = try? AVCaptureDeviceInput(device: device!), captureSession.canAddInput(deviceInput) else { return }
        captureSession.addInput(deviceInput)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(captureMetadataOutput) {
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        }
        guard captureSession.canAddOutput(dataOutput) else { return }
        captureSession.addOutput(dataOutput)
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        captureSession.commitConfiguration()
        videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    func reset(zoomReset: Bool) {
        print(device!.deviceType)
        print(device!.virtualDeviceSwitchOverVideoZoomFactors)
        for value in device!.virtualDeviceSwitchOverVideoZoomFactors {
            print("zoom: ", value)
        }
        isShowInterestArea = true
        isShowInterestAreaWeak = false
        flashMode = "auto"
        if let oldValue = interestTimer?.isValid {
            if oldValue {
                interestTimer?.invalidate()
            }
        }
        if zoomReset == true {
            switch device!.deviceType {
            case .builtInTripleCamera:
                baseZoomFactor = 2.0
                break
            case .builtInDualWideCamera:
                baseZoomFactor = 2.0
                break
            case .builtInUltraWideCamera:
                baseZoomFactor = 2.0
                break
            case .builtInDualCamera:
                baseZoomFactor = 1.0
                break
            case .builtInWideAngleCamera:
                if device!.virtualDeviceSwitchOverVideoZoomFactors.count == 0 {
                    baseZoomFactor = 1.0
                } else {
                    baseZoomFactor = CGFloat(device!.virtualDeviceSwitchOverVideoZoomFactors[0].floatValue)
                }
                break
            default:
                if device!.virtualDeviceSwitchOverVideoZoomFactors.count == 0 {
                    baseZoomFactor = 1.0
                } else {
                    baseZoomFactor = CGFloat(device!.virtualDeviceSwitchOverVideoZoomFactors[0].floatValue)
                }
                break
            }
            do {
                try device?.lockForConfiguration()
                if device!.isAutoFocusRangeRestrictionSupported {
                    device?.autoFocusRangeRestriction = .none
                }
                device?.ramp(toVideoZoomFactor: baseZoomFactor, withRate: 32.0)
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        tapPoint = CGPoint(x: 0.5, y: 0.5)
        tapPoint2 = CGPoint(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height / 2))
        do {
            try device?.lockForConfiguration()
            if device!.isFocusPointOfInterestSupported {
                device?.focusPointOfInterest = tapPoint
            }
            if device!.isFocusModeSupported(.continuousAutoFocus) {
                device?.focusMode = .continuousAutoFocus
            }
            if device!.isExposurePointOfInterestSupported {
                device?.exposurePointOfInterest = tapPoint
            }
            if device!.isExposureModeSupported(.continuousAutoExposure) {
                device?.exposureMode = .continuousAutoExposure
            }
            device?.unlockForConfiguration()
            isAutoExposureAutoFocusLocked = false
        } catch {
            print(error)
        }
        interestTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
            self!.isShowInterestArea = false
        }
    }
    func flipCameraDevice() {
        captureSession.stopRunning()
        captureSession.beginConfiguration()
        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }
        captureSession.commitConfiguration()
        let newCameraPosition: AVCaptureDevice.Position = device?.position == .front ? .back : .front
        captureSession = AVCaptureSession()
        dataOutput = AVCapturePhotoOutput()
        isFlipCameraDevice = true
        setupCaptureSession(withPosition: newCameraPosition)
        reset(zoomReset: true)
    }
    func selectDevice(zoomFactor: CGFloat) {
        do {
            try device?.lockForConfiguration()
            device?.ramp(toVideoZoomFactor: zoomFactor, withRate: 32.0)
            device?.unlockForConfiguration()
        } catch {
            print("Failed to change zoom factor.")
        }
    }
    func setFlashMode(mode: String) {
        flashMode = mode
    }
    func setUserAccelaration(xAcc: Double, yAcc: Double, zAcc: Double) {
        if fabs(userAccelarationX - xAcc) > 0.05 || fabs(userAccelarationY - yAcc) > 0.05 || fabs(userAccelarationZ - zAcc) > 0.05 {
            isMoved = true
            if isShowInterestAreaWeak == true && isMoved == true && isAutoExposureAutoFocusLocked == false {
                reset(zoomReset: false)
            }
        }
        self.userAccelarationX = xAcc
        self.userAccelarationY = yAcc
        self.userAccelarationZ = zAcc
    }
    @objc func onPanGesture(_ sender: UIPanGestureRecognizer) {
        if isShowInterestArea == true {
            isShowInterestAreaWeak = false
            if let oldValue = interestTimer?.isValid {
                if oldValue {
                    interestTimer?.invalidate()
                }
            }
            if photoOrientation == "V" {
                var changedValue = -sender.location(in: sender.view).y
                if sender.state == .began {
                    initialValue = -sender.location(in: sender.view).y
                }
                if sender.state == .changed {
                    changedValue = -sender.location(in: sender.view).y
                    addingPosition = (changedValue - initialValue + endedValue) / 4
                    if addingPosition > 40 {
                        addingPosition = 40
                    } else if addingPosition < -40 {
                        addingPosition = -40
                    }
                }
                if sender.state == .ended {
                    endedValue = addingPosition * 4
                }
            }
            if photoOrientation == "H" {
                var changedValue = sender.location(in: sender.view).x
                if sender.state == .began {
                    initialValue = sender.location(in: sender.view).x
                }
                if sender.state == .changed {
                    changedValue = sender.location(in: sender.view).x
                    addingPosition = (changedValue - initialValue + endedValue) / 4
                    if addingPosition > 40 {
                        addingPosition = 40
                    } else if addingPosition < -40 {
                        addingPosition = -40
                    }
                }
                if sender.state == .ended {
                    endedValue = addingPosition * 4
                }
            }
            print("Dragged: ", addingPosition)
            do {
                try device?.lockForConfiguration()
                device?.setExposureTargetBias(Float(addingPosition * CGFloat(device!.maxExposureTargetBias) / 40))
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
            interestTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
                self!.isMoved = false
                self!.isShowInterestAreaWeak = true
            }
        }
    }
    @objc func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        isShowInterestAreaWeak = false
        if let oldValue = interestTimer?.isValid {
            if oldValue {
                interestTimer?.invalidate()
            }
        }
        if sender.state == .began {
            baseZoomFactor = (device?.videoZoomFactor)!
        }
        let tempZoomFactor: CGFloat = baseZoomFactor * sender.scale
        var newZoomFactor: CGFloat
        if tempZoomFactor < (device?.minAvailableVideoZoomFactor)! {
            newZoomFactor = (device?.minAvailableVideoZoomFactor)!
        } else if (device?.maxAvailableVideoZoomFactor)! < tempZoomFactor {
            newZoomFactor = (device?.maxAvailableVideoZoomFactor)!
        } else {
            newZoomFactor = tempZoomFactor
        }
        if newZoomFactor > device!.maxAvailableVideoZoomFactor {
            newZoomFactor = device!.maxAvailableVideoZoomFactor
        } else if newZoomFactor < device!.minAvailableVideoZoomFactor {
            newZoomFactor = device!.minAvailableVideoZoomFactor
        }
        do {
            try device?.lockForConfiguration()
            device?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 32.0)
            device?.unlockForConfiguration()
        } catch {
            print("Failed to change zoom factor.")
        }
        interestTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self!.isMoved = false
            self!.isShowInterestAreaWeak = true
        }
    }
    @objc func onTapGesture(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            isShowInterestArea = true
            isShowInterestAreaWeak = false
            isMoved = false
            if let oldValue = interestTimer?.isValid {
                if oldValue {
                    interestTimer?.invalidate()
                }
            }
            tapPoint2 = sender.location(in: sender.view)
            tapPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: tapPoint2)
            print("Tapped: ", tapPoint)
            print("offY: ", (UIScreen.main.bounds.height - (UIScreen.main.bounds.width / 0.75)) / 2)
            do {
                try device?.lockForConfiguration()
                if device!.isFocusPointOfInterestSupported {
                    device?.focusPointOfInterest = tapPoint
                }
                if device!.isFocusModeSupported(.autoFocus) {
                    device?.focusMode = .autoFocus
                }
                if device!.isExposurePointOfInterestSupported {
                    device?.exposurePointOfInterest = tapPoint
                }
                if device!.isExposureModeSupported(.autoExpose) {
                    device?.exposureMode = .autoExpose
                }
                addingPosition = 0.0
                initialValue = 0.0
                endedValue = 0.0
                device?.setExposureTargetBias(0)
                device?.unlockForConfiguration()
                isAutoExposureAutoFocusLocked = false
            } catch {
                print(error)
            }
            interestTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
                self!.isMoved = false
                self!.isShowInterestAreaWeak = true
            }
        }
    }
    @objc func onLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        isShowInterestArea = true
        isShowInterestAreaWeak = false
        if let oldValue = interestTimer?.isValid {
            if oldValue {
                interestTimer?.invalidate()
            }
        }
        if sender.state == .began {
            do {
                print("Long pressed: ")
                try device?.lockForConfiguration()
                if device!.isFocusModeSupported(.locked) {
                    device?.focusMode = .locked
                }
                if device!.isExposureModeSupported(.locked) {
                    device?.exposureMode = .locked
                }
                device?.unlockForConfiguration()
                if device?.focusMode == .locked || device?.exposureMode == .locked {
                    isAutoExposureAutoFocusLocked = true
                }
            } catch {
                print(error)
            }
        }
        interestTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self!.isMoved = false
            self!.isShowInterestAreaWeak = true
        }
    }
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        switch flashMode {
        case "auto":
            settings.flashMode = .auto
            break
        case "on":
            settings.flashMode = .on
            break
        case "off":
            settings.flashMode = .off
            break
        default:
            settings.flashMode = .auto
            break
        }
        dataOutput.capturePhoto(with: settings, delegate: self)
    }
    func setPhotoOrientation(photoOrientation: String) {
        self.photoOrientation = photoOrientation
    }
}
extension PhotoCapture: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let uiImage = UIImage(data: imageData) {
            image = uiImage
        }
    }
}
extension PhotoCapture: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            isDetectQR = []
            QRData = []
            QRFrame = []
            return
        }
        isDetectQR = metadataObjects.map{$0 == $0}
        QRData = (metadataObjects as! [AVMetadataMachineReadableCodeObject]).map{$0.stringValue!}
        QRFrame = (metadataObjects as! [AVMetadataMachineReadableCodeObject]).map{(videoPreviewLayer.transformedMetadataObject(for: $0) as! AVMetadataMachineReadableCodeObject).bounds}
    }
}
