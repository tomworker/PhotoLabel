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
    @State var isEditSubCategory = false
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let lowerLoadLimit = UIDevice.current.userInterfaceIdiom == .pad ? 5 * ConfigManager.iPadImageColumnNumber : 3 * ConfigManager.imageColumnNumber - 1
    let upperLoadLimit = UIDevice.current.userInterfaceIdiom == .pad ? 8 * ConfigManager.iPadImageColumnNumber : 4 * ConfigManager.imageColumnNumber
    @State var originy = 150.0

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
                ForEach(mainCategoryIds.indices) { mainCategoryIndex in
                    ForEach(mainCategoryIds[mainCategoryIndex].items.indices) { subCategoryIndex in
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
                                        PhotoCaptureView(photoCapture: photoCapture, showPhotoCapture: $showPhotoCapture, caLayer: photoCapture.videoPreviewLayer, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: fileUrl)
                                    } else {
                                        ImagePickerView(sourceType: .camera, showPhotoCapture: $showPhotoCapture, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: fileUrl)
                                    }
                                }
                                .fullScreenCover(isPresented: $showPhotoLibrary2) {
                                    PhotoLibraryImagePickerView(showImagePicker: $showPhotoLibrary2, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: fileUrl)
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
                                    ForEach(CategoryManager.convertIdentifiable(imageFiles: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images, subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)) { imageFileId in
                                        if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                            if CategoryManager.isLocatedWithinArea(originy: originy, id: imageFileId.id, lowerLoadLimit: lowerLoadLimit, upperLoadLimit: upperLoadLimit) {
                                                ZStack {
                                                    Image(uiImage: ImageManager.downSize(uiimage: uiimage, scale: 0.3))
                                                        .resizable()
                                                        .aspectRatio(CategoryManager.getAspectRatio(width: uiimage.size.width, height: uiimage.size.height), contentMode: .fit)
                                                        .frame(width: CategoryManager.getImageWidth(width: uiimage.size.width, height: uiimage.size.height, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom))
                                                        .cornerRadius(10)
                                                        .border(.indigo, width: CategoryManager.getBorderWidth(isTargeted: isTargeted1, index: imageFileId.id, isTargetedIndex: isTargetedIndex1))
                                                    HStack {
                                                        if isDeleteMode == true {
                                                            Button {
                                                                let targetImageFile = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileId.id].imageFile
                                                                ZipManager.remove(fileUrl: tempDirectoryUrl.appendingPathComponent(targetImageFile))
                                                                mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.removeAll(where: { $0 == ImageFile(imageFile: targetImageFile)})
                                                                duplicateSpace.removeAll(where: {$0.imageFile == ImageFile(imageFile: targetImageFile)})
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
                                                                indexs1.append(String(imageFileId.id))
                                                                ZipManager.moveImagesFromPlistToWorkSpace(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace, duplicateSpace: &duplicateSpace)
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
                                                    CategoryManager.moveItemFromLastToFirst(image: imageFileId, imageSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)
                                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                                .onTapGesture(count: 1) {
                                                    showImageView2 = true
                                                    self.targetImageFileIndex = imageFileId.id
                                                }
                                                .draggable("\(String(imageFileId.id)):\(imageFileId.imageFile.imageFile):0") {
                                                    Image(uiImage: ImageManager.downSize(uiimage: uiimage, scale: 0.1))
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
                                                        if let originalImage = UIImage(contentsOfFile: duplicateSpace[Int(indexs1.first!)!].subFolderMode == 1 ? tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[Int(indexs1.first!)!].mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[Int(indexs1.first!)!].subCategoryName)).appendingPathComponent(indexs2.first!).path : tempDirectoryUrl.appendingPathComponent(indexs2.first!).path) {
                                                            let dateFormatter = DateFormatter()
                                                            dateFormatter.dateFormat = "yyyyMMddHHmmssS"
                                                            let jpgImageData = originalImage.jpegData(compressionQuality: 0.5)
                                                            let duplicateSpaceImageFileName = "\(dateFormatter.string(from: Date())).jpg"
                                                            var duplicateSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(duplicateSpaceImageFileName)
                                                            if mainCategoryIds[mainCategoryIndex].subFolderMode == 1 {
                                                                duplicateSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)).appendingPathComponent(duplicateSpaceImageFileName)
                                                                ZipManager.create(directoryUrl: tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)))
                                                            }
                                                            do {
                                                                try jpgImageData!.write(to: duplicateSpaceJpgUrl, options: .atomic)
                                                                duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: duplicateSpace.count)
                                                                ZipManager.moveImagesFromDuplicateSpaceToPlist(imageFile: duplicateSpaceImageFileName, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex)
                                                                ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                            } catch {
                                                                print("Writing Jpg file failed with error:\(error)")
                                                            }
                                                        }
                                                    } else if indexs3.first! == "1" {
                                                        var duplicateSpaceImageFileName = URL(string: indexs2[0])!.lastPathComponent
                                                        duplicateSpaceImageFileName = duplicateSpaceImageFileName.replacingOccurrences(of: "@", with: "")
                                                        duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: duplicateSpace.count)
                                                        ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
                                                        ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                    } else if indexs3.first! == "0" {
                                                        CategoryManager.reorderItems(imageKey: imageFileId.id, indexs: indexs1, imageSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)
                                                        ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                    }
                                                    return true
                                                } isTargeted: { isTargeted in
                                                    self.isTargeted1 = isTargeted
                                                    self.isTargetedIndex1 = imageFileId.id
                                                }
                                                .fullScreenCover(isPresented: $showImageView2) {
                                                    ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView2, targetImageFileIndex: self.targetImageFileIndex, imageFileIds: CategoryManager.convertIdentifiable(imageFiles: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images, subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory))
                                                }
                                            
                                            } else {
                                                VStack(alignment: .center, spacing: 0) {
                                                    Text("Now loading...")
                                                }
                                                .frame(width: CategoryManager.getImageWidth(width: 1.0, height: 0.75, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom), height: CategoryManager.getImageWidth(width: 0.75, height: 1.0, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom))
                                                .foregroundColor(.white)
                                                .background(.gray.opacity((0.3)))
                                                .cornerRadius(10)
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
                                            .dropDestination(for: String.self) { indexs, location in
                                                let arr: [String] = indexs.first!.components(separatedBy: ":")
                                                var indexs1: [String] = []
                                                indexs1.append(arr[0])
                                                var indexs2: [String] = []
                                                indexs2.append(arr[1])
                                                var indexs3: [String] = []
                                                indexs3.append(arr[2])
                                                if indexs3.first! == "2" {
                                                    if let originalImage = UIImage(contentsOfFile: duplicateSpace[Int(indexs1.first!)!].subFolderMode == 1 ? tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[Int(indexs1.first!)!].mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[Int(indexs1.first!)!].subCategoryName)).appendingPathComponent(indexs2.first!).path : tempDirectoryUrl.appendingPathComponent(indexs2.first!).path) {
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
                                                            duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: duplicateSpace.count)
                                                            ZipManager.moveImagesFromDuplicateSpaceToPlist(imageFile: duplicateSpaceImageFileName, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex)
                                                            ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                        } catch {
                                                            print("Writing Jpg file failed with error:\(error)")
                                                        }
                                                    }
                                                } else if indexs3.first! == "1" {
                                                    var duplicateSpaceImageFileName = URL(string: indexs2[0])!.lastPathComponent
                                                    duplicateSpaceImageFileName = duplicateSpaceImageFileName.replacingOccurrences(of: "@", with: "")
                                                    duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory) , at: duplicateSpace.count)
                                                    ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                } else if indexs3.first! == "0" {
                                                    CategoryManager.reorderItems(imageKey: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.count, indexs: indexs1, imageSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)
                                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                                return true
                                            } isTargeted: { isTargeted in
                                                self.isTargeted3 = isTargeted
                                            }
                                    }
                                }
                                .background(GeometryReader { proxy -> Color in
                                    DispatchQueue.main.async {
                                        let positiony = proxy.frame(in: .named("")).origin.y
                                        if fabs(originy - positiony) >= UIScreen.main.bounds.height {
                                            originy = positiony
                                        }
                                    }
                                    return Color.clear
                                })
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
                                    Text("Move to Workspace: ")
                                    Image(systemName: "square.and.arrow.up")
                                        .rotationEffect(Angle(degrees: 180))
                                }
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(.white)
                                Text("Move to top (double tap)")
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.white)
                                HStack {
                                    Text("Move to Stocker (drag & drop): ")
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(.white)
                            }
                            if isDuplicateMode {
                                LazyVGrid(columns: CategoryManager.getColumns(userInterfaceIdiom: UIDevice.current.userInterfaceIdiom), spacing: 5) {
                                    ForEach(duplicateSpace.indices, id: \.self) { index in
                                        if let uiimage = UIImage(contentsOfFile: duplicateSpace[index].subFolderMode == 1 ? tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[index].mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[index].subCategoryName)).appendingPathComponent(duplicateSpace[index].imageFile.imageFile).path : tempDirectoryUrl.appendingPathComponent(duplicateSpace[index].imageFile.imageFile).path) {
                                            ZStack {
                                                Image(uiImage: ImageManager.downSize(uiimage: uiimage, scale: 0.3))
                                                    .resizable()
                                                    .aspectRatio(CategoryManager.getAspectRatio(width: uiimage.size.width, height: uiimage.size.height), contentMode: .fit)
                                                    .frame(width: CategoryManager.getImageWidth(width: uiimage.size.width, height: uiimage.size.height, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom))
                                                    .cornerRadius(10)
                                                    .border(.indigo, width: CategoryManager.getBorderWidth(isTargeted: isTargeted2, index: index, isTargetedIndex: isTargetedIndex2))
                                                VStack {
                                                    if let range = duplicateSpace[index].mainCategoryName.range(of: ":=") {
                                                        let idx = duplicateSpace[index].mainCategoryName.index(range.lowerBound, offsetBy: -1)
                                                        Text(duplicateSpace[index].mainCategoryName[...idx])
                                                            .foregroundColor(.white.opacity(0.5))
                                                            .background(.black.opacity(0.5))
                                                    }
                                                    if let range = duplicateSpace[index].subCategoryName.range(of: ":=") {
                                                        let idx = duplicateSpace[index].subCategoryName.index(range.lowerBound, offsetBy: -1)
                                                        Text(duplicateSpace[index].subCategoryName[...idx])
                                                            .foregroundColor(.white.opacity(0.5))
                                                            .background(.black.opacity(0.5))
                                                    }
                                                }
                                            }
                                            .onTapGesture(count: 2) {
                                                CategoryManager.moveItemFromLastToFirst(image: CategoryManager.convertIdentifiable(duplicateImageFiles: duplicateSpace)[index], duplicateSpace: &duplicateSpace)
                                            }
                                            .onTapGesture(count: 1) {
                                                showImageView = true
                                                if duplicateSpace[index].subFolderMode == 1 {
                                                    self.targetImageFile = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[index].mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[index].subCategoryName)).appendingPathComponent(duplicateSpace[index].imageFile.imageFile).path
                                                } else {
                                                    self.targetImageFile = tempDirectoryUrl.appendingPathComponent(duplicateSpace[index].imageFile.imageFile).path
                                                }
                                            }
                                            .draggable("\(String(index)):\(duplicateSpace[index].imageFile.imageFile):2") {
                                                Image(uiImage: ImageManager.downSize(uiimage: uiimage, scale: 0.1))
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
                                                    CategoryManager.reorderItems(imageKey: index, indexs: indexs1, duplicateSpace: &duplicateSpace)
                                                }
                                                return true
                                            } isTargeted: { isTargeted in
                                                self.isTargeted2 = isTargeted
                                                self.isTargetedIndex2 = index
                                            }
                                            .fullScreenCover(isPresented: $showImageView) {
                                                ImageView(fileUrl: $fileUrl, showImageView: $showImageView, imageFile: targetImageFile)
                                            }
                                        }
                                    }
                                }
                            } else {
                                LazyVGrid(columns: CategoryManager.getColumns(userInterfaceIdiom: UIDevice.current.userInterfaceIdiom), spacing: 5) {
                                    ForEach(CategoryManager.convertIdentifiable(workSpaceImageFiles: workSpace)) { workSpaceImageFileId in
                                        if let uiimage = UIImage(contentsOfFile: workSpaceImageFileId.workSpaceImageFile.imageFile) {
                                            ZStack {
                                                Image(uiImage: ImageManager.downSize(uiimage: uiimage, scale: 0.3))
                                                    .resizable()
                                                    .aspectRatio(CategoryManager.getAspectRatio(width: uiimage.size.width, height: uiimage.size.height), contentMode: .fit)
                                                    .frame(width: CategoryManager.getImageWidth(width: uiimage.size.width, height: uiimage.size.height, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom))
                                                    .cornerRadius(10)
                                                    .border(.indigo, width: CategoryManager.getBorderWidth(isTargeted: isTargeted2, index: workSpaceImageFileId.id, isTargetedIndex: isTargetedIndex2))
                                                VStack {
                                                    Text(workSpaceImageFileId.workSpaceImageFile.subDirectory)
                                                        .foregroundColor(.white.opacity(0.5))
                                                        .background(.black.opacity(0.5))
                                                }
                                                HStack {
                                                    if isDeleteMode == true {
                                                        Button {
                                                            let targetImageFile = workSpace[workSpaceImageFileId.id].imageFile
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
                                                            indexs1.append(String(workSpaceImageFileId.id))
                                                            var duplicateSpaceImageFileName = workSpace[workSpaceImageFileId.id].imageFile
                                                            duplicateSpaceImageFileName = duplicateSpaceImageFileName.replacingOccurrences(of: "@", with: "")
                                                            duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), subFolderMode: mainCategoryIds[mainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[mainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory), at: duplicateSpace.count)
                                                            ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
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
                                                CategoryManager.moveItemFromLastToFirst(image: workSpaceImageFileId, workSpace: &workSpace)
                                            }
                                            .onTapGesture(count: 1) {
                                                showImageView = true
                                                self.targetImageFile = workSpaceImageFileId.workSpaceImageFile.imageFile
                                            }
                                            .draggable("\(String(workSpaceImageFileId.id)):\(workSpaceImageFileId.workSpaceImageFile.imageFile):1") {
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
                                                    CategoryManager.reorderItems(imageKey: workSpaceImageFileId.id, indexs: indexs1, workSpace: &workSpace)
                                                } else if indexs3.first! == "0"  {
                                                    ZipManager.moveImagesFromPlistToWorkSpace(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace, duplicateSpace: &duplicateSpace)
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                                return true
                                            } isTargeted: { isTargeted in
                                                self.isTargeted2 = isTargeted
                                                self.isTargetedIndex2 = workSpaceImageFileId.id
                                            }
                                            .fullScreenCover(isPresented: $showImageView) {
                                                ImageView(fileUrl: $fileUrl, showImageView: $showImageView, imageFile: targetImageFile)
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
