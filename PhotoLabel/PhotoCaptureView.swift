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
    @State var caLayer: CALayer
    let sheetId: Int
    @Binding var mainCategoryIds: [MainCategoryId]
    let mainCategoryIndex: Int
    let subCategoryIndex: Int
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    let fileUrl: URL
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    @State var photoOrientation = "H"
    @State var sliderVal = 0.5
    @State var isNoAnimation = false
    @State var isSelectFlashMode = false
    let deviceWidth = (AppDelegate.orientationLock == .allButUpsideDown && (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .portraitUpsideDown)) ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
    let deviceHeight = (AppDelegate.orientationLock == .allButUpsideDown && (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .portraitUpsideDown)) ? UIScreen.main.bounds.width : UIScreen.main.bounds.height

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
                        CameraView(caLayer: $caLayer, photoCapture: photoCapture, caLayer2: photoCapture.videoPreviewLayer)
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
                    .onChange(of: sensor.xGrv + sensor.xAcc) { newValue in
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
                            isNoAnimation = true
                            showPhotoCapture = false
                            if photoCapture.device!.position == .front {
                                photoCapture.flipCameraDevice()
                            }
                            photoCapture.reset(zoomReset: true)
                            AppDelegate.orientationLock = .allButUpsideDown
                            guard let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.filter({ $0.isKeyWindow }).first else { return }
                            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
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
                            Button {
                                photoCapture.setPhotoOrientation(photoOrientation: photoOrientation)
                                photoCapture.takePhoto()
                            } label: {
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                            .onChange(of:photoCapture.isPreparedImage) { value in
                                if photoCapture.isPreparedImage == true {
                                    if photoCapture.image != nil {
                                        switch photoOrientation {
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
                                        let workSpaceImageFileName = "@\(dateFormatter.string(from: Date())).jpg"
                                        let workSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(workSpaceImageFileName)
                                        let plistImageFileName = "\(dateFormatter.string(from: Date())).jpg"
                                        var plistJpgUrl = tempDirectoryUrl.appendingPathComponent(plistImageFileName)
                                        let duplicateSpaceImageFileName = plistImageFileName
                                        do {
                                            switch sheetId {
                                            case 1:
                                                try jpgImageData!.write(to: workSpaceJpgUrl, options: .atomic)
                                                workSpace.insert(WorkSpaceImageFile(imageFile: workSpaceImageFileName, subDirectory: ""), at: workSpace.count)
                                                ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            case 2:
                                                if mainCategoryIds[mainCategoryIndex].subFolderMode == 1 {
                                                    ZipManager.create(directoryUrl: tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)))
                                                    plistJpgUrl = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)).appendingPathComponent(plistImageFileName)
                                                }
                                                try jpgImageData!.write(to: plistJpgUrl, options: .atomic)
                                                duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: duplicateSpace.count)
                                                mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.insert(ImageFile(imageFile: plistImageFileName), at: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.count)
                                                mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages += 1
                                                ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            default:
                                                print("SheetId have failed to be found:\(sheetId)")
                                            }
                                        } catch {
                                            print("Writing Jpg file failed with error:\(error)")
                                        }
                                    }
                                    photoCapture.isPreparedImage = false
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
}
