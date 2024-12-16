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
    @Binding var downSizeImages: [[[UIImage]]]
    @State var mainCategoryArray: [String] = [""]
    @State var mainCategoryArray2: [[String]] = [["","",""]]
    @State var subCategory = ""
    @State var subCategory2: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: ConfigManager.maxNumberOfSubCategory)
    @State var subCategory3: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: ConfigManager.maxNumberOfSubCategory)
    @State var subCategory4: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: ConfigManager.maxNumberOfSubCategory)
    @State var targetSubCategoryIndex: [Int] = [-1, -1]
    @State var targetCheckInfoIndex = 0
    @State var targetImageFileIndex = 0
    @State var showImageView = false
    @State var showImageView3 = false
    @State var showImageStocker = false
    @State var isEditCheckItem: [Bool] = Array(repeating: false, count: 3)
    @State var isEditCheckInfo: [Bool] = Array(repeating: false, count: ConfigManager.maxNumberOfSubCategory)
    @State var isClear = false
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let initialOriginx = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5) + CGFloat(10) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3) + CGFloat(10))
    let imageWidth = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3))
    let imageHeight = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) * CGFloat(0.15) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(4))
    let lowerLoadLimit = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 6
    let upperLoadLimit = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8
    @State var originy = 150.0
    @State var originy2: [Double] = Array(repeating: 150.0, count: ConfigManager.maxNumberOfMainCategory)
    @State var countImageHeight = 0
    @State var countImageHeight2: [Int] = Array(repeating: 0, count: ConfigManager.maxNumberOfMainCategory)
    let correctionValue = UIDevice.current.userInterfaceIdiom == .pad ? pow(((UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) * CGFloat(0.15) + 25), 1.92) / pow(10, 2) - 75.2 : pow(((UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(4) + 25), 1.9) / pow(10, 2) - 64.9
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 0) {
                    Text(plistCategoryName.replacingOccurrences(of: "_", with: " / "))
                        .bold()
                }
                HStack(spacing: 0) {
                    Button {
                        isClear = true
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
                .alert(isPresented: $isClear) {
                    Alert(title: Text("Clear all checks & remarks?"),
                          primaryButton: .cancel(Text("Cancel")),
                          secondaryButton: .destructive(Text("All Clear"), action: {
                        clearCheckBox()
                    }))
                }
            }
            .frame(height: 50)
            .onAppear() {
                if originy2.count != mainCategoryIds.count {
                    originy2 = Array(repeating: 150.0, count: mainCategoryIds.count)
                    countImageHeight2 = Array(repeating: 0, count: mainCategoryIds.count)
                }
                if targetMainCategoryIndex == -1 {
                    targetMainCategoryIndex = 0
                }
                var array: [[String]] = Array(repeating: ["", ""], count: mainCategoryIds.count)
                mainCategoryArray = Array(repeating: "", count: mainCategoryIds.count)
                mainCategoryArray2 = Array(repeating: ["", "", ""], count: mainCategoryIds.count)
                for i in mainCategoryIds.indices {
                    if let range = mainCategoryIds[i].mainCategory.range(of: ":=") {
                        let idx = mainCategoryIds[i].mainCategory.index(range.lowerBound, offsetBy: -1)
                        let idx2 = mainCategoryIds[i].mainCategory.index(range.lowerBound, offsetBy: 2)
                        array[i][0] = String(mainCategoryIds[i].mainCategory[...idx])
                        array[i][1] = String(mainCategoryIds[i].mainCategory[idx2...])
                    } else {
                        array[i][0] = mainCategoryIds[i].mainCategory
                        array[i][1] = ",,"
                    }
                    mainCategoryArray[i] = array[i][0]
                    mainCategoryArray2[i] = array[i][1].components(separatedBy: ",")
                }
            }
            ScrollViewReader { scrollView in
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(mainCategoryArray.indices, id: \.self) { mainIndex in
                            Button {
                                withAnimation {
                                    scrollView.scrollTo(mainIndex + 1000, anchor: .center)
                                }
                                originy2[mainIndex] = 150.0
                                countImageHeight2[mainIndex] = 0
                                if mainIndex >= 1 {
                                    countImageHeight2[mainIndex - 1] = mainCategoryIds[mainIndex - 1].items.count * 2
                                }
                            } label: {
                                HStack(spacing: 0) {
                                    Text(" \(mainCategoryArray[mainIndex]) > ")
                                }
                                .frame(height: 30)
                                .border(.blue)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                    }
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? initialOriginx * 2.4 : initialOriginx * 1.4, height: 20)
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(mainCategoryArray2[0].indices, id: \.self) { index in
                                Text(mainCategoryArray2[0][index] == "" ? "CHK" + String(index + 1) : mainCategoryArray2[0][index])
                                    .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth))
                                    .background(index % 2 == 0 ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
                                    .onLongPressGesture {
                                        isEditCheckItem[index] = true
                                        var array: [String] = ["", ""]
                                        if let range = mainCategoryIds[0].mainCategory.range(of: ":=") {
                                            let idx = mainCategoryIds[0].mainCategory.index(range.lowerBound, offsetBy: -1)
                                            let idx2 = mainCategoryIds[0].mainCategory.index(range.lowerBound, offsetBy: 2)
                                            array[0] = String(mainCategoryIds[0].mainCategory[...idx])
                                            array[1] = String(mainCategoryIds[0].mainCategory[idx2...])
                                        } else {
                                            array[0] = mainCategoryIds[0].mainCategory
                                            array[1] = ",,"
                                        }
                                        mainCategoryArray[0] = array[0]
                                        mainCategoryArray2[0] = array[1].components(separatedBy: ",")
                                    }
                                    .alert("", isPresented: $isEditCheckItem[index], actions: {
                                        let initialValue = mainCategoryArray2[0][index]
                                        TextField("CheckItem", text: $mainCategoryArray2[0][index])
                                        Button("Edit", action: {
                                            mainCategoryIds[0].mainCategory = mainCategoryArray[0] + ":=" + mainCategoryArray2[0][0] + "," + mainCategoryArray2[0][1] + "," + mainCategoryArray2[0][2]
                                            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                        })
                                        Button("Cancel", role: .cancel, action: {mainCategoryArray2[0][index] = initialValue})
                                    }, message: {
                                        
                                    })
                            }
                        }
                    }
                    Spacer()
                }
                ScrollView {
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(mainCategoryIds.indices, id: \.self) { mainIndex in
                                HStack(spacing: 0) {
                                    if let range = mainCategoryIds[mainIndex].mainCategory.range(of: ":=") {
                                        let idx = mainCategoryIds[mainIndex].mainCategory.index(range.lowerBound, offsetBy: -1)
                                        Text(mainCategoryIds[mainIndex].mainCategory[...idx])
                                    }
                                    Spacer()
                                }
                                .id(mainIndex + 1000)
                                .background(GeometryReader { proxy -> Color in
                                    DispatchQueue.main.async {
                                        let positiony = proxy.frame(in: .named("")).origin.y
                                        updateCountImageHiehgt2(imageHeight: imageHeight, mainIndex: mainIndex, positiony: positiony)
                                        updateOriginy2(imageHeight: imageHeight, mainIndex: mainIndex)
                                    }
                                    return Color.clear
                                })
                                ForEach(mainCategoryIds[mainIndex].items) { subCategoryId in
                                    if originy2[mainIndex] >= CGFloat(150) - (CGFloat(subCategoryId.id + lowerLoadLimit) * (imageHeight + 25)) && originy2[mainIndex] <= CGFloat(150) - (CGFloat(subCategoryId.id - upperLoadLimit) * (imageHeight + 25)) {
                                        HStack(alignment: .top, spacing: 0) {
                                            VStack(alignment: .center, spacing: 0) {
                                                HStack(spacing: 0) {
                                                    if let range = subCategoryId.subCategory.range(of: ":=") {
                                                        let idx = subCategoryId.subCategory.index(range.lowerBound, offsetBy: -1)
                                                        Text(subCategoryId.subCategory[...idx])
                                                    }
                                                    Spacer()
                                                }
                                                .background(targetSubCategoryIndex[0] == mainIndex && targetSubCategoryIndex[1] == subCategoryId.id ? Color(.cyan) : (subCategoryId.id) % 2 == 0 ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
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
                                                            //Recovery code for onLongPressGesture problem
                                                            .onChange(of: showImageStocker) { }
                                                            //Above code goes well for some reason.
                                                            .onTapGesture { }
                                                            .onLongPressGesture {
                                                                showImageStocker = true
                                                                targetSubCategoryIndex = [mainIndex, subCategoryId.id]
                                                            }
                                                        } else {
                                                            ForEach(subCategoryId.images.indices, id: \.self) { index in
                                                                if let uiimage = UIImage(contentsOfFile: tempDirectoryUrl.path + "/" + subCategoryId.images[index].imageFile) {
                                                                    Image(uiImage: downSizeImages[mainIndex][subCategoryId.id][index])
                                                                        .resizable()
                                                                        .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                                                        .frame(width: uiimage.size.width > uiimage.size.height ? imageWidth : imageHeight, height: imageHeight)
                                                                        .cornerRadius(10)
                                                                    //Recovery code for onTapGesture problem
                                                                        .onChange(of: showImageView) { }
                                                                    //Above code goes well for some reason.
                                                                        .onTapGesture(count: 1) {
                                                                            showImageView = true
                                                                            targetSubCategoryIndex = [mainIndex, subCategoryId.id]
                                                                            targetImageFileIndex = index
                                                                        }
                                                                    //Recovery code for onLongPressGesture problem
                                                                        .onChange(of: showImageStocker) { }
                                                                    //Above code goes well for some reason.
                                                                        .onLongPressGesture {
                                                                            showImageStocker = true
                                                                            targetSubCategoryIndex = [mainIndex, subCategoryId.id]
                                                                        }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .fullScreenCover(isPresented: $showImageView) {
                                                        ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView, showImageView3: $showImageView3, targetImageFileIndex: $targetImageFileIndex, images: mainCategoryIds[targetSubCategoryIndex[0]].items[targetSubCategoryIndex[1]].images, mainCategoryIndex: targetSubCategoryIndex[0], subCategoryIndex: $targetSubCategoryIndex[1], downSizeImages: $downSizeImages, mainCategoryIds: $mainCategoryIds)
                                                    }
                                                    .fullScreenCover(isPresented: $showImageView3) {
                                                        VStack { } //dummy
                                                        ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView, showImageView3: $showImageView3, targetImageFileIndex: $targetImageFileIndex, images: mainCategoryIds[targetSubCategoryIndex[0]].items[targetSubCategoryIndex[1]].images, mainCategoryIndex: targetSubCategoryIndex[0], subCategoryIndex: $targetSubCategoryIndex[1], downSizeImages: $downSizeImages, mainCategoryIds: $mainCategoryIds)
                                                    }
                                                    .fullScreenCover(isPresented: $showImageStocker) {
                                                        ImageStockerTabView(photoCapture: _photoCapture, showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex, downSizeImages: $downSizeImages)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? initialOriginx * 2.4 : initialOriginx * 1.4)
                                            ForEach(mainCategoryArray2[0].indices, id: \.self) { index in
                                                VStack(alignment: .leading, spacing: 0) {
                                                    VStack(alignment: .center, spacing: 0) {
                                                        HStack(spacing: 0) {
                                                            Spacer()
                                                            VStack(spacing: 0) {
                                                                if let range = subCategoryId.subCategory.range(of: ":=") {
                                                                    let idx = subCategoryId.subCategory.index(range.lowerBound, offsetBy: 2)
                                                                    let array = subCategoryId.subCategory[idx...].components(separatedBy: ",")
                                                                    let checkInfo = String(array[index][array[index].startIndex])
                                                                    let idx2 = array[index].index(array[index].startIndex,offsetBy: 1)
                                                                    let remarks = String(array[index][idx2...])
                                                                    ZStack {
                                                                        Image(systemName: checkInfo == "*" ? "checkmark.circle.fill" : "circle")
                                                                            .foregroundColor(.blue)
                                                                            .offset(y: 8)
                                                                        Circle()
                                                                            .foregroundColor(.gray.opacity(0.1))
                                                                            .frame(width: 35, height: 35)
                                                                            .offset(y: 8)
                                                                            .onTapGesture {
                                                                                toggleCheckBox(mainCategoryIndex: mainIndex, subCategoryIndex: subCategoryId.id, subCategory: subCategoryId.subCategory, checkInfos: array, index: index)
                                                                            }
                                                                    }
                                                                    .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth), height: 45)
                                                                    VStack(spacing: 0) {
                                                                        if remarks == "" {
                                                                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                                                                .frame(width: 30, height: 30)
                                                                                .background(.black.opacity(0.3))
                                                                                .foregroundColor(.white.opacity(0.3))
                                                                                .cornerRadius(10)
                                                                                .onTapGesture { }
                                                                                .onLongPressGesture {
                                                                                    isEditCheckInfo[subCategoryId.id] = true
                                                                                    let idx3 = subCategoryId.subCategory.index(range.lowerBound, offsetBy: -1)
                                                                                    subCategory = String(subCategoryId.subCategory[...idx3])
                                                                                    subCategory2[subCategoryId.id] = array
                                                                                    for i in 0..<3 {
                                                                                        subCategory3[subCategoryId.id][i] = String(array[i][array[i].startIndex])
                                                                                        let idx4 = array[i].index(array[i].startIndex, offsetBy: 1)
                                                                                        subCategory4[subCategoryId.id][i] = String(array[i][idx4...])
                                                                                    }
                                                                                    targetCheckInfoIndex = index
                                                                                }
                                                                        } else {
                                                                            Text(remarks)
                                                                                .onTapGesture { }
                                                                                .onLongPressGesture {
                                                                                    isEditCheckInfo[subCategoryId.id] = true
                                                                                    let idx3 = subCategoryId.subCategory.index(range.lowerBound, offsetBy: -1)
                                                                                    subCategory = String(subCategoryId.subCategory[...idx3])
                                                                                    subCategory2[subCategoryId.id] = array
                                                                                    for i in 0..<3 {
                                                                                        subCategory3[subCategoryId.id][i] = String(array[i][array[i].startIndex])
                                                                                        let idx4 = array[i].index(array[i].startIndex, offsetBy: 1)
                                                                                        subCategory4[subCategoryId.id][i] = String(array[i][idx4...])
                                                                                    }
                                                                                    targetCheckInfoIndex = index
                                                                                }
                                                                        }
                                                                    }
                                                                    .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth), height: imageHeight - 20)
                                                                    .alert("", isPresented: $isEditCheckInfo[subCategoryId.id], actions: {
                                                                        let initialValue = subCategory2[subCategoryId.id][targetCheckInfoIndex]
                                                                        TextField("Remarks", text: $subCategory4[subCategoryId.id][targetCheckInfoIndex])
                                                                        Button("Edit", action: {
                                                                            subCategory2[subCategoryId.id][targetCheckInfoIndex] = subCategory3[subCategoryId.id][targetCheckInfoIndex] + subCategory4[subCategoryId.id][targetCheckInfoIndex]
                                                                            mainCategoryIds[mainIndex].items[subCategoryId.id].subCategory = subCategory + ":=" + subCategory2[subCategoryId.id][0] + "," + subCategory2[subCategoryId.id][1] + "," + subCategory2[subCategoryId.id][2]
                                                                            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                                        })
                                                                        Button("Cancel", role: .cancel, action: {subCategory2[subCategoryId.id][targetCheckInfoIndex] = initialValue})
                                                                    }, message: {
                                                                        
                                                                    })
                                                                }
                                                            }
                                                            Spacer()
                                                        }
                                                    }
                                                    .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth), height: imageHeight + 25)
                                                }
                                                .frame(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? ConfigManager.iPadCheckBoxMatrixColumnWidth : ConfigManager.checkBoxMatrixColumnWidth))
                                                .background((subCategoryId.id + index) % 2 == 0 ? Color(UIColor.systemGray5) : Color(UIColor.systemGray3))
                                                .offset(y: 2)
                                            }
                                            Spacer()
                                        }
                                        .frame(height: imageHeight + 25)
                                    } else {
                                        Spacer(minLength: 100)
                                    }
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }
        Spacer()
    }
    private func clearCheckBox() {
        autoreleasepool {
            for i in mainCategoryIds.indices {
                for j in mainCategoryIds[i].items.indices {
                    if let range = mainCategoryIds[i].items[j].subCategory.range(of: ":=") {
                        mainCategoryIds[i].items[j].subCategory = mainCategoryIds[i].items[j].subCategory[...range.lowerBound] + "=-,-,-"
                    }
                }
            }
            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
        }
    }
    private func toggleCheckBox(mainCategoryIndex: Int, subCategoryIndex: Int, subCategory: String, checkInfos: [String], index: Int) {
        autoreleasepool {
            if let range = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.range(of: ":=") {
                let idx = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.index(range.lowerBound, offsetBy: -1)
                var array = checkInfos
                var checkInfo = String(checkInfos[index][checkInfos[index].startIndex])
                let idx2 = checkInfos[index].index(checkInfos[index].startIndex, offsetBy: 1)
                let remarks = checkInfos[index][idx2...]
                if checkInfo == "-" {
                    checkInfo = "*"
                } else if checkInfo == "*" {
                    checkInfo = "-"
                }
                array[index] = checkInfo + remarks
                mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory[...idx] + ":=" + array[0] + "," + array[1] + "," + array[2]
            }
            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
        }
    }
    private func updateCountImageHiehgt2(imageHeight: CGFloat, mainIndex: Int, positiony: CGFloat) {
        if -(-95 + (imageHeight + 25) * 0.5 * CGFloat(countImageHeight2[mainIndex]) + positiony) >= (imageHeight + 25) {
            countImageHeight2[mainIndex] += 1
        } else if (-95 + (imageHeight + 25) * 0.5 * CGFloat(countImageHeight2[mainIndex]) + positiony) >= (imageHeight + 25) {
            countImageHeight2[mainIndex] -= 1
        }
    }
    private func updateOriginy2(imageHeight: CGFloat, mainIndex: Int) {
        originy2[mainIndex] = 150 - (imageHeight + 25 + correctionValue) * 0.5 * CGFloat(countImageHeight2[mainIndex])
    }
}
