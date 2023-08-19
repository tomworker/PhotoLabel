//
//  CheckBoxEditView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/08/17.
//

import SwiftUI

struct CheckBoxEditView: View {
    @Binding var showCheckBoxEdit: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var fileUrl: URL
    @State var targetMainCategoryIndex: Int
    @State var targetSubCategoryIndex = -1
    @State var targetSubCategoryIndex2 = -1
    @State var targetSubCategoryIndex3 = -1
    @State var targetImageFileIndex = -1
    @State var showImageView = false
    @State var isEditSubCategory = false
    @State var initialOriginx = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - (CGFloat(5) - CGFloat(1)) * CGFloat(10)) / CGFloat(5) + CGFloat(10) : (UIScreen.main.bounds.width - (CGFloat(3) - CGFloat(1)) * CGFloat(10)) / CGFloat(3) + CGFloat(10))
    var columns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3)), spacing: 5), count: 1)
    var columns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(5) - 1) * 10) / CGFloat(5)), spacing: 5), count: 1)

    var body: some View {
        ZStack {
            Text("CheckBox Matrix")
                .bold()
            HStack {
                Spacer()
                Button {
                    showCheckBoxEdit = false
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
        HStack(spacing: 0) {
            ZStack {
                HStack(spacing: 0) {
                    Text(mainCategoryIds[targetMainCategoryIndex].mainCategory + ":")
                    Spacer()
                }
                .frame(height: 50)
                .background(Color(UIColor.systemGray3))
                .offset(x: initialOriginx)
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(mainCategoryIds[0].mainCategory + ":")
                            .frame(height:50)
                        Spacer()
                    }
                    .frame(width: initialOriginx, height: 50)
                    .background(Color(UIColor.systemBackground))
                    Spacer()
                }
            }
            .frame(height: 50)
            Spacer()
        }
        ScrollView {
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(mainCategoryIds[0].items) { subCategoryId in
                        HStack(alignment: .top, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(subCategoryId.subCategory)
                                if subCategoryId.countStoredImages == 0 {
                                    Text("N/A")
                                } else {
                                    ScrollView {
                                        LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1) {
                                            ForEach(CategoryManager.convertIdentifiable(imageFiles: subCategoryId.images, subFolderMode: mainCategoryIds[0].subFolderMode, mainCategoryName: mainCategoryIds[0].mainCategory, subCategoryName: subCategoryId.subCategory)) { imageFileId in
                                                if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                                    Image(uiImage: uiimage)
                                                        .resizable()
                                                        .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber) : (UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber) * 0.75 : uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3) : (UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3) * 0.75)
                                                        .cornerRadius(10)
                                                    //Recovery code for onTapGesture problem
                                                        .onChange(of: showImageView) { newValue in }
                                                    //Above code goes well for some reason.
                                                        .onTapGesture(count: 1) {
                                                            showImageView = true
                                                            self.targetSubCategoryIndex = subCategoryId.id
                                                            self.targetImageFileIndex = imageFileId.id
                                                        }
                                                        .fullScreenCover(isPresented: $showImageView) {
                                                            ImageTabView(showImageView: $showImageView, targetImageFileIndex: self.targetImageFileIndex, imageFileIds: CategoryManager.convertIdentifiable(imageFiles: mainCategoryIds[0].items[targetSubCategoryIndex].images, subFolderMode: mainCategoryIds[0].subFolderMode, mainCategoryName: mainCategoryIds[0].mainCategory, subCategoryName: mainCategoryIds[0].items[targetSubCategoryIndex].subCategory))
                                                        }
                                                }
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - (CGFloat(5) - 1) * 10) / CGFloat(5) + 10 : (UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3) + 10)
                        
                    }
                    Spacer()
                }
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - (CGFloat(5) - 1) * 10) / CGFloat(5) + 10 : (UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3) + 10)

                if mainCategoryIds.count >= 2 {
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            /*
                            HStack(spacing: 0) {
                                Text(mainCategoryIds[targetMainCategoryIndex].mainCategory + ":")
                                Spacer()
                            }
                            .frame(height: 50)
                             */
                            ForEach(mainCategoryIds[targetMainCategoryIndex].items) { subCategoryId in
                                HStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(subCategoryId.subCategory)
                                            .foregroundColor(.blue)
                                            .onLongPressGesture {
                                                isEditSubCategory = true
                                                targetSubCategoryIndex2 = subCategoryId.id
                                            }
                                        Spacer()
                                        HStack(spacing: 0) {
                                            Spacer()
                                            Image(systemName: subCategoryId.subCategory.first == "*" ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(.blue)
                                                .onTapGesture {
                                                    targetSubCategoryIndex3 = subCategoryId.id
                                                    let initialValue = mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex3].subCategory
                                                    let startIdx = initialValue.index(initialValue.startIndex, offsetBy: 1, limitedBy: initialValue.endIndex) ?? initialValue.endIndex
                                                    if subCategoryId.subCategory.first == "*" {
                                                        mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex3].subCategory = String(initialValue[startIdx...])
                                                    } else {
                                                        mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex3].subCategory = "*" + initialValue
                                                    }
                                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - (CGFloat(5) - 1) * 10) / CGFloat(5) + 10 : (UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3) + 10)
                                .background((subCategoryId.id) % 2 == 0 ? Color(UIColor.systemGray5) : Color(UIColor.systemGray3))
                            }
                            .alert("", isPresented: $isEditSubCategory, actions: {
                                if targetSubCategoryIndex2 != -1 {
                                    let initialValue = mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex2].subCategory
                                    TextField("SubCategory", text: $mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex2].subCategory)
                                    Button("Edit", action: {ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)})
                                    Button("Cancel", role: .cancel, action: {mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex2].subCategory = initialValue})
                                }
                            }, message: {
                           
                            })
                            Spacer()
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
        }
    }
}
