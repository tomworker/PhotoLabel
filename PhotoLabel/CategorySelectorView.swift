//
//  CategorySelectorView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct CategorySelectorView: View {
    @Binding var showCategorySelector: Bool
    @State var mainCategoryIds: [MainCategoryId]
    @Binding var workSpace: [ImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @State var fileUrl: URL
    @State var plistCategoryName: String
    @State var showImagePicker = false
    @State var showPhotoLibrary = false
    @State var showImageStocker = false
    @State var showSubCategory = false
    @State var showFinalReport = false
    @State var moveToTrashBox = false
    @State var targetMainCategoryIndex = -1
    @State var targetSubCategoryId = SubCategoryId(id: 0, subCategory: "", countStoredImages: 0, images: [ImageFile(imageFile: "")], isTargeted: false)
    @State var targetSubCategoryIndex: [Int] = [-1, -1]
    @State var targetImageFile = ""
    @State var showImageView = false
    @State var isDuplicateMode = false
    var columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 2)
    var mainColumns1 = Array(repeating: GridItem(.fixed(120), spacing: 5), count: 3)
    var subColumns1 = Array(repeating: GridItem(.fixed(160), spacing: 5), count: 1)
    var subColumns2 = Array(repeating: GridItem(.fixed(160), spacing: 5), count: 2)
    var subColumns4 = Array(repeating: GridItem(.fixed(160), spacing: 5), count: 4)
    var subColumns8 = Array(repeating: GridItem(.fixed(160), spacing: 5), count: 8)
    @State var isTargeted = false
    @State var isTargetedIndex = -1
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let sheetId = 1

    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                ZStack {
                    HStack {
                        Button {
                            showCategorySelector = false
                        } label: {
                            Text("< Plist")
                                .frame(width: 50)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Button {
                            showFinalReport = true
                        } label: {
                            HStack {
                                Text("Final Report ")
                                Image(systemName: "apple.logo")
                            }
                            .frame(width: 150, height: 30)
                            .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.trailing)
                        }
                        .fullScreenCover(isPresented: $showFinalReport) {
                            finalReportView(showFinalReport: $showFinalReport, mainCategoryIds: $mainCategoryIds)
                        }
                    }
                }
                VStack {
                    Text(plistCategoryName.replacingOccurrences(of: "_", with: " / "))
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.2), .indigo.opacity(0.2), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.indigo).bold()
                    if targetMainCategoryIndex == -1 {
                        Text(" ")
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                    } else {
                        Text("Category: " + mainCategoryIds[targetMainCategoryIndex].mainCategory)
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                    }
                }
                HStack {
                    Image(systemName: "hand.point.right")
                    Text("Select Category")
                }
                LazyVGrid(columns: mainColumns1, spacing: 5) {
                    ForEach(mainCategoryIds) { mainCategoryId in
                        Button {
                            showSubCategory = true
                            targetMainCategoryIndex = mainCategoryId.id
                            targetSubCategoryIndex[1] = -1
                        } label: {
                            Text(mainCategoryId.mainCategory)
                                .frame(width: 120, height: 50)
                                .background(mainCategoryId.id == targetMainCategoryIndex ? LinearGradient(gradient: Gradient(colors: [.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(.white)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 5) {
                    if showSubCategory {
                        HStack {
                            Button {
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    print("Camera is available")
                                    showImagePicker.toggle()
                                } else {
                                    print("Camara is not available")
                                }
                            } label: {
                                Image(systemName: "camera")
                                    .frame(width: 50, height: 30)
                                    .background(LinearGradient(gradient: Gradient(colors: [.indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.leading)
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePickerView(sheetId: sheetId, sourceType: .camera, showImagePicker: $showImagePicker, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: -1, subCategoryIndex: -1, workSpace: $workSpace, fileUrl: fileUrl)
                            }
                            Button {
                                showPhotoLibrary = true
                            } label: {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .frame(width: 50, height: 30)
                                    .background(LinearGradient(gradient: Gradient(colors: [.brown]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .sheet(isPresented: $showPhotoLibrary) {
                                ImagePickerView(sheetId: sheetId, sourceType: .photoLibrary, showImagePicker: $showPhotoLibrary, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: -1, subCategoryIndex: -1, workSpace: $workSpace, fileUrl: fileUrl)
                            }
                            Spacer()
                            Button {
                            } label: {
                                HStack {
                                    Text("drag & drop >").foregroundColor(.white)
                                        .frame(width: 130, height: 30, alignment: .trailing)
                                        .foregroundColor(.white)
                                    Image(systemName: "trash")
                                        .frame(width: 40, height: 30, alignment: .leading)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 170, height: 30)
                                .foregroundColor(moveToTrashBox ? .black : .blue.opacity(0))
                                .background(moveToTrashBox ? LinearGradient(gradient: Gradient(colors: [.orange]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .dropDestination(for: String.self) { indexs, location in
                                    let arr: [String] = indexs.first!.components(separatedBy: ":")
                                    var indexs1: [String] = []
                                    indexs1.append(arr[0])
                                    var indexs2: [String] = []
                                    indexs2.append(arr[1])
                                    var indexs3: [String] = []
                                    indexs3.append(arr[2])
                                    if indexs3.first! != "2" {
                                        ZipManager.moveImagesFromWorkSpaceToTrashBox(images: indexs1, workSpace: &workSpace)
                                        ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                    }
                                    return true
                                } isTargeted: { isTargeted in
                                    moveToTrashBox = isTargeted
                                }
                            }
                            Spacer()
                            Button {
                                showSubCategory = false
                                targetMainCategoryIndex = -1
                                targetSubCategoryIndex = [-1, -1]
                            } label: {
                                Image(systemName: "xmark")
                                    .frame(width: 30, height: 30)
                                    .background(.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.trailing)
                            }
                        }
                        HStack {
                            Image(systemName: "hand.point.right")
                            Text("Select Details")
                        }
                        .frame(width: 370)
                        ScrollView(.horizontal) {
                            HStack(alignment: .top) {
                                LazyVGrid(columns: mainCategoryIds[targetMainCategoryIndex].items.count <= 10 ? subColumns2 : mainCategoryIds[targetMainCategoryIndex].items.count <= 20 ? subColumns4 : subColumns8, spacing: 5) {
                                    ForEach(mainCategoryIds[targetMainCategoryIndex].items) { subCategoryId in
                                        Button {
                                            showImageStocker = true
                                            targetSubCategoryId = subCategoryId
                                            targetSubCategoryIndex[0] = targetMainCategoryIndex
                                            targetSubCategoryIndex[1] = subCategoryId.id
                                        } label: {
                                            Text("\(subCategoryId.subCategory)\n(\(subCategoryId.countStoredImages))")
                                                .frame(maxWidth: .infinity, minHeight: 50)
                                                .background(subCategoryId.isTargeted ? LinearGradient(gradient: Gradient(colors: [.orange]), startPoint: .topLeading, endPoint: .bottomTrailing) : subCategoryId.id == targetSubCategoryIndex[1] ? LinearGradient(gradient: Gradient(colors: [.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .foregroundColor(.white)
                                                .dropDestination(for: String.self) { indexs, location in
                                                    let arr: [String] = indexs.first!.components(separatedBy: ":")
                                                    var indexs1: [String] = []
                                                    indexs1.append(arr[0])
                                                    var indexs2: [String] = []
                                                    indexs2.append(arr[1])
                                                    var indexs3: [String] = []
                                                    indexs3.append(arr[2])
                                                    if indexs3.first! == "2" {
                                                        if let originalImage = UIImage(contentsOfFile: indexs2.first!) {
                                                            let dateFormatter = DateFormatter()
                                                            dateFormatter.dateFormat = "yyyyMMddHHmmss"
                                                            let jpgImageData = originalImage.jpegData(compressionQuality: 0.5)
                                                            let duplicateSpaceImageFileName = "\(dateFormatter.string(from: Date())).jpg"
                                                            let duplicateSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(duplicateSpaceImageFileName)
                                                            do {
                                                                try jpgImageData!.write(to: duplicateSpaceJpgUrl, options: .atomic)
                                                                duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), mainCategoryName: mainCategoryIds[targetMainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].subCategory) , at: 0)
                                                                ZipManager.moveImagesFromDuplicateSpaceToPlist(imageFile: URL(string: indexs2.first!)!.lastPathComponent, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: targetMainCategoryIndex, subCategoryIndex: subCategoryId.id)
                                                                ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                            } catch {
                                                                print("Writing Jpg file failed with error:\(error)")
                                                            }
                                                        }
                                                    } else if indexs3.first! == "1" {
                                                        var duplicateSpaceImageFileName = URL(string: indexs2.first!)!.lastPathComponent
                                                        duplicateSpaceImageFileName = duplicateSpaceImageFileName.replacingOccurrences(of: "@", with: "")
                                                        duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), mainCategoryName: mainCategoryIds[targetMainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].subCategory) , at: 0)
                                                        ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: targetMainCategoryIndex, subCategoryIndex: subCategoryId.id, workSpace: &workSpace)
                                                        ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                    }
                                                    return true
                                                } isTargeted: { isTargeted in
                                                    mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].isTargeted = isTargeted
                                                }
                                        }
                                        .fullScreenCover(isPresented: $showImageStocker) {
                                            ImageStockerTabView(showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex)
                                        }
                                    }
                                }
                                Rectangle()
                                    .frame(width: 45, height: 50)
                                    .foregroundColor(.clear)
                                Spacer()
                            }
                        }
                    }
                }
            }
            if showSubCategory {
                Toggle(isOn: $isDuplicateMode) {
                    Text("Duplicate Mode")
                        .foregroundColor(isDuplicateMode ? .brown.opacity(0.8) : .gray.opacity(0.5))
                        .bold()
                }
                .fixedSize()
                .tint(.brown.opacity(0.8))
                Text("Workspace (drag & drop)")
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                Text("Move to top (double tap)")
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                if isDuplicateMode {
                    LazyVGrid(columns: columns, spacing: 5) {                        
                        ForEach(CategoryManager.convertIdentifiable(duplicateImageFiles: duplicateSpace)) { duplicateImageFileId in
                            if let uiimage = UIImage(contentsOfFile: duplicateImageFileId.duplicateImageFile.imageFile.imageFile) {
                                ZStack {
                                    Image(uiImage: uiimage)
                                        .resizable()
                                        .frame(width: uiimage.size.width >= uiimage.size.height ? 180 : 135, height: uiimage.size.width >= uiimage.size.height ? 135 : 180)
                                        .cornerRadius(10)
                                        .border(.indigo, width: isTargeted && duplicateImageFileId.id == isTargetedIndex ? 3 : .zero)
                                    VStack {
                                        Text(duplicateImageFileId.duplicateImageFile.mainCategoryName)
                                            .foregroundColor(.white.opacity(0.5))
                                            .background(.black.opacity(0.5))
                                        Text(duplicateImageFileId.duplicateImageFile.subCategoryName)
                                            .foregroundColor(.white.opacity(0.5))
                                            .background(.black.opacity(0.5))
                                    }
                                }
                                .onTapGesture(count: 2) {
                                    CategoryManager.moveItemFromLastToFirst(image: duplicateImageFileId, duplicateSpace: &duplicateSpace)
                                }
                                .onTapGesture(count: 1) {
                                    showImageView = true
                                    self.targetImageFile = duplicateImageFileId.duplicateImageFile.imageFile.imageFile
                                }
                                .draggable(String(duplicateImageFileId.id) + ":" + duplicateImageFileId.duplicateImageFile.imageFile.imageFile + ":2") {
                                    Image(uiImage: uiimage).border(.secondary)
                                }
                                .dropDestination(for: String.self) { indexs, location in
                                    let arr: [String] = indexs.first!.components(separatedBy: ":")
                                    var indexs1: [String] = []
                                    indexs1.append(arr[0])
                                    var indexs2: [String] = []
                                    indexs2.append(arr[1])
                                    var indexs3: [String] = []
                                    indexs3.append(arr[2])
                                    if indexs3.first! == "2" {
                                        CategoryManager.reorderItems(image: duplicateImageFileId, indexs: indexs1, duplicateSpace: &duplicateSpace)
                                    }
                                    return true
                                } isTargeted: { isTargeted in
                                    self.isTargeted = isTargeted
                                    self.isTargetedIndex = duplicateImageFileId.id
                                }
                                .fullScreenCover(isPresented: $showImageView) {
                                    ImageView(showImageView: $showImageView, imageFile: targetImageFile)
                                }
                            }
                        }
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(CategoryManager.convertIdentifiable(imageFiles: workSpace)) { imageFileId in
                            if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                Image(uiImage: uiimage)
                                    .resizable()
                                    .frame(width: uiimage.size.width >= uiimage.size.height ? 180 : 135, height: uiimage.size.width >= uiimage.size.height ? 135 : 180)
                                    .cornerRadius(10)
                                    .border(.indigo, width: isTargeted && imageFileId.id == isTargetedIndex ? 3 : .zero)
                                    .onTapGesture(count: 2) {
                                        CategoryManager.moveItemFromLastToFirst(image: imageFileId, workSpace: &workSpace)
                                    }
                                    .onTapGesture(count: 1) {
                                        showImageView = true
                                        self.targetImageFile = imageFileId.imageFile.imageFile
                                    }
                                    .draggable(String(imageFileId.id) + ":" + imageFileId.imageFile.imageFile + ":1") {
                                        Image(uiImage: uiimage).border(.secondary)
                                    }
                                    .dropDestination(for: String.self) { indexs, location in
                                        let arr: [String] = indexs.first!.components(separatedBy: ":")
                                        var indexs1: [String] = []
                                        indexs1.append(arr[0])
                                        var indexs2: [String] = []
                                        indexs2.append(arr[1])
                                        var indexs3: [String] = []
                                        indexs3.append(arr[2])
                                        if indexs3.first! == "1" {
                                            CategoryManager.reorderItems(image: imageFileId, indexs: indexs1, workSpace: &workSpace)
                                        }
                                        return true
                                    } isTargeted: { isTargeted in
                                        self.isTargeted = isTargeted
                                        self.isTargetedIndex = imageFileId.id
                                    }
                                    .fullScreenCover(isPresented: $showImageView) {
                                        ImageView(showImageView: $showImageView, imageFile: targetImageFile)
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}
