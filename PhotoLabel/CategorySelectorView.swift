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
    @State var fileUrl: URL
    @State var plistCategoryName: String
    @State var showImagePicker = false
    @State var showImageStocker = false
    @State var showSubCategory = false
    @State var showFinalReport = false
    @State var moveToTrashBox = false
    @State var targetMainCategoryIndex = -1
    @State var targetSubCategoryId = SubCategoryId(id: 0, subCategory: "", countStoredImages: 0, images: [ImageFile(imageFile: "")], isTargeted: false)
    @State var targetSubCategoryIndex: [Int] = [-1, -1]
    @State var targetImageFile = ""
    @State var showImageView = false
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
                                .foregroundColor(Color.blue)
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
                        .foregroundColor(Color.indigo).bold()
                    if targetMainCategoryIndex == -1 {
                        Text(" ")
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(Color.white)
                    } else {
                        Text("Category: " + mainCategoryIds[targetMainCategoryIndex].mainCategory)
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(Color.white)
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
                        } label: {
                            Text(mainCategoryId.mainCategory)
                                .frame(width: 120, height: 50)
                                .background(mainCategoryId.id == targetMainCategoryIndex ? LinearGradient(gradient: Gradient(colors: [.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(Color.white)
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
                                    .frame(width: 70, height: 30)
                                    .background(LinearGradient(gradient: Gradient(colors: [.indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                                    .padding(.leading)
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePickerView(sheetId: sheetId, showImagePicker: $showImagePicker, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: -1, subCategoryIndex: -1, workSpace: $workSpace, fileUrl: fileUrl)
                            }
                            Spacer()
                            Button {
                            } label: {
                                HStack {
                                    Text("drag & drop >").foregroundColor(Color.white)
                                        .frame(width: 130, height: 30, alignment: .trailing)
                                        .foregroundColor(Color.white)
                                    Image(systemName: "trash")
                                        .frame(width: 40, height: 30, alignment: .leading)
                                        .foregroundColor(Color.white)
                                }
                                .frame(width: 170, height: 30)
                                .foregroundColor(moveToTrashBox ? Color.black : Color.blue.opacity(0))
                                .background(moveToTrashBox ? LinearGradient(gradient: Gradient(colors: [.orange]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .dropDestination(for: String.self) { images, location in
                                    ZipManager.moveImagesFromWorkSpaceToTrashBox(images: images, workSpace: &workSpace)
                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
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
                                    .background(Color.orange)
                                    .foregroundColor(Color.white)
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
                                                .foregroundColor(Color.white)
                                                .dropDestination(for: String.self) { images, location in
                                                    ZipManager.moveImagesFromWorkSpaceToPlist(images: images, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: targetMainCategoryIndex, subCategoryIndex: subCategoryId.id, workSpace: &workSpace)
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                    return true
                                                } isTargeted: { isTargeted in
                                                    mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].isTargeted = isTargeted
                                                }
                                        }
                                        .fullScreenCover(isPresented: $showImageStocker) {
                                            ImageStockerTabView(showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex)
                                            //ImageStockerView(showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex)
                                        }
                                    }
                                }
                                Rectangle()
                                    .frame(width: 45, height: 50)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
            }
            if showSubCategory {
                Text("WorkSpace (drag & drop)")
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                Text("Move to top (double tap)")
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
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
                                .draggable(String(imageFileId.id)) {
                                    Image(uiImage: uiimage).border(.secondary)
                                }
                                .dropDestination(for: String.self) { indexs, location in
                                    CategoryManager.reorderItems(image: imageFileId, indexs: indexs, workSpace: &workSpace)
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
