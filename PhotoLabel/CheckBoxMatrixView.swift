//
//  CheckBoxMatrixView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/08/18.
//

import SwiftUI

struct CheckBoxMatrixView: View {
    @StateObject var photoCapture: PhotoCapture
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @Binding var plistCategoryName: String
    @Binding var showCheckBoxMatrix: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var fileUrl: URL
    @State var targetMainCategoryIndex = -1
    @State var targetSubCategoryIndex = -1
    @State var targetSubCategoryIndex2 = -1
    @State var targetSubCategoryIndex3 = -1
    @State var targetSubCategoryIndex4: [Int] = [-1, -1]
    @State var targetImageFileIndex = 0
    @State var isEditSubCategory = false
    @State var showImageView = false
    @State var showImageStocker = false
    @State var isShowMode = false
    @State var isToggleCheckBox = false
    @State var selectedIndex: [Int] = []
    @State var noSelectedIndex: [Int] = []
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let initialOriginx = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5) + CGFloat(10) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3) + CGFloat(10))
    let imageWidth = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3))
    let imageHeight = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) * CGFloat(0.15) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(4))
    let columns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3)), spacing: 5), count: 1)
    let columns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5)), spacing: 5), count: 1)
    let lowerLoadLimit = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 5
    let upperLoadLimit = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8
    //var columns3 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(3) - 1) * 10) / CGFloat(3)), spacing: 5), count: 2)
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var originy = 150.0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 0) {
                    Text("CheckBox Matrix")
                        .bold()
                    HStack(spacing: 0) {
                        Spacer()
                        Text("Show Mode ")
                            .foregroundColor(isShowMode ? .white: .white.opacity(0.4))
                            .bold()
                            .padding(.trailing)
                        Text("Edit Mode ")
                            .foregroundColor(isShowMode ? .white.opacity(0.4) : .white)
                            .bold()
                        Spacer()
                    }
                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                HStack(spacing: 0) {
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
            .frame(height: 50)
            .onAppear {
                for i in 1..<mainCategoryIds.count {
                    noSelectedIndex.append(i)
                }
            }
            if mainCategoryIds.count > 0 {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Button {
                            isShowMode.toggle()
                        } label: {
                            Text("Chg. Mode")
                                .frame(width: 110, height: 30)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        HStack(spacing: 0) {
                            Text(mainCategoryIds[0].mainCategory)
                                .frame(height:50)
                            Spacer()
                        }
                        .frame(height: 50)
                    }
                    .frame(width: initialOriginx)
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            if selectedIndex.count >= 1 {
                                ForEach(0..<selectedIndex.count, id: \.self) { index in
                                    VStack(spacing: 0) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .frame(height: 30)
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                noSelectedIndex.append(selectedIndex[index])
                                                selectedIndex.remove(at: index)
                                            }
                                        VStack(spacing: 0) {
                                            Text(mainCategoryIds[selectedIndex[index]].mainCategory)
                                        }
                                        .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth), height: 50)
                                        .background(index % 2 == 0 ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
                                    }
                                }
                                VStack(spacing:0) {
                                }
                                .frame(width: 5)
                            }
                            if noSelectedIndex.count >= 1 {
                                ScrollView(.horizontal) {
                                    HStack(spacing: 0) {
                                        ForEach(0..<noSelectedIndex.count, id: \.self) { index in
                                            VStack(spacing: 0) {
                                                Image(systemName: "circle")
                                                    .frame(height: 30)
                                                    .foregroundColor(.blue)
                                                    .onTapGesture {
                                                        selectedIndex.append(noSelectedIndex[index])
                                                        noSelectedIndex.remove(at: index)
                                                    }
                                                VStack(spacing: 0) {
                                                    HStack(spacing: 0) {
                                                        Text(mainCategoryIds[noSelectedIndex[index]].mainCategory)
                                                    }
                                                    .frame(height: 50)
                                                }
                                                .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth))
                                                .background((selectedIndex.count + index) % 2 == 0 ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .frame(height: 80)
                ScrollView {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(mainCategoryIds[0].items) { subCategoryId in
                                HStack(alignment: .top, spacing: 0) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(subCategoryId.subCategory)
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
                                                self.targetSubCategoryIndex = subCategoryId.id
                                                self.targetSubCategoryIndex4 = [0, self.targetSubCategoryIndex]
                                            }
                                        } else {
                                            ScrollView {
                                            //LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1) {
                                            //ForEach(CategoryManager.convertIdentifiable(imageFiles: subCategoryId.images, subFolderMode: mainCategoryIds[0].subFolderMode, mainCategoryName: mainCategoryIds[0].mainCategory, subCategoryName: subCategoryId.subCategory)) { imageFileId in
                                            //if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                            if let uiimage = UIImage(contentsOfFile: tempDirectoryUrl.path + "/" + subCategoryId.images[0].imageFile) {
                                                if originy > CGFloat(150) - (CGFloat(subCategoryId.id + lowerLoadLimit) * initialOriginx) && originy < CGFloat(150) - (CGFloat(subCategoryId.id - upperLoadLimit) * initialOriginx) {
                                                    Image(uiImage: ImageManager.downSize(uiimage: uiimage, scale: 0.1))
                                                    .resizable()
                                                    .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                                    .frame(width: uiimage.size.width > uiimage.size.height ? imageWidth : imageHeight)
                                                    .cornerRadius(10)
                                                    //Recovery code for onTapGesture problem
                                                    .onChange(of: showImageView) { newValue in }
                                                    //Above code goes well for some reason.
                                                    .onTapGesture(count: 1) {
                                                    showImageView = true
                                                    self.targetSubCategoryIndex = subCategoryId.id
                                                    //self.targetImageFileIndex = imageFileId.id
                                                    }
                                                    .onLongPressGesture {
                                                    showImageStocker = true
                                                    self.targetSubCategoryIndex = subCategoryId.id
                                                    self.targetSubCategoryIndex4 = [0, self.targetSubCategoryIndex]
                                                    }
                                                    .fullScreenCover(isPresented: $showImageView) {
                                                        ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView, targetImageFileIndex: self.targetImageFileIndex, imageFileIds: CategoryManager.convertIdentifiable(imageFiles: mainCategoryIds[0].items[targetSubCategoryIndex].images, subFolderMode: mainCategoryIds[0].subFolderMode, mainCategoryName: mainCategoryIds[0].mainCategory, subCategoryName: mainCategoryIds[0].items[targetSubCategoryIndex].subCategory))
                                                    }
                                                    .fullScreenCover(isPresented: $showImageStocker) {
                                                        ImageStockerTabView(photoCapture: photoCapture, showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex4)
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
                                            //}
                                            //}
                                            }
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .frame(height: initialOriginx)
                            }
                            Spacer()
                        }
                        .frame(width: initialOriginx)
                        if mainCategoryIds.count >= 2 {
                            HStack(spacing: 0) {
                                if selectedIndex.count >= 1 {
                                    HStack(spacing: 0) {
                                        ForEach(0..<selectedIndex.count, id: \.self) { index in
                                            VStack(spacing: 0) {
                                                ForEach(mainCategoryIds[selectedIndex[index]].items) { subCategoryId in
                                                    HStack(spacing: 0) {
                                                        VStack(alignment: .leading, spacing: 0) {
                                                            if isShowMode || index != 0 {
                                                                Text(subCategoryId.subCategory)
                                                            } else {
                                                                Text(subCategoryId.subCategory)
                                                                    .foregroundColor(.blue)
                                                                    .onLongPressGesture {
                                                                        isEditSubCategory = true
                                                                        targetMainCategoryIndex = selectedIndex[index]
                                                                        targetSubCategoryIndex2 = subCategoryId.id
                                                                    }
                                                            }
                                                            Spacer()
                                                            HStack(spacing: 0) {
                                                                Spacer()
                                                                ZStack {
                                                                    if isShowMode || index != 0 {
                                                                        Image(systemName: subCategoryId.subCategory.first == "*" ? "checkmark.circle.fill" : "circle")
                                                                            .offset(x: 4)
                                                                    } else {
                                                                        Image(systemName: subCategoryId.subCategory.first == "*" ? "checkmark.circle.fill" : "circle")
                                                                            .foregroundColor(.blue)
                                                                            .offset(x: 4)
                                                                        Circle()
                                                                            .foregroundColor(.gray.opacity(0.1))
                                                                            .frame(width: 35, height: 35)
                                                                            .offset(x: 4)
                                                                            .onTapGesture {
                                                                                isToggleCheckBox = true
                                                                                toggleCheckBox(mainCategoryIndex: selectedIndex[index], subCategoryIndex: subCategoryId.id, subCategory: subCategoryId.subCategory)
                                                                            }
                                                                    }
                                                                }
                                                                Spacer()
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
                                                    .frame(height: initialOriginx)
                                                    .background((index + subCategoryId.id) % 2 == 0 ? Color(UIColor.systemGray5) : Color(UIColor.systemGray3))
                                                }
                                                Spacer()
                                            }
                                            .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth))
                                        }
                                        Spacer()
                                    }
                                }
                            }
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
    }
    private func toggleCheckBox(mainCategoryIndex: Int, subCategoryIndex: Int, subCategory: String) {
        autoreleasepool {
            targetSubCategoryIndex3 = subCategoryIndex
            let initialValue = mainCategoryIds[mainCategoryIndex].items[targetSubCategoryIndex3].subCategory
            let startIdx = initialValue.index(initialValue.startIndex, offsetBy: 1, limitedBy: initialValue.endIndex) ?? initialValue.endIndex
            if subCategory.first == "*" {
                mainCategoryIds[mainCategoryIndex].items[targetSubCategoryIndex3].subCategory = String(initialValue[startIdx...])
            } else {
                mainCategoryIds[mainCategoryIndex].items[targetSubCategoryIndex3].subCategory = "*" + initialValue
            }
            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
        }
    }
}
