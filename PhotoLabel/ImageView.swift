//
//  ImageView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI
import Vision
import VisionKit

struct ImageView: View {
    @Binding var fileUrl: URL
    @Binding var showImageView: Bool
    @Binding var showImageView3: Bool
    let imageFile: String
    let mainCategoryIndex: Int
    @Binding var subCategoryIndex: Int
    @Binding var targetImageFileIndex: Int
    @Binding var downSizeImages: [[[UIImage]]]
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var isDetectQRMode: Bool
    @Binding var isShowMenuIcon: Bool
    @Binding var isDetectTextMode: Bool
    @State var lastValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State var location = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State var endLocation = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State var leftEdge: CGFloat = 0
    @State var rightEdge: CGFloat = UIScreen.main.bounds.width
    @State var topEdge: CGFloat = 0
    @State var bottomEdge: CGFloat = UIScreen.main.bounds.height
    @State var aspectRatio: CGFloat = 4 / 3
    @State var isEditImageInfo = false
    @State var recognizedTexts: [String] = []
    @StateObject var qrCapture = QRCapture()
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    @State var croppedUiimage: UIImage? = nil
    //@GestureState var magnifyBy = 1.0
    //@State var magnifyBy2 = 1.0
    //@State var deltaM = 0.0

    var body: some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                autoreleasepool {
                    self.location.x = value.location.x - (value.startLocation.x - self.endLocation.x)
                    self.location.y = value.location.y - (value.startLocation.y - self.endLocation.y)
                }
            }
            .onEnded { value in
                autoreleasepool {
                    leftEdge = self.location.x - UIScreen.main.bounds.width * self.scale / 2
                    rightEdge = self.location.x + UIScreen.main.bounds.width * self.scale / 2
                    topEdge = self.location.y - UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                    bottomEdge = self.location.y + UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                    if leftEdge > 0 {
                        self.location.x = UIScreen.main.bounds.width * self.scale / 2
                    }
                    if rightEdge < UIScreen.main.bounds.width {
                        self.location.x = UIScreen.main.bounds.width - UIScreen.main.bounds.width * self.scale / 2
                    }
                    if topEdge > (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2 {
                        self.location.y = (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2 + UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                    }
                    if bottomEdge < (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2 {
                        self.location.y = (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2 - UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                    }
                    self.endLocation.x = self.location.x
                    self.endLocation.y = self.location.y
                    if let uiimage = UIImage(contentsOfFile: imageFile) {
                        updateCroppedUiimage(uiimage: uiimage)
                    }
                }
            }
        /*
        let magnifyGesture = MagnifyGesture()
            .updating($magnifyBy) { value, gestureState, transaction in
                gestureState = value.magnification
                if magnifyBy == 1.0 {
                    deltaM = magnifyBy2
                } else {
                    scale = value.magnification * deltaM
                }
            }
            .onEnded { value in
                if value.magnification > 1.0 {
                    scale = value.magnification * deltaM
                } else {
                    scale = 1.0
                    location = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                }
            }
         */
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in
                autoreleasepool {
                    let delta = value / self.lastValue
                    self.scale = self.scale * delta
                    self.lastValue = value
                    self.location.x = (UIScreen.main.bounds.width / 2) + (self.location.x - (UIScreen.main.bounds.width / 2)) * delta
                    self.location.y = (UIScreen.main.bounds.height / 2) + (self.location.y - (UIScreen.main.bounds.height / 2)) * delta
                }
            }
            .onEnded { value in
                autoreleasepool {
                    if self.scale < 1.0 {
                        self.scale = 1.0
                        location = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                        endLocation = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                        self.lastValue = 1.0
                    } else {
                        leftEdge = self.location.x - UIScreen.main.bounds.width * self.scale / 2
                        rightEdge = self.location.x + UIScreen.main.bounds.width * self.scale / 2
                        topEdge = self.location.y - UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                        bottomEdge = self.location.y + UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                        if leftEdge <= 0 && rightEdge >= UIScreen.main.bounds.width {
                            //none
                        } else if leftEdge > 0 {
                            self.location.x = UIScreen.main.bounds.width * self.scale  / 2
                        } else if rightEdge < UIScreen.main.bounds.width {
                            self.location.x = UIScreen.main.bounds.width - UIScreen.main.bounds.width * self.scale / 2
                        }
                        if topEdge <= (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2 && bottomEdge >= (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2 {
                            //none
                        } else if topEdge > (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2 {
                            self.location.y = (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) / 2 + UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                        } else if bottomEdge < (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2 {
                            self.location.y = (UIScreen.main.bounds.height + UIScreen.main.bounds.width * aspectRatio) / 2 - UIScreen.main.bounds.width * aspectRatio * self.scale / 2
                        }
                        self.endLocation.x = self.location.x
                        self.endLocation.y = self.location.y
                        self.lastValue = 1.0
                    }
                    if self.scale != 1.0 {
                        if let uiimage = UIImage(contentsOfFile: imageFile) {
                            updateCroppedUiimage2(uiimage: uiimage)
                        }
                    } else {
                        if let uiimage = UIImage(contentsOfFile: imageFile) {
                            self.croppedUiimage = uiimage
                        }
                    }
                }
            }
        ZStack {
            Color.black
                .ignoresSafeArea()
            if let uiimage = UIImage(contentsOfFile: imageFile) {
                ZStack {
                    Image(uiImage: uiimage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(self.scale)
                        .position(location)
                        .gesture(self.scale != 1 ? dragGesture : nil)
                        .gesture(magnificationGesture)
                        //.gesture(magnifyGesture)
                        .onTapGesture(count: 2) {
                            self.scale = self.scale * 2
                        }
                    if isShowMenuIcon == true {
                        if mainCategoryIds.count != 0, isEditImageInfo == false {
                            if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.count <= 2 {
                                 //none
                            } else {
                                Text(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.replacingOccurrences(of: ",", with: "\n")[mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.replacingOccurrences(of: ",", with: "\n").index(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.replacingOccurrences(of: ",", with: "\n").startIndex, offsetBy: 1)...mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.replacingOccurrences(of: ",", with: "\n").index(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.replacingOccurrences(of: ",", with: "\n").endIndex, offsetBy: -2)])
                                    .foregroundColor(.white.opacity(0.5))
                                    .background(.black.opacity(0.5))
                            }
                        }
                        if isDetectQRMode == true {
                            if let features = detectQRCode((scale == 1.0 ? uiimage : croppedUiimage) ?? uiimage) as? [CIQRCodeFeature], !features.isEmpty {
                                ForEach(features.indices, id: \.self) { index in
                                    ZStack {
                                        Button {
                                            autoreleasepool {
                                                qrCapture.isRecognizedQRs[index].toggle()
                                                if qrCapture.isRecognizedQRs[index] == true {
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo == "" {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = "," + features[index].messageString! + ","
                                                    } else {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo += features[index].messageString! + ","
                                                    }
                                                } else {
                                                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.replacingOccurrences(of: "," + features[index].messageString! + ",", with: ",")
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo == "," {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = ""
                                                    }
                                                }
                                                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            }
                                        } label: {
                                            Text("")
                                                .frame(width: scale * features[index].bounds.width * (UIScreen.main.bounds.width / uiimage.size.width), height: scale * features[index].bounds.height * (UIScreen.main.bounds.width / uiimage.size.width))
                                                .border(qrCapture.isRecognizedQRs[index] ? .blue :.green, width: 1)
                                                .foregroundColor(.black)
                                                .background(qrCapture.isRecognizedQRs[index] ? .blue.opacity(0.1) : .green.opacity(0.1))
                                        }
                                        Text(features[index].messageString!)
                                            .font(.system(.caption2))
                                            .background(qrCapture.isRecognizedQRs[index] ? .blue.opacity(0.3) : .green.opacity(0.3))
                                            .foregroundColor(.black)
                                    }
                                    .position(x: detectQRCodePosition(axis: "x", uiimage: uiimage, croppedUiimage: (scale == 1.0 ? uiimage : croppedUiimage) ?? uiimage, features: features, index: index), y: detectQRCodePosition(axis: "y", uiimage: uiimage, croppedUiimage: (scale == 1.0 ? uiimage : croppedUiimage) ?? uiimage, features: features, index: index))
                                }
                            }
                        }
                        if isDetectTextMode == true {
                            let recognizedTexts = recognizeTextInImage((scale == 1.0 ? uiimage : croppedUiimage) ?? uiimage)
                            ScrollView {
                                VStack(spacing: 0) {
                                    Spacer(minLength: 80)
                                    ForEach(recognizedTexts.indices, id: \.self) { index in
                                        Button {
                                            autoreleasepool {
                                                qrCapture.isRecognizedTexts[index].toggle()
                                                if qrCapture.isRecognizedTexts[index] == true {
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo == "" {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = "," + recognizedTexts[index] + ","
                                                    } else {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo += recognizedTexts[index] + ","
                                                    }
                                                } else {
                                                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.replacingOccurrences(of: "," + recognizedTexts[index] + ",", with: ",")
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo == "," {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = ""
                                                    }
                                                }
                                                for i in recognizedTexts.indices {
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.range(of: "," + recognizedTexts[i] + ",") != nil {
                                                        qrCapture.isRecognizedTexts[i] = true
                                                    } else {
                                                        qrCapture.isRecognizedTexts[i] = false
                                                    }
                                                }
                                                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            }
                                        } label: {
                                            Text(recognizedTexts[index])
                                                .frame(width: UIScreen.main.bounds.width, height: 25)
                                                .border(qrCapture.isRecognizedTexts[index] ? .blue : .green, width: 1)
                                                .foregroundColor(.white)
                                                .background(qrCapture.isRecognizedTexts[index] ? .blue.opacity(0.3) : .green.opacity(0.3))
                                        }
                                    }
                                    Spacer(minLength: 80)
                                }
                            }
                        }
                    }
                }
            }
            if isShowMenuIcon == true {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        if mainCategoryIds.count != 0 {
                            Button {
                                isEditImageInfo = true
                            } label: {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                    .frame(width: 30, height: 30)
                                    .background(.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.leading)
                            }
                            .alert("Image Information", isPresented: $isEditImageInfo, actions: {
                                let initialValue = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo
                                TextField("Image info", text: $mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo)
                                Button("Edit", action: {
                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo == "" {
                                        //none
                                    } else {
                                        if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.prefix(1) != "," {
                                            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = "," + mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo
                                        }
                                        if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.suffix(1) != "," {
                                            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo += ","
                                        }
                                    }
                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                })
                                Button("Clear", action: {
                                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = ""
                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                })
                                Button("Cancel", role: .cancel, action: {
                                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo = initialValue
                                })
                            }, message: {
                                
                            })
                            Spacer()
                            Button {
                                isDetectQRMode.toggle()
                            } label: {
                                Image(systemName: "qrcode.viewfinder")
                                    .frame(width: 30, height: 30)
                                    .background(isDetectQRMode == true ? .blue : .gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Spacer()
                            Button {
                                isDetectTextMode.toggle()
                            } label: {
                                ZStack {
                                    Image(systemName: "viewfinder")
                                        .frame(width: 30, height: 30)
                                        .background(isDetectTextMode == true ? .blue : .gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.vertical)
                                    Image(systemName: "textformat")
                                        .font(.system(size: 10))
                                        .frame(width: 30, height: 30)
                                        .background(.clear)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            Spacer()
                            Button {
                                autoreleasepool {
                                    if let uiimage = UIImage(contentsOfFile: imageFile) {
                                        let uiimage2 = rotateImage(uiimage, radians: CGFloat.pi / 2, isClockwise: true)
                                        do {
                                            try uiimage2.jpegData(compressionQuality:100)?.write(to:URL(fileURLWithPath: imageFile))
                                            if targetImageFileIndex != -1 {
                                                downSizeImages[mainCategoryIndex][subCategoryIndex][targetImageFileIndex] = uiimage2.resize(targetSize: CGSize(width: 200, height: 200))
                                            }
                                            ZipManager.saveZip(fileUrl: fileUrl)
                                            showImageView = false
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "rotate.right")
                                    .frame(width: 30, height: 30)
                                    .background(.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Spacer()
                            Button {
                                autoreleasepool {
                                    if let uiimage = UIImage(contentsOfFile: imageFile) {
                                        let uiimage2 = rotateImage(uiimage, radians: -CGFloat.pi / 2, isClockwise: false)
                                        do {
                                            try uiimage2.jpegData(compressionQuality:100)?.write(to:URL(fileURLWithPath: imageFile))
                                            if targetImageFileIndex != -1 {
                                                downSizeImages[mainCategoryIndex][subCategoryIndex][targetImageFileIndex] = uiimage2.resize(targetSize: CGSize(width: 200, height: 200))
                                            }
                                            ZipManager.saveZip(fileUrl: fileUrl)
                                            showImageView = false
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "rotate.left")
                                    .frame(width: 30, height: 30)
                                    .background(.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        Spacer()
                        Button {
                            showImageView = false
                            showImageView3 = false
                        } label: {
                            Image(systemName: "xmark")
                                .frame(width: 30, height: 30)
                                .background(.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.trailing)
                        }
                    }
                    .background(.black.opacity(0.3))
                    HStack(spacing: 0) {
                        Spacer()
                    }
                    .frame(height: 20)
                    .background(.black.opacity(0.3))
                    Spacer()
                    if subCategoryIndex != -1 {
                        VStack {
                            ZStack {
                                if let range = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.range(of: ":=") {
                                    let idx = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.index(range.lowerBound, offsetBy: -1)
                                    Text(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory[...idx] + " (\(String(targetImageFileIndex + 1))/\(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages))")
                                        .foregroundColor(.white)
                                }
                                HStack {
                                    if subCategoryIndex > 0 {
                                        Button {
                                            autoreleasepool {
                                                let startIndex = subCategoryIndex - 1
                                                for i in stride(from: startIndex, through: 0, by: -1) {
                                                    if mainCategoryIds[mainCategoryIndex].items[i].countStoredImages > 0 {
                                                        subCategoryIndex = i
                                                        targetImageFileIndex = 0
                                                        showImageView.toggle()
                                                        showImageView3 = !showImageView
                                                        break
                                                    }
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text("Prev")
                                                Image(systemName: "folder")
                                            }
                                            .frame(width: 80, height: 30)
                                            .foregroundColor(.white)
                                            .background(.gray)
                                            .cornerRadius(10)
                                            .padding(.leading)
                                        }
                                    }
                                    Spacer()
                                    if subCategoryIndex < mainCategoryIds[mainCategoryIndex].items.count - 1 {
                                        Button {
                                            autoreleasepool {
                                                let startIndex = subCategoryIndex + 1
                                                for i in startIndex..<mainCategoryIds[mainCategoryIndex].items.count {
                                                    if mainCategoryIds[mainCategoryIndex].items[i].countStoredImages > 0 {
                                                        subCategoryIndex = i
                                                        targetImageFileIndex = 0
                                                        showImageView.toggle()
                                                        showImageView3 = !showImageView
                                                        break
                                                    }
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text("Next")
                                                Image(systemName: "folder")
                                            }
                                            .frame(width: 80, height: 30)
                                            .foregroundColor(.white)
                                            .background(.gray)
                                            .cornerRadius(10)
                                            .padding(.trailing)
                                        }
                                    }
                                }
                            }
                            VStack {
                            }
                            .frame(height: 20)
                        }
                        .background(.black.opacity(0.3))
                    }
                }
            }
        }
        .onTapGesture {
            isShowMenuIcon.toggle()
        }
    }
    private func rotateImage(_ image: UIImage, radians: CGFloat, isClockwise: Bool) -> UIImage {
        autoreleasepool {
            recognizedTexts = []
            qrCapture.isRecognizedTexts = []
            if image.imageOrientation == .up {
                let rotatedSize = CGRect(origin: .zero, size: image.size)
                    .applying(CGAffineTransform(rotationAngle: radians))
                    .integral.size
                UIGraphicsBeginImageContextWithOptions(rotatedSize, false, image.scale)
                let context = UIGraphicsGetCurrentContext()!
                context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
                context.rotate(by: radians)
                context.scaleBy(x: 1, y: -1)
                context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
                context.draw(image.cgImage!, in: .init(origin: .zero, size: image.size))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                return newImage
            } else {
                let cgImage = image.cgImage
                let newImage = UIImage(cgImage: cgImage!, scale: image.scale, orientation: UIImage.Orientation.up)
                if (image.imageOrientation == .right && !isClockwise) || (image.imageOrientation == .left && isClockwise) {
                    return newImage
                } else {
                    var radians2 = radians
                    if image.imageOrientation == .right && isClockwise {
                        radians2 = -CGFloat.pi
                    } else if image.imageOrientation == .left && !isClockwise {
                        radians2 = CGFloat.pi
                    } else if image.imageOrientation == .down && !isClockwise {
                        radians2 = -CGFloat.pi / 2
                    } else if image.imageOrientation == .down && isClockwise {
                        radians2 = CGFloat.pi / 2
                    } else {
                        return newImage
                    }
                    let rotatedSize = CGRect(origin: .zero, size: newImage.size)
                        .applying(CGAffineTransform(rotationAngle: radians2))
                        .integral.size
                    UIGraphicsBeginImageContextWithOptions(rotatedSize, false, newImage.scale)
                    let context = UIGraphicsGetCurrentContext()!
                    context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
                    context.rotate(by: radians2)
                    context.scaleBy(x: 1, y: -1)
                    context.translateBy(x: -newImage.size.width / 2, y: -newImage.size.height / 2)
                    context.draw(newImage.cgImage!, in: .init(origin: .zero, size: newImage.size))
                    let newImage2 = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    return newImage2
                }
            }
        }
    }
    private func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        autoreleasepool {
            if let image = image, let ciImage = CIImage.init(image: image) {
                var options: [String: Any]
                let context = CIContext()
                options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
                if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)) {
                    options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
                } else {
                    options = [CIDetectorImageOrientation: 1]
                }
                let features = qrDetector?.features(in: ciImage, options: options)
                if let features = features, features.count > 0 {
                    qrCapture.isRecognizedQRs = Array(repeating: false, count: features.count)
                    for i in features.indices {
                        if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.range(of: "," + (features as! [CIQRCodeFeature])[i].messageString! + ",") != nil {
                            qrCapture.isRecognizedQRs[i] = true
                        } else {
                            qrCapture.isRecognizedQRs[i] = false
                        }
                    }
                }
                return features
            }
            return nil
        }
    }
    private func detectQRCodePosition(axis: String, uiimage: UIImage, croppedUiimage: UIImage, features: [CIQRCodeFeature], index: Int) -> CGFloat {
        autoreleasepool {
            if axis == "x" {
                if uiimage.imageOrientation == .right {
                    let position = (features[index].bounds.minY + features[index].bounds.width * 0.5) * scale * (UIScreen.main.bounds.width / uiimage.size.width)
                    return position
                } else if uiimage.imageOrientation == .up {
                    let position = (features[index].bounds.minX + features[index].bounds.width * 0.5) * scale * (UIScreen.main.bounds.width / uiimage.size.width)
                    return position
                } else if uiimage.imageOrientation == .left {
                    let position = UIScreen.main.bounds.width - ((features[index].bounds.minY + features[index].bounds.width * 0.5) * scale * (UIScreen.main.bounds.width / uiimage.size.width))
                    return position
                } else if uiimage.imageOrientation == .down {
                    let position = UIScreen.main.bounds.width - ((features[index].bounds.minX + features[index].bounds.width * 0.5) * scale * (UIScreen.main.bounds.width / uiimage.size.width))
                    return position
                } else {
                    return 0.0
                }
            } else if axis == "y" {
                var offset = 0.0
                if (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * scale < UIScreen.main.bounds.width * aspectRatio {
                    offset = endLocation.y - uiimage.size.height * (UIScreen.main.bounds.width / uiimage.size.width) * scale * 0.5
                } else {
                    offset = (endLocation.y - uiimage.size.height * (UIScreen.main.bounds.width / uiimage.size.width) * scale * 0.5 < UIScreen.main.bounds.height * 0.5 - UIScreen.main.bounds.width * aspectRatio * 0.5) ? (UIScreen.main.bounds.height - UIScreen.main.bounds.width * aspectRatio) * 0.5 : endLocation.y - uiimage.size.height * (UIScreen.main.bounds.width / uiimage.size.width) * scale * 0.5
                }
                if uiimage.imageOrientation == .right {
                    let position = (features[index].bounds.minX + features[index].bounds.height * 0.5) * scale * (UIScreen.main.bounds.width / uiimage.size.width) + offset
                    return position
                } else if uiimage.imageOrientation == .up {
                    let position = (croppedUiimage.size.height - (features[index].bounds.minY + features[index].bounds.height * 0.5)) * scale * (UIScreen.main.bounds.width / uiimage.size.width) + offset
                    return position
                } else if uiimage.imageOrientation == .left {
                    let position = (croppedUiimage.size.height - (features[index].bounds.minX + features[index].bounds.height * 0.5)) * scale * (UIScreen.main.bounds.width / uiimage.size.width) + offset
                    return position
                } else if uiimage.imageOrientation == .down {
                    let position = (features[index].bounds.minY + features[index].bounds.height * 0.5) * scale * (UIScreen.main.bounds.width / uiimage.size.width) + offset
                    return position
                } else {
                    return 0.0
                }
            } else {
                return 0.0
            }
        }
    }
    private func recognizeTextInImage(_ image: UIImage) -> [String] {
        autoreleasepool {
            guard let cgImage = image.cgImage else { return [] }
            let request = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                if qrCapture.isRecognizedTexts.count != observations.count {
                    qrCapture.isRecognizedTexts = Array(repeating: false, count: observations.count)
                }
                recognizedTexts = observations.compactMap{ $0.topCandidates(1).first?.string }
                for i in recognizedTexts.indices {
                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[targetImageFileIndex].imageInfo.range(of: "," + recognizedTexts[i] + ",") != nil {
                        qrCapture.isRecognizedTexts[i] = true
                    } else {
                        qrCapture.isRecognizedTexts[i] = false
                    }
                }
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ja-JP"]
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
            return recognizedTexts
        }
    }
    private func updateCroppedUiimage(uiimage: UIImage) {
        if uiimage.imageOrientation == .right {
            let rect = CGRect(x: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? 0 : uiimage.size.height * ((self.scale - aspectRatio * (uiimage.size.width / uiimage.size.height)) / self.scale) * 0.5 - ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.y - UIScreen.main.bounds.height * 0.5), y: uiimage.size.width * ((self.scale - 1) / self.scale) * 0.5 + ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.x - UIScreen.main.bounds.width * 0.5), width: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? (uiimage.size.width / UIScreen.main.bounds.width) * UIScreen.main.bounds.height * self.scale : aspectRatio * uiimage.size.width / self.scale, height: uiimage.size.width / self.scale)
            self.croppedUiimage = uiimage.crop(to: rect)
        } else if uiimage.imageOrientation == .up {
            let rect = CGRect(x: uiimage.size.width * ((self.scale - 1) / self.scale) * 0.5 - ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.x - UIScreen.main.bounds.width * 0.5), y: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? 0 : uiimage.size.height * ((self.scale - aspectRatio * (uiimage.size.width / uiimage.size.height)) / self.scale) * 0.5 - ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.y - UIScreen.main.bounds.height * 0.5), width: uiimage.size.width / self.scale, height: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? (uiimage.size.width / UIScreen.main.bounds.width) * UIScreen.main.bounds.height * self.scale : aspectRatio * uiimage.size.width / self.scale)
            self.croppedUiimage = uiimage.crop(to: rect)
        } else if uiimage.imageOrientation == .left {
            let rect = CGRect(x: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? 0 : uiimage.size.height * ((self.scale - aspectRatio * (uiimage.size.width / uiimage.size.height)) / self.scale) * 0.5 + ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.y - UIScreen.main.bounds.height * 0.5), y: uiimage.size.width * ((self.scale - 1) / self.scale) * 0.5 - ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.x - UIScreen.main.bounds.width * 0.5), width: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? (uiimage.size.width / UIScreen.main.bounds.width) * UIScreen.main.bounds.height * self.scale : aspectRatio * uiimage.size.width / self.scale, height: uiimage.size.width / self.scale)
            self.croppedUiimage = uiimage.crop(to: rect)
        } else if uiimage.imageOrientation == .down {
            let rect = CGRect(x: uiimage.size.width * ((self.scale - 1) / self.scale) * 0.5 + ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.x - UIScreen.main.bounds.width * 0.5), y: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? 0 : uiimage.size.height * ((self.scale - aspectRatio * (uiimage.size.width / uiimage.size.height)) / self.scale) * 0.5 + ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.y - UIScreen.main.bounds.height * 0.5), width: uiimage.size.width / self.scale, height: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? (uiimage.size.width / UIScreen.main.bounds.width) * UIScreen.main.bounds.height * self.scale : aspectRatio * uiimage.size.width / self.scale)
            self.croppedUiimage = uiimage.crop(to: rect)
        } else {
            self.croppedUiimage = uiimage
        }
    }
    private func updateCroppedUiimage2(uiimage: UIImage) {
        if self.scale != 1.0 {
            if let uiimage = UIImage(contentsOfFile: imageFile) {
                if uiimage.imageOrientation == .right {
                    let rect = CGRect(x: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? 0 : uiimage.size.height * ((self.scale - aspectRatio * (uiimage.size.width / uiimage.size.height)) / self.scale) * 0.5 - ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.y - UIScreen.main.bounds.height * 0.5), y: uiimage.size.width * ((self.scale - 1) / self.scale) * 0.5 + ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.x - UIScreen.main.bounds.width * 0.5), width: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? (uiimage.size.width / UIScreen.main.bounds.width) * UIScreen.main.bounds.height * self.scale : aspectRatio * uiimage.size.width / self.scale, height: uiimage.size.width / self.scale)
                    self.croppedUiimage = uiimage.crop(to: rect)
                } else if uiimage.imageOrientation == .up {
                    let rect = CGRect(x: uiimage.size.width * ((self.scale - 1) / self.scale) * 0.5 - ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.x - UIScreen.main.bounds.width * 0.5), y: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? 0 : uiimage.size.height * ((self.scale - aspectRatio * (uiimage.size.width / uiimage.size.height)) / self.scale) * 0.5 - ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.y - UIScreen.main.bounds.height * 0.5), width: uiimage.size.width / self.scale, height: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? (uiimage.size.width / UIScreen.main.bounds.width) * UIScreen.main.bounds.height * self.scale : aspectRatio * uiimage.size.width / self.scale)
                    self.croppedUiimage = uiimage.crop(to: rect)
                } else if uiimage.imageOrientation == .left {
                    let rect = CGRect(x: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? 0 : uiimage.size.height * ((self.scale - aspectRatio * (uiimage.size.width / uiimage.size.height)) / self.scale) * 0.5 + ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.y - UIScreen.main.bounds.height * 0.5), y: uiimage.size.width * ((self.scale - 1) / self.scale) * 0.5 - ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.x - UIScreen.main.bounds.width * 0.5), width: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? (uiimage.size.width / UIScreen.main.bounds.width) * UIScreen.main.bounds.height * self.scale : aspectRatio * uiimage.size.width / self.scale, height: uiimage.size.width / self.scale)
                    self.croppedUiimage = uiimage.crop(to: rect)
                } else if uiimage.imageOrientation == .down {
                    let rect = CGRect(x: uiimage.size.width * ((self.scale - 1) / self.scale) * 0.5 + ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.x - UIScreen.main.bounds.width * 0.5), y: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? 0 : uiimage.size.height * ((self.scale - aspectRatio * (uiimage.size.width / uiimage.size.height)) / self.scale) * 0.5 + ((uiimage.size.width / UIScreen.main.bounds.width) / self.scale) * (self.endLocation.y - UIScreen.main.bounds.height * 0.5), width: uiimage.size.width / self.scale, height: (UIScreen.main.bounds.width / uiimage.size.width) * uiimage.size.height * self.scale < UIScreen.main.bounds.width * aspectRatio ? (uiimage.size.width / UIScreen.main.bounds.width) * UIScreen.main.bounds.height * self.scale : aspectRatio * uiimage.size.width / self.scale)
                    self.croppedUiimage = uiimage.crop(to: rect)
                } else {
                    self.croppedUiimage = uiimage
                }
            }
        } else {
            if let uiimage = UIImage(contentsOfFile: imageFile) {
                self.croppedUiimage = uiimage
            }
        }
    }
}
class QRCapture: NSObject, ObservableObject {
    var isRecognizedQRs: [Bool] = []
    var isRecognizedTexts: [Bool] = []
}
extension UIImage {
    func crop(to rect: CGRect) -> UIImage? {
        autoreleasepool {
            let scaledRect = CGRect(x: rect.origin.x * self.scale, y: rect.origin.y * self.scale, width: rect.size.width * self.scale, height: rect.size.height * self.scale)
            guard let cgImage = self.cgImage?.cropping(to: scaledRect) else { return nil }
            return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        }
    }
}
