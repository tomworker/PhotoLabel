//
//  CheckBoxMatrixView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/08/18.
//

import SwiftUI

struct CheckBoxMatrixView: View {
    @Binding var showCheckBoxMatrix: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var fileUrl: URL
    @State var targetSubCategoryIndex = -1
    @State var targetImageFileIndex = -1
    @State var showImageView = false
    @State var showCheckBoxEdit = false
    @State var originx = CGFloat.zero
    @State var initialOriginx = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - (CGFloat(5) - CGFloat(1)) * CGFloat(10)) / CGFloat(5) + CGFloat(10) : (UIScreen.main.bounds.width - (CGFloat(3) - CGFloat(1)) * CGFloat(10)) / CGFloat(3) + CGFloat(10))
    @State var selectedIndex = -1
    var columns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3)), spacing: 5), count: 1)
    var columns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(5) - 1) * 10) / CGFloat(5)), spacing: 5), count: 1)

    var body: some View {
        ZStack {
            Text("CheckBox Matrix")
                .bold()
            HStack {
                Spacer()
                Button {
                    showCheckBoxMatrix = false
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
        if mainCategoryIds.count > 0 {
            HStack(spacing: 0) {
                ZStack {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(1..<mainCategoryIds.count, id: \.self) { index in
                                VStack(spacing: 0) {
                                    Image(systemName: selectedIndex == index ? "checkmark.circle.fill" : "circle")
                                        .frame(height: 40)
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            if selectedIndex == index {
                                                selectedIndex = -1
                                            } else {
                                                selectedIndex = index
                                            }
                                        }
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            Text(mainCategoryIds[index].mainCategory + ":")
                                            Spacer()
                                        }
                                        .frame(height: 50)
                                    }
                                    .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth))
                                    .background(index % 2 == 0 ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
                                }
                            }
                        }
                        .offset(x: originx)
                    }
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            VStack(spacing: 0) {
                                Button {
                                    if selectedIndex == -1 {
                                    } else {
                                        showCheckBoxEdit = true
                                    }
                                } label: {
                                    Text("Edit")
                                        .frame(width: 80, height: 30)
                                        .background(.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .fullScreenCover(isPresented: $showCheckBoxEdit) {
                                    CheckBoxEditView(showCheckBoxEdit: $showCheckBoxEdit, mainCategoryIds: $mainCategoryIds, fileUrl: $fileUrl, targetMainCategoryIndex: selectedIndex)
                                }
                            }
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - (CGFloat(5) - 1) * 10) / CGFloat(5) + 10 : (UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3) + 10)
                            .background(Color(UIColor.systemBackground))
                            Spacer()
                        }
                        .frame(height: 40)
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
                }
                .frame(height: 90)
                Spacer()
            }
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        /*
                         HStack(spacing: 0) {
                         Text(mainCategoryIds[0].mainCategory + ":")
                         .frame(height:50)
                         Spacer()
                         }
                         */
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
                        ScrollView(.horizontal) {
                            HStack(spacing: 0) {
                                ForEach(1..<mainCategoryIds.count, id: \.self) { index in
                                    VStack(spacing: 0) {
                                        /*
                                         HStack(spacing: 0) {
                                         Text(mainCategoryIds[index].mainCategory + ":")
                                         Spacer()
                                         }
                                         .frame(height: 50)
                                         */
                                        ForEach(mainCategoryIds[index].items) { subCategoryId in
                                            HStack(spacing: 0) {
                                                VStack(alignment: .leading, spacing: 0) {
                                                    Text(subCategoryId.subCategory)
                                                    Spacer()
                                                    HStack(spacing: 0) {
                                                        Spacer()
                                                        Image(systemName: subCategoryId.subCategory.first == "*" ? "checkmark.circle.fill" : "circle")
                                                        Spacer()
                                                    }
                                                    Spacer()
                                                }
                                                Spacer()
                                            }
                                            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - (CGFloat(5) - 1) * 10) / CGFloat(5) + 10 : (UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3) + 10)
                                            .background((index + subCategoryId.id) % 2 == 0 ? Color(UIColor.systemGray5) : Color(UIColor.systemGray3))
                                        }
                                        Spacer()
                                    }
                                    .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth))
                                }
                                Spacer()
                            }
                            .background(GeometryReader { proxy -> Color in DispatchQueue.main.async {
                                originx = proxy.frame(in: .global).origin.x
                            }
                                return Color.clear
                            })
                        }
                    }
                    Spacer()
                }
            }
            
        }
        Spacer()
    }
}
 
