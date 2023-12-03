//
//  CheckBoxView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/12/02.
//

import SwiftUI

struct CheckBoxView: View {
    @StateObject var photoCapture: PhotoCapture
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @Binding var plistCategoryName: String
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var fileUrl: URL
    @Binding var targetMainCategoryIndex: Int
    @Binding var showCheckBox: Bool
    @State var targetSubCategoryIndex = -1
    @State var targetSubCategoryIndex3 = -1
    @State var targetSubCategoryIndex4: [Int] = [-1, -1]
    @State var targetImageFileIndex = 0
    @State var showImageView = false
    @State var showImageStocker = false
    @State var isToggleCheckBox = false
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let initialOriginx = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5) + CGFloat(10) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3) + CGFloat(10))
    let imageWidth = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3))
    let imageHeight = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) * CGFloat(0.15) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(4))
    let lowerLoadLimit = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 5
    let upperLoadLimit = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8
    @State var originy = 150.0
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 0) {
                    Text("CheckBox")
                        .bold()
                }
                HStack(spacing: 0) {
                    Button {
                        clearCheckBox()
                    } label: {
                        Text("Clear")
                            .frame(width: 70, height: 30)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .frame(height: 30)
                    Spacer()
                    Button {
                        showCheckBox = false
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 30, height: 30)
                            .background(.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.trailing)
                    }
                }
            }
            .frame(height: 50)
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].mainCategory)
                        Spacer()
                    }
                }
                .frame(width: initialOriginx, height: 25)
                Spacer()
            }
            ScrollView {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].items) { subCategoryId in
                            HStack(alignment: .top, spacing: 0) {
                                VStack(alignment: .center, spacing: 0) {
                                    HStack(spacing: 0) {
                                        Text(subCategoryId.subCategory)
                                        Spacer()
                                    }
                                    .background((subCategoryId.id) % 2 == 0 ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
                                    .frame(height: 25)
                                    ScrollView(.horizontal) {
                                        HStack(spacing: 0) {
                                            if subCategoryId.countStoredImages == 0 {
                                                VStack(alignment: .center, spacing: 0) {
                                                    Text("Take photo")
                                                    Text("Long press here")
                                                }
                                                .frame(width: imageWidth, height: imageHeight)
                                                .foregroundColor(.white)
                                                .background(.gray.opacity((0.3)))
                                                .cornerRadius(10)
                                                .onLongPressGesture {
                                                    showImageStocker = true
                                                    targetSubCategoryIndex = subCategoryId.id
                                                    targetSubCategoryIndex4 = [targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex, targetSubCategoryIndex]
                                                }
                                            } else {
                                                ForEach(subCategoryId.images.indices, id: \.self) { index in
                                                    if index <= 1 {
                                                        if let uiimage = UIImage(contentsOfFile: tempDirectoryUrl.path + "/" + subCategoryId.images[index].imageFile) {
                                                            if originy > CGFloat(150) - (CGFloat(subCategoryId.id + lowerLoadLimit) * (imageHeight + 25)) && originy < CGFloat(150) - (CGFloat(subCategoryId.id - upperLoadLimit) * (imageHeight + 25)) {
                                                                Image(uiImage: ImageManager.downSize(uiimage: uiimage, scale: 0.1))
                                                                    .resizable()
                                                                    .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                                                    .frame(width: uiimage.size.width > uiimage.size.height ? imageWidth : imageHeight, height: imageHeight)
                                                                    .cornerRadius(10)
                                                                    //Recovery code for onTapGesture problem
                                                                    .onChange(of: showImageView) { newValue in }
                                                                    //Above code goes well for some reason.
                                                                    .onTapGesture(count: 1) {
                                                                        showImageView = true
                                                                        targetSubCategoryIndex = subCategoryId.id
                                                                        targetImageFileIndex = index
                                                                    }
                                                                    .onLongPressGesture {
                                                                    showImageStocker = true
                                                                    targetSubCategoryIndex = subCategoryId.id
                                                                    targetSubCategoryIndex4 = [targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex, targetSubCategoryIndex]
                                                                    }
                                                            } else {
                                                                VStack(alignment: .center, spacing: 0) {
                                                                    Text("Now loading...")
                                                                }
                                                                .frame(width: imageWidth, height: imageHeight)
                                                                .foregroundColor(.white)
                                                                .background(.gray.opacity((0.3)))
                                                                .cornerRadius(10)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .fullScreenCover(isPresented: $showImageView) {
                                            ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView, targetImageFileIndex: targetImageFileIndex, imageFileIds: CategoryManager.convertIdentifiable(imageFiles: mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].items[targetSubCategoryIndex].images, subFolderMode: mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].items[targetSubCategoryIndex].subCategory))
                                        }
                                        .fullScreenCover(isPresented: $showImageStocker) {
                                            ImageStockerTabView(photoCapture: photoCapture, showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex4)
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(width: initialOriginx * 1.5)
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 0) {
                                        //Text(subCategoryId.subCategory)
                                        Spacer()
                                    }
                                    .frame(height: 25)
                                    VStack(alignment: .center, spacing: 0) {
                                        HStack(spacing: 0) {
                                            Spacer()
                                            ZStack {
                                                Image(systemName: subCategoryId.subCategory.last == "*" ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(.blue)
                                                    .offset(y: -12.5)
                                                Circle()
                                                    .foregroundColor(.gray.opacity(0.1))
                                                    .frame(width: 35, height: 35)
                                                    .offset(y: -12.5)
                                                    .onTapGesture {
                                                        isToggleCheckBox = true
                                                        toggleCheckBox(mainCategoryIndex: targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex, subCategoryIndex: subCategoryId.id, subCategory: subCategoryId.subCategory)
                                                    }
                                            }
                                            Spacer()
                                        }
                                    }
                                    .frame(width: imageWidth, height: imageHeight)
                                    .foregroundColor(.white)
                                }
                                .frame(width: imageWidth)
                                .background((subCategoryId.id) % 2 == 0 ? Color(UIColor.systemGray5) : Color(UIColor.systemGray3))
                                .offset(y: 2)
                                Spacer()
                            }
                            .frame(height: imageHeight + 25)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .background(GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        let positiony = proxy.frame(in: .named("")).origin.y
                        if fabs(originy - positiony) > UIScreen.main.bounds.height || isToggleCheckBox == true {
                            originy = positiony
                            isToggleCheckBox = false
                        }
                    }
                    return Color.clear
                })
            }
        }
        Spacer()
    }
    private func clearCheckBox() {
        autoreleasepool {
            var initialValue = ""
            var toIdx = initialValue.startIndex
            for i in 0..<mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].items.count {
                initialValue = mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].items[i].subCategory
                toIdx = initialValue.index(initialValue.endIndex, offsetBy: -2)
                if initialValue.last == "*" {
                    mainCategoryIds[targetMainCategoryIndex == -1 ? 0 : targetMainCategoryIndex].items[i].subCategory = String(initialValue[...toIdx])
                }
            }
            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
        }
    }
    private func toggleCheckBox(mainCategoryIndex: Int, subCategoryIndex: Int, subCategory: String) {
        autoreleasepool {
            targetSubCategoryIndex3 = subCategoryIndex
            let initialValue = mainCategoryIds[mainCategoryIndex].items[targetSubCategoryIndex3].subCategory
            let toIdx = initialValue.index(initialValue.endIndex, offsetBy: -2)
            if subCategory.last == "*" {
                mainCategoryIds[mainCategoryIndex].items[targetSubCategoryIndex3].subCategory = String(initialValue[...toIdx])
            } else {
                mainCategoryIds[mainCategoryIndex].items[targetSubCategoryIndex3].subCategory = initialValue + "*"
            }
            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
        }
    }
}
