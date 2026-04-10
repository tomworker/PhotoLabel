//
//  PhotoCaptureView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/09/15.
//

import SwiftUI
import AVFoundation

struct PhotoCaptureView: View {
    @StateObject var photoCapture = PhotoCapture()
    @StateObject var sensor = MotionSensor()
    @Binding var showPhotoCapture: Bool
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
    @EnvironmentObject var alertCenter: AlertCenter
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    private var camera: AVCaptureDevice? {
        photoCapture.device
    }

    var body: some View {
        if isNoAnimation == false {
            ZStack {
                ZStack {
                    VStack {
                        CameraView(photoCapture: photoCapture)
                    }
                    .onAppear {
                        print(deviceWidth, " : ", deviceHeight)
                        if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.filter({ $0.isKeyWindow }).first {
                            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                        }
                    }
                    .onReceive(sensor.$orientation) { newOrientation in
                        photoOrientation = newOrientation
                        photoCapture.setPhotoOrientation(photoOrientation: newOrientation)
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
                    if photoCapture.isShowInterestArea || photoCapture.isAutoExposureAutoFocusLocked {
                        FocusBracket(at: photoCapture.tapPoint2, isWeak: photoCapture.isShowInterestAreaWeak)
                        ExposureIndicator(at: photoCapture.tapPoint2, isWeak: photoCapture.isShowInterestAreaWeak, orientation: photoOrientation)
                    }
                    if photoCapture.isAutoExposureAutoFocusLocked {
                        let statusText = photoCapture.lockStatusText
                        if photoOrientation == "H" {
                            VStack {
                                Text(statusText)
                                    .font(.system(.caption))
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
                                Text(statusText)
                                    .font(.system(.caption))
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
                    ForEach(camera?.virtualDeviceSwitchOverVideoZoomFactors ?? [], id: \.self) { value in
                        if value == camera?.virtualDeviceSwitchOverVideoZoomFactors[0] {
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
                                if photoCapture.image == nil {
                                    cancelView(jpgFileName: "")
                                } else {
                                    let plistImageFileName = saveImage()
                                    cancelView(jpgFileName: plistImageFileName)
                                }
                            } else {
                                if photoCapture.image == nil {
                                    cancelView(jpgFileName: "")
                                } else {
                                    let plistImageFileName = saveImage()
                                    cancelView(jpgFileName: plistImageFileName)
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
                            } else {
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        guard !photoCapture.isProcedureRunning else { return }
                                        photoCapture.setPhotoOrientation(photoOrientation: photoOrientation)
                                        photoOrientationAtShot = photoOrientation
                                        photoCapture.isProcedureRunning = true
                                        photoCapture.takePhoto { capturedImage in
                                            let result = saveImage()
                                            print("saving image result: \(result)")
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
}
private extension PhotoCaptureView {
    @ViewBuilder
    func FocusBracket(at point: CGPoint, isWeak: Bool) -> some View {
        let color = isWeak ? Color.yellow.opacity(0.5) : Color.yellow
        ZStack {
            Rectangle().stroke(color, lineWidth: 1).frame(width: 80, height: 80)
            Rectangle().fill(color).frame(width: 5, height: 1).offset(x: -37.5)
            Rectangle().fill(color).frame(width: 5, height: 1).offset(x: 37.5)
            Rectangle().fill(color).frame(width: 1, height: 5).offset(y: -37.5)
            Rectangle().fill(color).frame(width: 1, height: 5).offset(y: 37.5)
        }
        .position(point)
    }
    @ViewBuilder
    func ExposureIndicator(at point: CGPoint, isWeak: Bool, orientation: String) -> some View {
        let color = isWeak ? Color.yellow.opacity(0.5) : Color.yellow
        let isV = (orientation == "V")
        let screenWidth = UIScreen.main.bounds.width
        let limitY = 60 + (screenWidth / 0.75)
        let sunX: CGFloat = isV ? (point.x + 70 < screenWidth ? point.x + 56 : point.x - 56) : (point.x + photoCapture.addingPosition)
        let rectX: CGFloat = isV ? (point.x + 70 < screenWidth ? point.x + 56 : point.x - 56) : point.x
        let sunY: CGFloat = isV ? (point.y - photoCapture.addingPosition) : (point.y + 70 < limitY ? point.y + 56 : point.y - 56)
        let rectY: CGFloat = isV ? point.y : (point.y + 70 < limitY ? point.y + 56 : point.y - 56)
        Group {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(color)
                .frame(width: 30)
                .position(x: sunX, y: sunY)
            Rectangle()
                .fill(color)
                .frame(width: orientation == "V" ? 1 : 80, height: orientation == "V" ? 80 : 1)
                .position(x: rectX, y: rectY)
        }
    }
    func saveImage() -> String {
        return autoreleasepool {
            var plistImageFileName = ""
            guard let originalImage = photoCapture.image else {
                photoCapture.isProcedureRunning = false
                return ""
            }
            var processedImage = originalImage
            if let cgImage = originalImage.cgImage {
                let orientation: UIImage.Orientation = (photoOrientationAtShot == "V") ? .right : (camera?.position == .front) ? .down : .up
                processedImage = UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: orientation)
            }
            guard let jpgImageData = processedImage.jpegData(compressionQuality: 0.5) else { return "" }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmssS"
            plistImageFileName = "\(dateFormatter.string(from: Date())).jpg"
            var plistJpgUrl = tempDirectoryUrl.appendingPathComponent(plistImageFileName)
            let duplicateSpaceImageFileName = plistImageFileName
            let mainCat = mainCategoryIds[mainCategoryIndex]
            let subCat = mainCat.items[subCategoryIndex]
            do {
                if mainCat.subFolderMode == 1 {
                    let mainName = ZipManager.replaceString(targetString: mainCat.mainCategory)
                    let subName = ZipManager.replaceString(targetString: subCat.subCategory)
                    let folderUrl = tempDirectoryUrl.appendingPathComponent(mainName).appendingPathComponent(subName)
                    ZipManager.create(directoryUrl: folderUrl)
                    plistJpgUrl = folderUrl.appendingPathComponent(plistImageFileName)
                }
                try jpgImageData.write(to: plistJpgUrl, options: .atomic)
                duplicateSpace.insert(DuplicateImageFile(imageFile: duplicateSpaceImageFileName, subFolderMode: mainCat.subFolderMode, mainCategoryName: mainCat.mainCategory, subCategoryName: subCat.subCategory), at: duplicateSpace.count)
                mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.insert(ImageFile(imageFile: plistImageFileName, imageInfo: capturedQRData), at: subCat.images.count)
                let thumb = processedImage.resize(targetSize: CGSize(width: 200, height: 200))
                downSizeImages[mainCategoryIndex][subCategoryIndex].append(thumb)
                mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages += 1
                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                photoCapture.image = nil
                photoCapture.isProcedureRunning = false
            } catch {
                print("Writing Jpg file failed with error:\(error)")
                photoCapture.isProcedureRunning = false
            }
            return plistImageFileName
        }
    }
    func cancelView(jpgFileName: String) {
        isNoAnimation = true
        showPhotoCapture = false
        photoCapture.image = nil
        if camera?.position == .front {
            photoCapture.flipCameraDevice()
        }
        photoCapture.reset(zoomReset: true)
        let plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
        let targetZipUrl = fileUrl.deletingLastPathComponent().appendingPathComponent(plistNoExtensionName + ".zip")
        let targetPlistUrl = fileUrl
        DispatchQueue.global(qos: .background).async {
            do {
                try ZipManager.saveZip(fileUrl: targetPlistUrl)
            } catch {
                DispatchQueue.main.async {
                    alertCenter.show(title: "Zip update failed?", body: "一度カメラビューを開いて、撮影せずにCancelで閉じてみてください。\nZipファイルが更新されます。")
                }
            }
            if jpgFileName != "" {
                let expectedEntry = "\(plistNoExtensionName)/\(jpgFileName)"
                if !ZipManager.contains(expectedEntry, in: targetZipUrl) {
                    DispatchQueue.main.async {
                        alertCenter.show(title: "Zip missing latest photo?(\(jpgFileName))", body: "一度カメラビューを開いて、撮影せずにCancelで閉じてみてください。\nZipファイルが更新されます。")
                    }
                }
            }
        }
        if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.filter({ $0.isKeyWindow }).first {
            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
}
