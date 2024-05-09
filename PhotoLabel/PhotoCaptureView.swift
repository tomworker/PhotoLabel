//
//  PhotoCaptureView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/09/15.
//

import SwiftUI

struct PhotoCaptureView: View {
    @StateObject var photoCapture: PhotoCapture
    @StateObject var sensor = MotionSensor()
    @Binding var showPhotoCapture: Bool
    let caLayer: CALayer
    @Binding var mainCategoryIds: [MainCategoryId]
    let mainCategoryIndex: Int
    let subCategoryIndex: Int
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    let fileUrl: URL
    @Binding var downSizeImages: [[[UIImage]]]
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    @State var photoOrientation = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight ? "H" : "V"
    @State var photoOrientationAtShot = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight ? "H" : "V"
    @State var sliderVal = 0.5
    @State var isNoAnimation = false
    @State var isSelectFlashMode = false
    @State var capturedQRData = ""
    let deviceWidth = (AppDelegate.orientationLock == .allButUpsideDown && (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .portraitUpsideDown)) ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
    let deviceHeight = (AppDelegate.orientationLock == .allButUpsideDown && (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .portraitUpsideDown)) ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if AppDelegate.orientationLock == .allButUpsideDown && isNoAnimation == false {
            Spacer()
                .background(.clear)
                .onAppear {
                    AppDelegate.orientationLock = .portrait
                    guard let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.filter({ $0.isKeyWindow }).first else { return }
                    window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
        } else if AppDelegate.orientationLock == .portrait && isNoAnimation == false {
            ZStack {
                ZStack {
                    VStack {
                        CameraView(caLayer: caLayer, photoCapture: photoCapture)
                            .onPinchGesture()
                            .onPanGesture()
                            .onLongPressGesture()
                            .onTapGesture()
                    }
                    .onAppear {
                        print(deviceWidth, " : ", deviceHeight)
                        guard let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.filter({ $0.isKeyWindow }).first else { return }
                        window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                    }
                    .onReceive(timer) { _ in
                        photoCapture.setUserAccelaration(xAcc: Double(sensor.xAcc)!, yAcc: Double(sensor.yAcc)!, zAcc: Double(sensor.zAcc)!)
                        if fabs(Double(sensor.xGrv)!) < 0.2 && fabs(Double(sensor.yGrv)!) < 0.2 {
                            //none
                        } else {
                            if fabs(Double(sensor.xGrv)!) / fabs(Double(sensor.yGrv)!) > 1 {
                                photoOrientation = "H"
                            } else {
                                photoOrientation = "V"
                            }
                            photoCapture.setPhotoOrientation(photoOrientation: photoOrientation)
                        }
                    }
                    if photoCapture.isShowInterestArea == false && photoCapture.isAutoExposureAutoFocusLocked == false {
                        //none
                    } else {
                        Rectangle()
                            .frame(width: 80, height: 80)
                            .border(photoCapture.isShowInterestAreaWeak == true ? .yellow.opacity(0.5) : .yellow, width: 1)
                            .foregroundColor(.clear)
                            .position(photoCapture.tapPoint2)
                        Rectangle()
                            .frame(width: 5, height: 1)
                            .foregroundColor(photoCapture.isShowInterestAreaWeak == true ? .yellow.opacity(0.5) : .yellow)
                            .position(photoCapture.tapPoint2)
                            .offset(x: -37.5)
                        Rectangle()
                            .frame(width: 5, height: 1)
                            .foregroundColor(photoCapture.isShowInterestAreaWeak == true ? .yellow.opacity(0.5) : .yellow)
                            .position(photoCapture.tapPoint2)
                            .offset(x: 37.5)
                        Rectangle()
                            .frame(width: 1, height: 5)
                            .foregroundColor(photoCapture.isShowInterestAreaWeak == true ? .yellow.opacity(0.5) : .yellow)
                            .position(photoCapture.tapPoint2)
                            .offset(y: -37.5)
                        Rectangle()
                            .frame(width: 1, height: 5)
                            .foregroundColor(photoCapture.isShowInterestAreaWeak == true ? .yellow.opacity(0.5) : .yellow)
                            .position(photoCapture.tapPoint2)
                            .offset(y: 37.5)
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 20, weight: .light))
                            .frame(width: 30)
                            .foregroundColor(photoCapture.isShowInterestAreaWeak == true ? .yellow.opacity(0.5) : .yellow)
                            .position(x: photoOrientation == "V" ? photoCapture.tapPoint2.x + 70 < UIScreen.main.bounds.width ? photoCapture.tapPoint2.x + 56 : photoCapture.tapPoint2.x - 56 : photoCapture.tapPoint2.x + photoCapture.addingPosition, y: photoOrientation == "V" ? photoCapture.tapPoint2.y - photoCapture.addingPosition : photoCapture.tapPoint2.y + 70 < 60 + (UIScreen.main.bounds.width / 0.75) ? photoCapture.tapPoint2.y + 56 : photoCapture.tapPoint2.y - 56)
                        Rectangle()
                            .frame(width: photoOrientation == "V" ? 1 : 80, height: photoOrientation == "V" ? 80 : 1)
                            .foregroundColor(photoCapture.isShowInterestAreaWeak == true ? .yellow.opacity(0.5) : .yellow)
                            .position(x: photoOrientation == "V" ? photoCapture.tapPoint2.x + 70 < UIScreen.main.bounds.width ? photoCapture.tapPoint2.x + 56 : photoCapture.tapPoint2.x - 56 : photoCapture.tapPoint2.x, y: photoOrientation == "V" ? photoCapture.tapPoint2.y : photoCapture.tapPoint2.y + 70 < 60 + (UIScreen.main.bounds.width / 0.75) ? photoCapture.tapPoint2.y + 56 : photoCapture.tapPoint2.y - 56)
                    }
                    if photoCapture.isAutoExposureAutoFocusLocked == true {
                        if photoOrientation == "H" {
                            VStack {
                                Text(photoCapture.device!.isExposureModeSupported(.locked) ? photoCapture.device!.isFocusModeSupported(.locked) ? "AE/AF locked" : "AE locked" : photoCapture.device!.isFocusModeSupported(.locked) ? "AF locked" : "").font(.system(.caption))
                                    .frame(width: 80, height: 15)
                                    .background(.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(1)
                                    .rotationEffect(Angle(degrees: 90))
                                    .position(x: UIScreen.main.bounds.width - 7.5, y: UIScreen.main.bounds.height / 2)
                            }
                        }
                        if photoOrientation == "V" {
                            VStack {
                                Text(photoCapture.device!.isExposureModeSupported(.locked) ? photoCapture.device!.isFocusModeSupported(.locked) ? "AE/AF locked" : "AE locked" : photoCapture.device!.isFocusModeSupported(.locked) ? "AF locked" : "").font(.system(.caption))
                                    .frame(width: 80, height: 15)
                                    .background(.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(1)
                                    .offset(y: ((UIScreen.main.bounds.height - (UIScreen.main.bounds.width / 0.75)) / 2))
                                Spacer()
                            }
                        }
                    }
                    Button {
                        capturedQRData = ""
                    } label: {
                        VStack {
                            Text(capturedQRData == "" ? "" : "Captured into Image info! (or tap to clear)")
                                .foregroundColor(.white)
                                .background(.blue.opacity(0.3))
                            Text(capturedQRData)
                                .foregroundColor(.white)
                                .background(.blue.opacity(0.3))
                        }
                    }
                    ForEach(photoCapture.isDetectQR.indices, id: \.self) { index in
                        ZStack {
                            Button {
                                if capturedQRData == "" {
                                    capturedQRData = photoCapture.QRData[index] + ","
                                } else {
                                    if capturedQRData == photoCapture.QRData[index] + "," {
                                        capturedQRData = ""
                                    } else {
                                        capturedQRData = photoCapture.QRData[index] + ","
                                    }
                                }
                            } label: {
                                Text("")
                                    .frame(width: photoCapture.QRFrame[index].width, height: photoCapture.QRFrame[index].height)
                                    .border(capturedQRData == photoCapture.QRData[index] ? .blue : .green, width: 1)
                                    .foregroundColor(.black)
                                    .background(capturedQRData == photoCapture.QRData[index] ? .blue.opacity(0.1) : .green.opacity(0.1))
                            }
                            Text(photoCapture.QRData[index])
                                .font(.system(.caption2))
                                .foregroundColor(.black)
                                .background(capturedQRData == photoCapture.QRData[index] ? .blue.opacity(0.3) : .green.opacity(0.3))
                        }
                        .position(CGPoint(x: photoCapture.QRFrame[index].minX + photoCapture.QRFrame[index].width / 2, y: photoCapture.QRFrame[index].minY + photoCapture.QRFrame[index].height / 2))
                    }
                }
                VStack {
                    ZStack {
                        HStack {
                            Button {
                                isSelectFlashMode.toggle()
                            } label: {
                                Image(systemName: photoCapture.flashMode == "off" ? "bolt.slash.fill" : "bolt.fill")
                                    .font(.system(size: 20))
                                    .frame(width: 30)
                                    .foregroundColor(photoCapture.flashMode == "on" ? .yellow : .white)
                                    .padding()
                            }
                            if isSelectFlashMode == true {
                                Button {
                                    photoCapture.setFlashMode(mode: "auto")
                                    isSelectFlashMode = false
                                } label: {
                                    Text("Auto")
                                        .foregroundColor(photoCapture.flashMode == "auto" ? .yellow : .white)
                                        .padding()
                                }
                                Button {
                                    photoCapture.setFlashMode(mode: "on")
                                    isSelectFlashMode = false
                                } label: {
                                    Text("On")
                                        .foregroundColor(photoCapture.flashMode == "on" ? .yellow : .white)
                                        .padding()
                                }
                                Button {
                                    photoCapture.setFlashMode(mode: "off")
                                    isSelectFlashMode = false
                                } label: {
                                    Text("Off")
                                        .foregroundColor(photoCapture.flashMode == "off" ? .yellow : .white)
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                    }
                    .frame(height: ((deviceHeight - (deviceWidth / 0.75)) / 2))
                    .background(.black)
                    Spacer()
                }
                HStack {
                    Spacer()
                    ForEach(photoCapture.device!.virtualDeviceSwitchOverVideoZoomFactors, id: \.self) { value in
                        if value == photoCapture.device!.virtualDeviceSwitchOverVideoZoomFactors[0] {
                            Button {
                                photoCapture.selectDevice(zoomFactor: CGFloat(1))
                            } label: {
                                ZStack {
                                    Circle()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.black.opacity(0.3))
                                    Text("0.5x")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        Button {
                            photoCapture.selectDevice(zoomFactor: CGFloat(value.floatValue))
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.black.opacity(0.3))
                                Text(String(format: Int((value.floatValue / 2) * 10) % 10 == 0 ? "%.0f" : "%.1f", value.floatValue / 2) + "x")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    Spacer()
                }
                .position(x: deviceWidth / 2, y: ((deviceHeight + (deviceWidth / 0.75)) / 2) - 25)
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            if photoCapture.isProcedureRunning == false {
                                cancelView()
                            } else {
                                if photoCapture.image == nil {
                                    //none
                                } else {
                                    saveImage()
                                    cancelView()
                                }
                            }
                        } label: {
                            Text("Cancel")
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                        Button {
                            photoCapture.flipCameraDevice()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.white)
                                .padding(.trailing)
                        }
                        ZStack {
                            Image(systemName: "rectangle.portrait")
                                .foregroundColor(.white)
                                .scaleEffect(1.1)
                            Image(systemName: photoOrientation == "H" ? "person.fill.turn.right" : "person.fill")
                                .foregroundColor(.white)
                                .offset(y: photoOrientation == "H" ? 0 : 1.5)
                        }
                        .padding(.trailing)
                    }
                    .frame(height: ((deviceHeight - (deviceWidth / 0.75)) / 2))
                    .background(.black)
                }
                VStack {
                    Spacer()
                    ZStack {
                        VStack {
                            Circle()
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white)
                        }
                        VStack {
                            Circle()
                                .frame(width: 54, height: 54)
                                .foregroundColor(.black)
                        }
                        VStack {
                            if photoCapture.isProcedureRunning == true {
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                                    .onReceive(timer) { _ in
                                        if photoCapture.isProcedureRunning == true && photoCapture.image != nil {
                                            saveImage()
                                        }
                                    }
                            } else {
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        photoCapture.setPhotoOrientation(photoOrientation: photoOrientation)
                                        if photoCapture.isProcedureRunning == false {
                                            if photoCapture.image == nil {
                                                photoCapture.takePhoto()
                                                photoOrientationAtShot = photoOrientation
                                                photoCapture.isProcedureRunning = true
                                            } else {
                                                print("isProcedureRunning false & image not nil")
                                            }
                                        } else {
                                            if photoCapture.image == nil {
                                                //none
                                            } else {
                                                saveImage()
                                                photoCapture.takePhoto()
                                                photoOrientationAtShot = photoOrientation
                                                photoCapture.isProcedureRunning = true
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .frame(width: 64, height: ((deviceHeight - (deviceWidth / 0.75)) / 2))
                }
            }
            .ignoresSafeArea(.all)
            .background(.black)
        }
    }
    private func saveImage() {
        autoreleasepool {
            if photoCapture.image != nil {
                switch photoOrientationAtShot {
                case "H":
                    let cgImage = photoCapture.image?.cgImage
                    let rotatedImage = UIImage(cgImage: cgImage!, scale: photoCapture.image!.scale, orientation: UIImage.Orientation.up)
                    photoCapture.image? = rotatedImage
                    break
                case "V":
                    let cgImage = photoCapture.image?.cgImage
                    let rotatedImage = UIImage(cgImage: cgImage!, scale: photoCapture.image!.scale, orientation: UIImage.Orientation.right)
                    photoCapture.image? = rotatedImage
                    break
                default:
                    break
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmssS"
                let jpgImageData = photoCapture.image?.jpegData(compressionQuality: 0.5)
                let plistImageFileName = "\(dateFormatter.string(from: Date())).jpg"
                var plistJpgUrl = tempDirectoryUrl.appendingPathComponent(plistImageFileName)
                let duplicateSpaceImageFileName = plistImageFileName
                do {
                    if mainCategoryIds[mainCategoryIndex].subFolderMode == 1 {
                        ZipManager.create(directoryUrl: tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)))
                        plistJpgUrl = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)).appendingPathComponent(plistImageFileName)
                    }
                    try jpgImageData!.write(to: plistJpgUrl, options: .atomic)
                    duplicateSpace.insert(DuplicateImageFile(imageFile: duplicateSpaceImageFileName, subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: duplicateSpace.count)
                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.insert(ImageFile(imageFile: plistImageFileName, imageInfo: capturedQRData), at: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.count)
                    downSizeImages[mainCategoryIndex][subCategoryIndex].append(UIImage(contentsOfFile: tempDirectoryUrl.path + "/" + plistImageFileName)!.resize(targetSize: CGSize(width: 200, height: 200)))
                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages += 1
                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                } catch {
                    print("Writing Jpg file failed with error:\(error)")
                }
            }
            photoCapture.isProcedureRunning = false
            photoCapture.image = nil
        }
    }
    private func cancelView() {
        isNoAnimation = true
        showPhotoCapture = false
        photoCapture.image = nil
        if photoCapture.device!.position == .front {
            photoCapture.flipCameraDevice()
        }
        photoCapture.reset(zoomReset: true)
        AppDelegate.orientationLock = .allButUpsideDown
        guard let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.filter({ $0.isKeyWindow }).first else { return }
        window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        DispatchQueue.global(qos: .background).async {
            ZipManager.saveZip(fileUrl: fileUrl)
        }
    }
}
