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
    let imageFile: String
    let mainCategoryIndex: Int
    let subCategoryIndex: Int
    let imageFileIndex: Int
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
    @State var aspectRatio: CGFloat = 1.0
    @State var isEditImageInfo = false
    @State var recognizedTexts: [String] = []
    @StateObject var qrCapture = QRCapture()

    var body: some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                self.location.x = value.location.x - (value.startLocation.x - self.endLocation.x)
                self.location.y = value.location.y - (value.startLocation.y - self.endLocation.y)
            }
            .onEnded { value in
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
            }
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in
                let delta = value / self.lastValue
                self.scale = self.scale * delta
                self.lastValue = value
            }
            .onEnded { value in
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
                        .onTapGesture(count: 2) {
                            self.scale = self.scale * 2
                        }
                    if isShowMenuIcon == true {
                        if mainCategoryIds.count != 0 {
                            Text(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo)
                                .foregroundColor(.white.opacity(0.5))
                                .background(.black.opacity(0.5))
                        }
                        if isDetectQRMode == true {
                            if let features = detectQRCode(uiimage) as? [CIQRCodeFeature], !features.isEmpty {
                                ForEach(features.indices, id: \.self) { index in
                                    ZStack {
                                        Button {
                                            autoreleasepool {
                                                qrCapture.isRecognizedQRs[index].toggle()
                                                if qrCapture.isRecognizedQRs[index] == true {
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo == "" {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = "," + features[index].messageString! + ","
                                                    } else {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo += features[index].messageString! + ","
                                                    }
                                                } else {
                                                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo.replacingOccurrences(of: "," + features[index].messageString! + ",", with: ",")
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo == "," {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = ""
                                                    }
                                                }
                                                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            }
                                        } label: {
                                            Text("")
                                                .frame(width: features[index].bounds.width * UIScreen.main.bounds.width / uiimage.size.width, height: features[index].bounds.height * UIScreen.main.bounds.width / uiimage.size.width)
                                                .border(qrCapture.isRecognizedQRs[index] ? .blue :.green, width: 1)
                                                .foregroundColor(.black)
                                                .background(qrCapture.isRecognizedQRs[index] ? .blue.opacity(0.1) : .green.opacity(0.1))
                                        }
                                        Text(features[index].messageString!)
                                            .font(.system(.caption2))
                                            .background(qrCapture.isRecognizedQRs[index] ? .blue.opacity(0.3) : .green.opacity(0.3))
                                            .foregroundColor(.black)
                                    }
                                    .position(x: uiimage.imageOrientation == .right ? CGFloat((features[index].bounds.minY + features[index].bounds.width / 2) * UIScreen.main.bounds.width / uiimage.size.width) : CGFloat((features[index].bounds.minX + (features[index].bounds.width / 2)) * UIScreen.main.bounds.width / uiimage.size.width), y: uiimage.imageOrientation == .right ? CGFloat((features[index].bounds.minX + features[index].bounds.height / 2)) * UIScreen.main.bounds.width / uiimage.size.width + (UIScreen.main.bounds.height - uiimage.size.height * UIScreen.main.bounds.width / uiimage.size.width) / 2 : CGFloat(UIScreen.main.bounds.height - (features[index].bounds.minY + (features[index].bounds.height / 2)) * UIScreen.main.bounds.width / uiimage.size.width - ((UIScreen.main.bounds.height / 2) - (uiimage.size.height / 2) * UIScreen.main.bounds.width / uiimage.size.width)))
                                    //.position(x: CGFloat((features[index].bounds.minY + features[index].bounds.width / 2) * UIScreen.main.bounds.width / uiimage.size.width), y: CGFloat((features[index].bounds.minX + features[index].bounds.height / 2)) * UIScreen.main.bounds.width / uiimage.size.width + (UIScreen.main.bounds.height - uiimage.size.height * UIScreen.main.bounds.width / uiimage.size.width) / 2)
                                    //.position(x: CGFloat((features[index].bounds.minX + (features[index].bounds.width / 2)) * UIScreen.main.bounds.width / uiimage.size.width), y: CGFloat(UIScreen.main.bounds.height - (features[index].bounds.minY + (features[index].bounds.height / 2)) * UIScreen.main.bounds.width / uiimage.size.width - ((UIScreen.main.bounds.height / 2) - (uiimage.size.height / 2) * UIScreen.main.bounds.width / uiimage.size.width)))
                                }
                            }
                        }
                        if isDetectTextMode == true {
                            let recognizedTexts = recognizeTextInImage(uiimage)
                            ScrollView {
                                VStack(spacing: 0) {
                                    Spacer(minLength: 80)
                                    ForEach(recognizedTexts.indices, id: \.self) { index in
                                        Button {
                                            autoreleasepool {
                                                qrCapture.isRecognizedTexts[index].toggle()
                                                if qrCapture.isRecognizedTexts[index] == true {
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo == "" {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = "," + recognizedTexts[index] + ","
                                                    } else {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo += recognizedTexts[index] + ","
                                                    }
                                                } else {
                                                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo.replacingOccurrences(of: "," + recognizedTexts[index] + ",", with: ",")
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo == "," {
                                                        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = ""
                                                    }
                                                }
                                                for i in recognizedTexts.indices {
                                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo.range(of: "," + recognizedTexts[i] + ",") != nil {
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
                VStack {
                    HStack {
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
                                let initialValue = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo
                                TextField("Image info", text: $mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo)
                                Button("Edit", action: {
                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                })
                                Button("Clear", action: {
                                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = ""
                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                })
                                Button("Cancel", role: .cancel, action: {
                                    mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = initialValue
                                })
                            }, message: {
                                
                            })
                            Spacer()
                            Button {
                                scale = 1
                                location = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
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
                                if let uiimage = UIImage(contentsOfFile: imageFile) {
                                    let uiimage2 = rotateImage(uiimage, radians: CGFloat.pi / 2, isClockwise: true)
                                    do {
                                        try uiimage2.jpegData(compressionQuality:100)?.write(to:URL(fileURLWithPath: imageFile))
                                        if imageFileIndex != -1 {
                                            downSizeImages[mainCategoryIndex][subCategoryIndex][imageFileIndex] = uiimage2.resize(targetSize: CGSize(width: 200, height: 200))
                                        }
                                        ZipManager.saveZip(fileUrl: fileUrl)
                                        showImageView = false
                                    } catch {
                                        print(error)
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
                                if let uiimage = UIImage(contentsOfFile: imageFile) {
                                    let uiimage2 = rotateImage(uiimage, radians: -CGFloat.pi / 2, isClockwise: false)
                                    do {
                                        try uiimage2.jpegData(compressionQuality:100)?.write(to:URL(fileURLWithPath: imageFile))
                                        if imageFileIndex != -1 {
                                            downSizeImages[mainCategoryIndex][subCategoryIndex][imageFileIndex] = uiimage2.resize(targetSize: CGSize(width: 200, height: 200))
                                        }
                                        ZipManager.saveZip(fileUrl: fileUrl)
                                        showImageView = false
                                    } catch {
                                        print(error)
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
                    Spacer()
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
                        if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo.range(of: "," + (features as! [CIQRCodeFeature])[i].messageString! + ",") != nil {
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
    private func recognizeTextInImage(_ image: UIImage) -> [String] {
        autoreleasepool {
            guard let cgImage = image.cgImage else { return [] }
            let request = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                if qrCapture.isRecognizedTexts.count == 0 {
                    qrCapture.isRecognizedTexts = Array(repeating: false, count: observations.count)
                }
                recognizedTexts = observations.compactMap{ $0.topCandidates(1).first?.string }
                for i in recognizedTexts.indices {
                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo.range(of: "," + recognizedTexts[i] + ",") != nil {
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
}
class QRCapture: NSObject, ObservableObject {
    var isRecognizedQRs: [Bool] = []
    var isRecognizedTexts: [Bool] = []
}
