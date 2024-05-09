//
//  EachTabView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct EachTabView: View {
    @StateObject var photoCapture: PhotoCapture
    @Binding var showImageStocker: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @Binding var fileUrl: URL
    @Binding var plistCategoryName: String
    @Binding var targetSubCategoryIndex: [Int]
    @Binding var downSizeImages: [[[UIImage]]]
    @State var subCategory = ""
    @State var subCategory2 = ""
    @State var moveToWorkSpace = false
    @State var showPhotoCapture = false
    @State var showPhotoLibrary2 = false
    @State var isTargeted1 = false
    @State var isTargetedIndex1 = -1
    @State var isTargeted2 = false
    @State var isTargetedIndex2 = -1
    @State var isTargeted3 = false
    @State var targetImageFile = ""
    @State var targetImageFileIndex = -1
    @State var showImageView = false
    @State var showImageView2 = false
    @State var isDeleteMode = false
    @State var isWorkSpaceMode = false
    @State var isDuplicateMode = false
    @State var isSwapMode = false
    @State var isEditSubCategory = false
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)

    var body: some View {
        VStack(spacing: 5) {
            VStack(spacing: 5) {
                HStack {
                    Button {
                        if  UIDevice.current.userInterfaceIdiom == .phone {
                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                showPhotoCapture = true
                            }
                        } else {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                print("Camera is available")
                                showPhotoCapture.toggle()
                            } else {
                                print("Camara is not available")
                            }
                        }
                    } label: {
                        Image(systemName: "camera")
                            .frame(width: 50, height: 30)
                            .background(LinearGradient(gradient: Gradient(colors: [.indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.leading)
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
                    Spacer()
                    Toggle(isOn: $isDeleteMode) {
                        Image(systemName: "trash")
                            .foregroundColor(isDeleteMode ? .blue : .gray.opacity(0.5))
                    }
                    .fixedSize()
                    .tint(.blue)
                    Spacer()
                    Toggle(isOn: $isWorkSpaceMode) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(isWorkSpaceMode ? .blue : .gray.opacity(0.5))
                                .rotationEffect(Angle(degrees: 180))
                        }
                    }
                    .fixedSize()
                    .tint(.blue)
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
            ScrollView {
                ForEach(mainCategoryIds.indices, id: \.self) { mainCategoryIndex in
                    ForEach(mainCategoryIds[mainCategoryIndex].items.indices, id: \.self) { subCategoryIndex in
                        if mainCategoryIndex == targetSubCategoryIndex[0] && subCategoryIndex == targetSubCategoryIndex[1] {
                            VStack(spacing:5) {
                                VStack {
                                    Text(plistCategoryName.replacingOccurrences(of: "_", with: " / "))
                                        .frame(maxWidth: .infinity)
                                        .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.2), .indigo.opacity(0.2), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .foregroundColor(.indigo).bold()
                                    if let range = mainCategoryIds[mainCategoryIndex].mainCategory.range(of: ":=") {
                                        let idx = mainCategoryIds[mainCategoryIndex].mainCategory.index(range.lowerBound, offsetBy: -1)
                                        Text("Category: " + mainCategoryIds[mainCategoryIndex].mainCategory[...idx])
                                            .frame(maxWidth: .infinity)
                                            .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing) )
                                            .foregroundColor(.white)
                                    }
                                }
                                .fullScreenCover(isPresented: $showPhotoCapture) {
                                    if  UIDevice.current.userInterfaceIdiom == .phone {
                                        PhotoCaptureView(photoCapture: photoCapture, showPhotoCapture: $showPhotoCapture, caLayer: photoCapture.videoPreviewLayer, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: fileUrl, downSizeImages: $downSizeImages)
                                    } else {
                                        ImagePickerView(sourceType: .camera, showPhotoCapture: $showPhotoCapture, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: fileUrl, downSizeImages: $downSizeImages)
                                    }
                                }
                                .fullScreenCover(isPresented: $showPhotoLibrary2) {
                                    PhotoLibraryImagePickerView(showImagePicker: $showPhotoLibrary2, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: fileUrl, downSizeImages: $downSizeImages)
                                }
                                if let range = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.range(of: ":=") {
                                    let idx = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.index(range.lowerBound, offsetBy: -1)
                                    Text(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory[...idx])
                                        .onLongPressGesture {
                                            isEditSubCategory = true
                                            var array: [String] = ["", ""]
                                            if let range = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.range(of: ":=") {
                                                let idx = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.index(range.lowerBound, offsetBy: -1)
                                                let idx2 = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.index(range.lowerBound, offsetBy: 1)
                                                array[0] = String(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory[...idx])
                                                array[1] = String(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory[idx2...])
                                            } else {
                                                array[0] = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory
                                                array[1] = "=-,-,-"
                                            }
                                            subCategory = array[0]
                                            subCategory2 = array[1]
                                        }
                                        .alert("", isPresented: $isEditSubCategory, actions: {
                                            TextField("SubCategory", text: $subCategory)
                                            Button("Edit", action: {
                                                mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory = subCategory + ":" + subCategory2
                                                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            })
                                            Button("Cancel", role: .cancel, action: {subCategory = ""})
                                        }, message: {
                                            
                                        })
                                }
                                LazyVGrid(columns: CategoryManager.getColumns(userInterfaceIdiom: UIDevice.current.userInterfaceIdiom), spacing: 5) {
                                    ForEach(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.indices, id: \.self) { imageFileIndex in
                                        if let uiimage = UIImage(contentsOfFile: tempDirectoryUrl.path + "/" +  mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageFile) {
                                            ZStack {
                                                Image(uiImage: downSizeImages[mainCategoryIndex][subCategoryIndex][imageFileIndex])
                                                    .resizable()
                                                    .aspectRatio(CategoryManager.getAspectRatio(width: uiimage.size.width, height: uiimage.size.height), contentMode: .fit)
                                                    .frame(width: CategoryManager.getImageWidth(width: uiimage.size.width, height: uiimage.size.height, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom))
                                                    .cornerRadius(10)
                                                    .border(.indigo, width: CategoryManager.getBorderWidth(isTargeted: isTargeted1, index: imageFileIndex, isTargetedIndex: isTargetedIndex1))
                                                HStack {
                                                    if isDeleteMode == true {
                                                        Button {
                                                            let targetImageFile = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageFile
                                                            ZipManager.remove(fileUrl: tempDirectoryUrl.appendingPathComponent(targetImageFile))
                                                            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.remove(at: imageFileIndex)
                                                            downSizeImages[mainCategoryIndex][subCategoryIndex].remove(at: imageFileIndex)
                                                            duplicateSpace.removeAll(where: {$0.imageFile == targetImageFile})
                                                            print("Removed from plist:\(targetImageFile)")
                                                            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages -= 1
                                                            ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                        } label: {
                                                            Image(systemName: "trash")
                                                                .frame(width: 30, height: 30)
                                                                .background(.black.opacity(0.3))
                                                                .foregroundColor(.white)
                                                                .cornerRadius(10)
                                                        }
                                                    }
                                                    if isWorkSpaceMode == true {
                                                        Button {
                                                            var indexs1: [String] = []
                                                            indexs1.append(String(imageFileIndex))
                                                            ZipManager.moveImagesFromPlistToWorkSpace(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace, duplicateSpace: &duplicateSpace, downSizeImages: &downSizeImages[mainCategoryIndex][subCategoryIndex])
                                                            ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                        } label: {
                                                            Image(systemName: "square.and.arrow.up")
                                                                .frame(width: 30, height: 30)
                                                                .rotationEffect(Angle(degrees: 180))
                                                                .background(.black.opacity(0.3))
                                                                .foregroundColor(.white)
                                                                .cornerRadius(10)
                                                        }
                                                    }
                                                }
                                            }
                                            .onTapGesture(count: 2) {
                                                CategoryManager.moveItemFromLastToFirst(imageKey: imageFileIndex, imageSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images, downSizeImages: &downSizeImages[mainCategoryIndex][subCategoryIndex])
                                                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            }
                                            .onTapGesture(count: 1) {
                                                if isSwapMode == true {
                                                    CategoryManager.reorderItems(imageKey: imageFileIndex, index: isTargetedIndex1, imageSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images, downSizeImages: &downSizeImages[mainCategoryIndex][subCategoryIndex])
                                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                    isSwapMode = false
                                                    self.isTargeted1 = false
                                                } else {
                                                    showImageView2 = true
                                                    self.targetImageFileIndex = imageFileIndex
                                                }
                                            }
                                            .onLongPressGesture {
                                                isSwapMode = true
                                                self.isTargeted1 = true
                                                self.isTargetedIndex1 = imageFileIndex
                                            }
                                            .fullScreenCover(isPresented: $showImageView2) {
                                                ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView2, targetImageFileIndex: self._targetImageFileIndex, images: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, downSizeImages: $downSizeImages, mainCategoryIds: $mainCategoryIds)
                                            }
                                        }
                                    }
                                    ZStack{
                                        Text("Take photo\n        or\nMove here")
                                            .frame(width: CategoryManager.getImageWidth(width: 1.0, height: 0.75, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom), height: CategoryManager.getImageWidth(width: 0.75, height: 1.0, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom))
                                            .foregroundColor(.white)
                                            .background(.gray.opacity((0.3)))
                                            .cornerRadius(10)
                                            .border(.indigo, width: CategoryManager.getBorderWidth(isTargeted: isTargeted3, index: 0, isTargetedIndex: 0))
                                            .onTapGesture(count: 1) {
                                                if isSwapMode == true {
                                                    CategoryManager.reorderItems(imageKey: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.count, index: isTargetedIndex1, imageSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images, downSizeImages: &downSizeImages[mainCategoryIndex][subCategoryIndex])
                                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                    isSwapMode = false
                                                    self.isTargeted1 = false
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
                                HStack {
                                    Text("Move to Workspace/Stocker: ")
                                    Image(systemName: "square.and.arrow.up")
                                        .rotationEffect(Angle(degrees: 180))
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(.white)
                                Text("Move to top (double tap)")
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.white)
                                HStack {
                                    Text("Reorder images (long press & tap target)")
                                }
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(.white)
                            }
                            if isDuplicateMode {
                                LazyVGrid(columns: CategoryManager.getColumns(userInterfaceIdiom: UIDevice.current.userInterfaceIdiom), spacing: 5) {
                                    ForEach(duplicateSpace.indices, id: \.self) { duplicateSpaceImageFileIndex in
                                        if let uiimage = UIImage(contentsOfFile: duplicateSpace[duplicateSpaceImageFileIndex].subFolderMode == 1 ? tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[duplicateSpaceImageFileIndex].mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[duplicateSpaceImageFileIndex].subCategoryName)).appendingPathComponent(duplicateSpace[duplicateSpaceImageFileIndex].imageFile).path : tempDirectoryUrl.appendingPathComponent(duplicateSpace[duplicateSpaceImageFileIndex].imageFile).path) {
                                            ZStack {
                                                Image(uiImage: uiimage.resize(targetSize: CGSize(width: 200, height: 200)))
                                                    .resizable()
                                                    .aspectRatio(CategoryManager.getAspectRatio(width: uiimage.size.width, height: uiimage.size.height), contentMode: .fit)
                                                    .frame(width: CategoryManager.getImageWidth(width: uiimage.size.width, height: uiimage.size.height, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom))
                                                    .cornerRadius(10)
                                                    .border(.indigo, width: CategoryManager.getBorderWidth(isTargeted: isTargeted2, index: duplicateSpaceImageFileIndex, isTargetedIndex: isTargetedIndex2))
                                                VStack {
                                                    if let range = duplicateSpace[duplicateSpaceImageFileIndex].mainCategoryName.range(of: ":=") {
                                                        let idx = duplicateSpace[duplicateSpaceImageFileIndex].mainCategoryName.index(range.lowerBound, offsetBy: -1)
                                                        Text(duplicateSpace[duplicateSpaceImageFileIndex].mainCategoryName[...idx])
                                                            .foregroundColor(.white.opacity(0.5))
                                                            .background(.black.opacity(0.5))
                                                    }
                                                    if let range = duplicateSpace[duplicateSpaceImageFileIndex].subCategoryName.range(of: ":=") {
                                                        let idx = duplicateSpace[duplicateSpaceImageFileIndex].subCategoryName.index(range.lowerBound, offsetBy: -1)
                                                        Text(duplicateSpace[duplicateSpaceImageFileIndex].subCategoryName[...idx])
                                                            .foregroundColor(.white.opacity(0.5))
                                                            .background(.black.opacity(0.5))
                                                    }
                                                    if isWorkSpaceMode == true {
                                                        Button {
                                                            if let originalImage = UIImage(contentsOfFile: duplicateSpace[duplicateSpaceImageFileIndex].subFolderMode == 1 ? tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[duplicateSpaceImageFileIndex].mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[duplicateSpaceImageFileIndex].subCategoryName)).appendingPathComponent(duplicateSpace[duplicateSpaceImageFileIndex].imageFile).path : tempDirectoryUrl.appendingPathComponent(duplicateSpace[duplicateSpaceImageFileIndex].imageFile).path) {
                                                                let dateFormatter = DateFormatter()
                                                                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                                                                let jpgImageData = originalImage.jpegData(compressionQuality: 0.5)
                                                                let duplicateSpaceImageFileName = "\(dateFormatter.string(from: Date())).jpg"
                                                                var duplicateSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(duplicateSpaceImageFileName)
                                                                if mainCategoryIds[mainCategoryIndex].subFolderMode == 1 {
                                                                    duplicateSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)).appendingPathComponent(duplicateSpaceImageFileName)
                                                                    ZipManager.create(directoryUrl: tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)))
                                                                }
                                                                do {
                                                                    try jpgImageData!.write(to: duplicateSpaceJpgUrl, options: .atomic)
                                                                    duplicateSpace.insert(DuplicateImageFile(imageFile: duplicateSpaceImageFileName, subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: duplicateSpace.count)
                                                                    ZipManager.moveImagesFromDuplicateSpaceToPlist(imageFile: duplicateSpaceImageFileName, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, downSizeImages: &downSizeImages[mainCategoryIndex][subCategoryIndex])
                                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                                } catch {
                                                                    print("Writing Jpg file failed with error:\(error)")
                                                                }
                                                            }
                                                        } label: {
                                                            Image(systemName: "square.and.arrow.up")
                                                                .frame(width: 30, height: 30)
                                                                .background(.black.opacity(0.3))
                                                                .foregroundColor(.white)
                                                                .cornerRadius(10)
                                                        }
                                                    }
                                                }
                                            }
                                            .onTapGesture(count: 2) {
                                                CategoryManager.moveItemFromLastToFirst(imageKey: duplicateSpaceImageFileIndex, duplicateSpace: &duplicateSpace)
                                            }
                                            .onTapGesture(count: 1) {
                                                showImageView = true
                                                if duplicateSpace[duplicateSpaceImageFileIndex].subFolderMode == 1 {
                                                    self.targetImageFile = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[duplicateSpaceImageFileIndex].mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[duplicateSpaceImageFileIndex].subCategoryName)).appendingPathComponent(duplicateSpace[duplicateSpaceImageFileIndex].imageFile).path
                                                } else {
                                                    self.targetImageFile = tempDirectoryUrl.appendingPathComponent(duplicateSpace[duplicateSpaceImageFileIndex].imageFile).path
                                                }
                                            }
                                            .fullScreenCover(isPresented: $showImageView) {
                                                ImageView(fileUrl: $fileUrl, showImageView: $showImageView, imageFile: targetImageFile, mainCategoryIndex: -1, subCategoryIndex: -1, imageFileIndex: -1, downSizeImages: .constant([]), mainCategoryIds: .constant([]), isDetectQRMode: .constant(false), isShowMenuIcon: .constant(true), isDetectTextMode: .constant(false))
                                            }
                                        }
                                    }
                                }
                            } else {
                                LazyVGrid(columns: CategoryManager.getColumns(userInterfaceIdiom: UIDevice.current.userInterfaceIdiom), spacing: 5) {
                                    ForEach(workSpace.indices, id: \.self) { workSpaceImageFileIndex in
                                        if let uiimage = UIImage(contentsOfFile: tempDirectoryUrl.appendingPathComponent(workSpace[workSpaceImageFileIndex].imageFile).path) {
                                            ZStack {
                                                Image(uiImage: uiimage.resize(targetSize: CGSize(width: 200, height: 200)))
                                                    .resizable()
                                                    .aspectRatio(CategoryManager.getAspectRatio(width: uiimage.size.width, height: uiimage.size.height), contentMode: .fit)
                                                    .frame(width: CategoryManager.getImageWidth(width: uiimage.size.width, height: uiimage.size.height, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom))
                                                    .cornerRadius(10)
                                                    .border(.indigo, width: CategoryManager.getBorderWidth(isTargeted: isTargeted2, index: workSpaceImageFileIndex, isTargetedIndex: isTargetedIndex2))
                                                VStack {
                                                    Text(workSpace[workSpaceImageFileIndex].subDirectory)
                                                        .foregroundColor(.white.opacity(0.5))
                                                        .background(.black.opacity(0.5))
                                                }
                                                HStack {
                                                    if isDeleteMode == true {
                                                        Button {
                                                            let targetImageFile = workSpace[workSpaceImageFileIndex].imageFile
                                                            ZipManager.remove(fileUrl: tempDirectoryUrl.appendingPathComponent(targetImageFile))
                                                            workSpace.removeAll(where: {$0 == WorkSpaceImageFile(imageFile: targetImageFile, subDirectory: "")})
                                                            print("Removed from WorkSpace:\(targetImageFile)")
                                                            ZipManager.saveZip(fileUrl: fileUrl)
                                                        } label: {
                                                            Image(systemName: "trash")
                                                                .frame(width: 30, height: 30)
                                                                .background(.black.opacity(0.3))
                                                                .foregroundColor(.white)
                                                                .cornerRadius(10)
                                                        }
                                                    }
                                                    if isWorkSpaceMode == true {
                                                        Button {
                                                            var indexs1: [String] = []
                                                            indexs1.append(String(workSpaceImageFileIndex))
                                                            var duplicateSpaceImageFileName = workSpace[workSpaceImageFileIndex].imageFile
                                                            duplicateSpaceImageFileName = duplicateSpaceImageFileName.replacingOccurrences(of: "@", with: "")
                                                            duplicateSpace.insert(DuplicateImageFile(imageFile: duplicateSpaceImageFileName, subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: duplicateSpace.count)
                                                            ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace, downSizeImages: &downSizeImages[mainCategoryIndex][subCategoryIndex])
                                                            ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                        } label: {
                                                            Image(systemName: "square.and.arrow.up")
                                                                .frame(width: 30, height: 30)
                                                                .background(.black.opacity(0.3))
                                                                .foregroundColor(.white)
                                                                .cornerRadius(10)
                                                        }
                                                    }
                                                }
                                            }
                                            .onTapGesture(count: 2) {
                                                CategoryManager.moveItemFromLastToFirst(imageKey: workSpaceImageFileIndex, workSpace: &workSpace)
                                            }
                                            .onTapGesture(count: 1) {
                                                showImageView = true
                                                self.targetImageFile = tempDirectoryUrl.appendingPathComponent(workSpace[workSpaceImageFileIndex].imageFile).path
                                            }
                                            .fullScreenCover(isPresented: $showImageView) {
                                                ImageView(fileUrl: $fileUrl, showImageView: $showImageView, imageFile: targetImageFile, mainCategoryIndex: -1, subCategoryIndex: -1, imageFileIndex: -1, downSizeImages: .constant([]), mainCategoryIds: .constant([]), isDetectQRMode: .constant(false), isShowMenuIcon: .constant(true), isDetectTextMode: .constant(false))
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
}
