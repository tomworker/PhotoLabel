//
//  EachTabView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct EachTabView: View {
    @Binding var showImageStocker: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var workSpace: [ImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @Binding var fileUrl: URL
    @Binding var plistCategoryName: String
    @Binding var targetSubCategoryIndex: [Int]
    @State var moveToWorkSpace = false
    @State var showImagePicker2 = false
    @State var showPhotoLibrary2 = false
    @State var isTargeted1 = false
    @State var isTargetedIndex1 = -1
    @State var isTargeted2 = false
    @State var isTargetedIndex2 = -1
    @State var targetImageFile = ""
    @State var showImageView = false
    @State var isDuplicateMode = false
    let sheetId = 2
    var columns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber)), spacing: 5), count: ConfigManager.imageColumnNumber)
    var columns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber)), spacing: 5), count: ConfigManager.iPadImageColumnNumber)
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)

    var body: some View {
        ScrollView {
            ForEach(mainCategoryIds.indices) { mainCategoryIndex in
                ForEach(mainCategoryIds[mainCategoryIndex].items.indices) { subCategoryIndex in
                    if mainCategoryIndex == targetSubCategoryIndex[0] && subCategoryIndex == targetSubCategoryIndex[1] {
                        VStack(spacing: 5) {
                            HStack {
                                Button {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        print("Camera is available")
                                        showImagePicker2.toggle()
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
                                .sheet(isPresented: $showImagePicker2) {
                                    ImagePickerView(sheetId: sheetId, sourceType: .camera, showImagePicker: $showImagePicker2, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: fileUrl)
                                }
                                Button {
                                    showPhotoLibrary2.toggle()
                                } label: {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .frame(width: 50, height: 30)
                                        .background(LinearGradient(gradient: Gradient(colors: [.brown]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .sheet(isPresented: $showPhotoLibrary2) {
                                    ImagePickerView(sheetId: sheetId, sourceType: .photoLibrary, showImagePicker: $showPhotoLibrary2, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: fileUrl)
                                }
                                Spacer()
                                Button {
                                } label: {
                                    Text("To Workspace")
                                        .frame(maxWidth: .infinity, minHeight: 30)
                                        .background(moveToWorkSpace ? .orange : subCategoryIndex % 2 == 0 ? .brown.opacity(0.8) : .indigo.opacity(0.8))
                                        .foregroundColor(.white)
                                        .dropDestination(for: String.self) { indexs, location in
                                            let arr: [String] = indexs.first!.components(separatedBy: ":")
                                            var indexs1: [String] = []
                                            indexs1.append(arr[0])
                                            var indexs2: [String] = []
                                            indexs2.append(arr[1])
                                            var indexs3: [String] = []
                                            indexs3.append(arr[2])
                                            if indexs3.first! != "2" {
                                                if URL(string: indexs2[0])!.lastPathComponent.first == "@" {
                                                } else {
                                                    ZipManager.moveImagesFromPlistToWorkSpace(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace, duplicateSpace: &duplicateSpace)
                                                    if workSpace.count >= 2 {
                                                        CategoryManager.moveItemFromLastToFirst(image: ImageFileId(id: workSpace.count - 1, imageFile: ImageFile(imageFile: indexs1.first!)), workSpace: &workSpace)
                                                    }
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                            }
                                            return true
                                        } isTargeted: { isTargeted in
                                            moveToWorkSpace = isTargeted
                                        }
                                }
                                Spacer()
                                Button {
                                    showImageStocker = false
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
                        VStack(spacing:5) {
                            VStack {
                                Text(plistCategoryName.replacingOccurrences(of: "_", with: " / "))
                                    .frame(maxWidth: .infinity)
                                    .background(subCategoryIndex % 2 == 0 ? LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.2), .indigo.opacity(0.2), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.clear, .brown.opacity(0.2), .brown.opacity(0.2), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(subCategoryIndex % 2 == 0 ? .indigo : .brown).bold()
                                Text("Category: " + mainCategoryIds[mainCategoryIndex].mainCategory)
                                    .frame(maxWidth: .infinity)
                                    .background(subCategoryIndex % 2 == 0 ? LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.clear, .brown.opacity(0.8), .brown.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.white)
                            }
                            Text(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)
                            if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages == 0 {
                                LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1) {
                                    ZStack{
                                        Text("Take photo\n        or\nMove here")
                                            .aspectRatio(4 / 3, contentMode: .fit)
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - 40) / 5 : (UIScreen.main.bounds.width - 10 ) / 2, height: UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - 40) / 5 * 3 / 4: (UIScreen.main.bounds.width - 10 ) / 2 * 3 / 4)
                                            .foregroundColor(.white)
                                            .background(.gray.opacity((0.3)))
                                            .cornerRadius(10)
                                            .border(.indigo, width: isTargeted1 ? 3 : .zero)
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
                                                            duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: 0)
                                                            ZipManager.moveImagesFromDuplicateSpaceToPlist(imageFile: duplicateSpaceImageFileName, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex)
                                                            ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                        } catch {
                                                            print("Writing Jpg file failed with error:\(error)")
                                                        }
                                                    }
                                                } else if indexs3.first! == "1" {
                                                    var duplicateSpaceImageFileName = URL(string: indexs2[0])!.lastPathComponent
                                                    duplicateSpaceImageFileName = duplicateSpaceImageFileName.replacingOccurrences(of: "@", with: "")
                                                    duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory) , at: 0)
                                                    ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                                return true
                                            } isTargeted: { isTargeted in
                                                self.isTargeted1 = isTargeted
                                            }
                                    }
                                    Rectangle()
                                        .frame(width: 180, height: 135)
                                        .foregroundColor(.clear)
                                }
                            }
                            LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1) {
                                ForEach(CategoryManager.convertIdentifiable(imageFiles: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)) { imageFileId in
                                    if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                        Image(uiImage: uiimage)
                                            .resizable()
                                            .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - 40 ) / 5 : (UIScreen.main.bounds.width - 40 ) / 5 * 3 / 4 : uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - 10 ) / 2 : (UIScreen.main.bounds.width - 10 ) / 2 * 3 / 4)
                                            .cornerRadius(10)
                                            .border(.indigo, width: isTargeted1 && imageFileId.id == isTargetedIndex1 ? 3 : .zero)
                                            .onTapGesture(count: 2) {
                                                CategoryManager.moveItemFromLastToFirst(image: imageFileId, workSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)
                                                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            }
                                            .onTapGesture(count: 1) {
                                                showImageView = true
                                                self.targetImageFile = imageFileId.imageFile.imageFile
                                            }
                                            .draggable(String(imageFileId.id) + ":" + imageFileId.imageFile.imageFile + ":0") {
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
                                                    if let originalImage = UIImage(contentsOfFile: indexs2.first!) {
                                                        let dateFormatter = DateFormatter()
                                                        dateFormatter.dateFormat = "yyyyMMddHHmmss"
                                                        let jpgImageData = originalImage.jpegData(compressionQuality: 0.5)
                                                        let duplicateSpaceImageFileName = "\(dateFormatter.string(from: Date())).jpg"
                                                        let duplicateSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(duplicateSpaceImageFileName)
                                                        do {
                                                            try jpgImageData!.write(to: duplicateSpaceJpgUrl, options: .atomic)
                                                            duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: 0)
                                                            ZipManager.moveImagesFromDuplicateSpaceToPlist(imageFile: duplicateSpaceImageFileName, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex)
                                                            ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                        } catch {
                                                            print("Writing Jpg file failed with error:\(error)")
                                                        }
                                                    }
                                                } else if indexs3.first! == "1" {
                                                    var duplicateSpaceImageFileName = URL(string: indexs2[0])!.lastPathComponent
                                                    duplicateSpaceImageFileName = duplicateSpaceImageFileName.replacingOccurrences(of: "@", with: "")
                                                    duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: 0)
                                                    ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                } else if indexs3.first! == "0" {
                                                    CategoryManager.reorderItems(image: imageFileId, indexs: indexs1, workSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)
                                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                                return true
                                            } isTargeted: { isTargeted in
                                                self.isTargeted1 = isTargeted
                                                self.isTargetedIndex1 = imageFileId.id
                                            }
                                            .fullScreenCover(isPresented: $showImageView) {
                                                ImageView(showImageView: $showImageView, imageFile: targetImageFile)
                                            }
                                    }
                                }
                            }
                        }
                        VStack {
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
                        }
                        if isDuplicateMode {
                            LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1, spacing: 5) {
                                ForEach(CategoryManager.convertIdentifiable(duplicateImageFiles: duplicateSpace)) { duplicateImageFileId in
                                    if let uiimage = UIImage(contentsOfFile: duplicateImageFileId.duplicateImageFile.imageFile.imageFile) {
                                        ZStack {
                                            Image(uiImage: uiimage)
                                                .resizable()
                                                .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - 40 ) / 5 : (UIScreen.main.bounds.width - 40 ) / 5 * 3 / 4 : uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - 10 ) / 2 : (UIScreen.main.bounds.width - 10 ) / 2 * 3 / 4)
                                                .cornerRadius(10)
                                                .border(.indigo, width: isTargeted2 && duplicateImageFileId.id == isTargetedIndex2 ? 3 : .zero)
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
                                            self.isTargeted2 = isTargeted
                                            self.isTargetedIndex2 = duplicateImageFileId.id
                                        }
                                        .fullScreenCover(isPresented: $showImageView) {
                                            ImageView(showImageView: $showImageView, imageFile: targetImageFile)
                                        }
                                    }
                                }
                            }
                        } else {
                            LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1, spacing: 5) {
                                ForEach(CategoryManager.convertIdentifiable(imageFiles: workSpace)) { imageFileId in
                                    if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                        Image(uiImage: uiimage)
                                            .resizable()
                                            .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - 40 ) / 5 : (UIScreen.main.bounds.width - 40 ) / 5 * 3 / 4 : uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - 10 ) / 2 : (UIScreen.main.bounds.width - 10 ) / 2 * 3 / 4)
                                            .cornerRadius(10)
                                            .border(.indigo, width: isTargeted2 && imageFileId.id == isTargetedIndex2 ? 3 : .zero)
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
                                                } else if indexs3.first! == "0"  {
                                                    ZipManager.moveImagesFromPlistToWorkSpace(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace, duplicateSpace: &duplicateSpace)
                                                    if workSpace.count >= 2 {
                                                        CategoryManager.moveItemFromLastToFirst(image: ImageFileId(id: workSpace.count - 1, imageFile: ImageFile(imageFile: indexs1.first!)), workSpace: &workSpace)
                                                    }
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                                return true
                                            } isTargeted: { isTargeted in
                                                self.isTargeted2 = isTargeted
                                                self.isTargetedIndex2 = imageFileId.id
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
    }
}
