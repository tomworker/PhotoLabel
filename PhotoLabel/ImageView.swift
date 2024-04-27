//
//  ImageView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct ImageView: View {
    @Binding var fileUrl: URL
    @Binding var showImageView: Bool
    let imageFile: String
    let mainCategoryIndex: Int
    let subCategoryIndex: Int
    let imageFileIndex: Int
    @Binding var downSizeImages: [[[UIImage]]]
    @Binding var mainCategoryIds: [MainCategoryId]
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
                }
            }
            if mainCategoryIds.count != 0 {
                Text(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo)
                    .foregroundColor(.white.opacity(0.5))
                    .background(.black.opacity(0.5))
            }
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
                                .padding(.vertical)
                                .padding(.leading)
                        }
                        .alert("", isPresented: $isEditImageInfo, actions: {
                            let initialValue = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo
                            TextField("Image info", text: $mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo)
                            Button("Edit", action: {
                                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                            })
                            Button("Cancel", role: .cancel, action: {mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo = initialValue})
                        }, message: {
                            
                        })
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .frame(width: 30, height: 30)
                                .background(.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.vertical)
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            ZStack {
                                Image(systemName: "viewfinder")
                                    .frame(width: 30, height: 30)
                                    .background(.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.vertical)
                                Image(systemName: "textformat")
                                    .font(.system(size: 10))
                                    .frame(width: 30, height: 30)
                                    .background(.clear)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.vertical)
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
                                .padding(.vertical)
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
                                .padding(.vertical)
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
                            .padding(.vertical)
                            .padding(.trailing)
                    }
                }
                .background(.black.opacity(0.3))
                Spacer()
            }
        }
    }
    private func rotateImage(_ image: UIImage, radians: CGFloat, isClockwise: Bool) -> UIImage {
        autoreleasepool {
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
}
