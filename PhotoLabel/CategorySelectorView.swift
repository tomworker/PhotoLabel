//
//  CategorySelectorView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct CategorySelectorView: View {
    @StateObject var photoCapture: PhotoCapture
    @Binding var showCategorySelector: Bool
    @State var mainCategoryIds: [MainCategoryId]
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @State var fileUrl: URL
    @State var plistCategoryName: String
    @State var showPhotoCapture = false
    @State var showPhotoLibrary = false
    @State var showImageStocker = false
    @State var showSubCategory = false
    @State var showCheckBox = false
    @State var showCheckBoxMatrix = false
    @State var showFinalReport = false
    @State var moveToTrashBox = false
    @State var targetMainCategoryIndex = -1
    @State var targetSubCategoryId = SubCategoryId(id: 0, subCategory: "", countStoredImages: 0, images: [ImageFile(imageFile: "")], isTargeted: false)
    @State var targetSubCategoryIndex: [Int] = [-1, -1]
    @State var targetImageFile = ""
    @State var showImageView = false
    @State var isDuplicateMode = false
    @State var isMainScrollViewEnabled = false
    @State var isSubScrollViewEnabled = false
    var columns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber)), spacing: 5), count: ConfigManager.imageColumnNumber)
    var columns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber)), spacing: 5), count: ConfigManager.iPadImageColumnNumber)
    @State var mainScrollColumns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.mainColumnNumber) - 1) * 5) / CGFloat(ConfigManager.mainColumnNumber)), spacing: 5), count: ConfigManager.mainColumnNumber)
    @State var mainScrollColumns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadMainColumnNumber) - 1) * 5) / CGFloat(ConfigManager.iPadMainColumnNumber)), spacing: 5), count: ConfigManager.iPadMainColumnNumber)
    @State var subScrollColumns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.subColumnNumber) - 1) * 5) / CGFloat(ConfigManager.subColumnNumber)), spacing: 5), count: ConfigManager.subColumnNumber)
    @State var subScrollColumns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadSubColumnNumber) - 1) * 5) / CGFloat(ConfigManager.iPadSubColumnNumber)), spacing: 5), count: ConfigManager.iPadSubColumnNumber)
    @State var isTargeted = false
    @State var isTargetedIndex = -1
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

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
                            showCheckBox = true
                        } label: {
                            HStack {
                                Text("CheckSheet")
                            }
                            .frame(width: 120, height: 30)
                            .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .fullScreenCover(isPresented: $showCheckBox) {
                            CheckBoxView(photoCapture: photoCapture, workSpace: $workSpace, duplicateSpace: $duplicateSpace, plistCategoryName: $plistCategoryName, mainCategoryIds: $mainCategoryIds, fileUrl: $fileUrl, targetMainCategoryIndex: $targetMainCategoryIndex, showCheckBox: $showCheckBox)
                        }
                        Button {
                            showFinalReport = true
                        } label: {
                            HStack {
                                Text("Final Report")
                            }
                            .frame(width: 120, height: 30)
                            .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.trailing)
                        }
                        .fullScreenCover(isPresented: $showFinalReport) {
                            FinalReportView(fileUrl: $fileUrl, showFinalReport: $showFinalReport, mainCategoryIds: $mainCategoryIds)
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
                        if let range = mainCategoryIds[targetMainCategoryIndex].mainCategory.range(of: ":=") {
                            let idx = mainCategoryIds[targetMainCategoryIndex].mainCategory.index(range.lowerBound, offsetBy: -1)
                            Text("Category: " + mainCategoryIds[targetMainCategoryIndex].mainCategory[...idx])
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(.white)
                        }
                    }
                }
                .onAppear {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        if mainCategoryIds.count > ConfigManager.iPadMainColumnNumber * ConfigManager.iPadMainRowNumber {
                            isMainScrollViewEnabled = true
                            mainScrollColumns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadMainColumnNumber) - 1) * 5) * 2 / (CGFloat(ConfigManager.iPadMainColumnNumber) * 2 - 1)), spacing: 5), count: mainCategoryIds.count % ConfigManager.iPadMainRowNumber == 0 ? mainCategoryIds.count / ConfigManager.iPadMainRowNumber : (mainCategoryIds.count - (mainCategoryIds.count % ConfigManager.iPadMainRowNumber)) / ConfigManager.iPadMainRowNumber + 1)
                        }
                    } else {
                        if mainCategoryIds.count > ConfigManager.mainColumnNumber * ConfigManager.mainRowNumber {
                            isMainScrollViewEnabled = true
                            mainScrollColumns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.mainColumnNumber) - 1) * 5) * 2 / (CGFloat(ConfigManager.mainColumnNumber) * 2 - 1)), spacing: 5), count: mainCategoryIds.count % ConfigManager.mainRowNumber == 0 ? mainCategoryIds.count / ConfigManager.mainRowNumber : (mainCategoryIds.count - (mainCategoryIds.count % ConfigManager.mainRowNumber)) / ConfigManager.mainRowNumber + 1)
                        }
                    }
                }
                ZStack {
                    HStack {
                        Image(systemName: "hand.point.right")
                        Text("Select Category")
                    }
                    if isMainScrollViewEnabled {
                        HStack {
                            Spacer()
                            Text("scroll")
                            Text(">")
                        }
                    }
                }
                VStack {
                    ScrollView(.horizontal) {
                        LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? mainScrollColumns2 : mainScrollColumns1, spacing: 5) {
                            ForEach(mainCategoryIds) { mainCategoryId in
                                Button {
                                    showSubCategory = true
                                    targetMainCategoryIndex = mainCategoryId.id
                                    targetSubCategoryIndex[1] = -1
                                    if UIDevice.current.userInterfaceIdiom == .pad {
                                        if mainCategoryIds[targetMainCategoryIndex].items.count > ConfigManager.iPadSubColumnNumber * ConfigManager.iPadSubRowNumber {
                                            isSubScrollViewEnabled = true
                                            subScrollColumns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadSubColumnNumber) - 1) * 5) * 2 / ((CGFloat(ConfigManager.iPadSubColumnNumber) + 1) * 2 - 1)), spacing: 5), count: mainCategoryIds[targetMainCategoryIndex].items.count % ConfigManager.iPadSubRowNumber == 0 ? mainCategoryIds[targetMainCategoryIndex].items.count / ConfigManager.iPadSubRowNumber : (mainCategoryIds[targetMainCategoryIndex].items.count - (mainCategoryIds[targetMainCategoryIndex].items.count % ConfigManager.iPadSubRowNumber)) / ConfigManager.iPadSubRowNumber + 1)
                                        } else {
                                            isSubScrollViewEnabled = false
                                            subScrollColumns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadSubColumnNumber) - 1) * 5) / CGFloat(ConfigManager.iPadSubColumnNumber)), spacing: 5), count: ConfigManager.iPadSubColumnNumber)
                                        }
                                    } else {
                                        if mainCategoryIds[targetMainCategoryIndex].items.count > ConfigManager.subColumnNumber * ConfigManager.subRowNumber {
                                            isSubScrollViewEnabled = true
                                            subScrollColumns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.subColumnNumber) - 1) * 5) * 2 / ((CGFloat(ConfigManager.subColumnNumber) + 1) * 2 - 1)), spacing: 5), count: mainCategoryIds[targetMainCategoryIndex].items.count % ConfigManager.subRowNumber == 0 ? mainCategoryIds[targetMainCategoryIndex].items.count / ConfigManager.subRowNumber : (mainCategoryIds[targetMainCategoryIndex].items.count - (mainCategoryIds[targetMainCategoryIndex].items.count % ConfigManager.subRowNumber)) / ConfigManager.subRowNumber + 1)
                                        } else {
                                            isSubScrollViewEnabled = false
                                            subScrollColumns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.subColumnNumber) - 1) * 5) / CGFloat(ConfigManager.subColumnNumber)), spacing: 5), count: ConfigManager.subColumnNumber)
                                        }
                                    }
                                } label: {
                                    if let range = mainCategoryId.mainCategory.range(of: ":=") {
                                        let idx = mainCategoryId.mainCategory.index(range.lowerBound, offsetBy: -1)
                                        Text(mainCategoryId.mainCategory[...idx])
                                            .frame(maxWidth: .infinity, minHeight: 50)
                                            .background(mainCategoryId.id == targetMainCategoryIndex ? LinearGradient(gradient: Gradient(colors: [.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                }
                VStack(spacing: 5) {
                    if showSubCategory {
                        ZStack {
                            HStack {
                                Image(systemName: "hand.point.right")
                                Text("Select Details")
                            }
                            if isSubScrollViewEnabled {
                                HStack {
                                    Spacer()
                                    Text("scroll")
                                    Text(">")
                                }
                            }
                        }
                        ScrollView(.horizontal) {
                            HStack(alignment: .top) {
                                LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? subScrollColumns2 : subScrollColumns1, spacing: 5) {
                                    ForEach(mainCategoryIds[targetMainCategoryIndex].items) { subCategoryId in
                                        Button {
                                            showImageStocker = true
                                            targetSubCategoryId = subCategoryId
                                            targetSubCategoryIndex[0] = targetMainCategoryIndex
                                            targetSubCategoryIndex[1] = subCategoryId.id
                                        } label: {
                                            if let range = subCategoryId.subCategory.range(of: ":=") {
                                                let idx = subCategoryId.subCategory.index(range.lowerBound, offsetBy: -1)
                                                Text(subCategoryId.subCategory[...idx] + "\n(\(subCategoryId.countStoredImages))")
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
                                                            if let originalImage = UIImage(contentsOfFile: duplicateSpace[Int(indexs1.first!)!].subFolderMode == 1 ? tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[Int(indexs1.first!)!].mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: duplicateSpace[Int(indexs1.first!)!].subCategoryName)).appendingPathComponent(indexs2.first!).path : tempDirectoryUrl.appendingPathComponent(indexs2.first!).path) {
                                                                let dateFormatter = DateFormatter()
                                                                dateFormatter.dateFormat = "yyyyMMddHHmmssS"
                                                                let jpgImageData = originalImage.jpegData(compressionQuality: 0.5)
                                                                let duplicateSpaceImageFileName = "\(dateFormatter.string(from: Date())).jpg"
                                                                var duplicateSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(duplicateSpaceImageFileName)
                                                                if mainCategoryIds[targetMainCategoryIndex].subFolderMode == 1 {
                                                                    duplicateSpaceJpgUrl = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[targetMainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].subCategory)).appendingPathComponent(duplicateSpaceImageFileName)
                                                                    ZipManager.create(directoryUrl: tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[targetMainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].subCategory)))
                                                                }
                                                                do {
                                                                    try jpgImageData!.write(to: duplicateSpaceJpgUrl, options: .atomic)
                                                                    duplicateSpace.insert(DuplicateImageFile(imageFile: duplicateSpaceImageFileName, subFolderMode: mainCategoryIds[targetMainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[targetMainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].subCategory) , at: duplicateSpace.count)
                                                                    ZipManager.moveImagesFromDuplicateSpaceToPlist(imageFile: duplicateSpaceImageFileName, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: targetMainCategoryIndex, subCategoryIndex: subCategoryId.id)
                                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                                } catch {
                                                                    print("Writing Jpg file failed with error:\(error)")
                                                                }
                                                            }
                                                        } else if indexs3.first! == "1" {
                                                            var duplicateSpaceImageFileName = URL(string: indexs2.first!)!.lastPathComponent
                                                            duplicateSpaceImageFileName = duplicateSpaceImageFileName.replacingOccurrences(of: "@", with: "")
                                                            duplicateSpace.insert(DuplicateImageFile(imageFile: duplicateSpaceImageFileName, subFolderMode: mainCategoryIds[targetMainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[targetMainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].subCategory) , at: duplicateSpace.count)
                                                            ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: targetMainCategoryIndex, subCategoryIndex: subCategoryId.id, workSpace: &workSpace)
                                                            ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                        }
                                                        return true
                                                    } isTargeted: { isTargeted in
                                                        mainCategoryIds[targetMainCategoryIndex].items[subCategoryId.id].isTargeted = isTargeted
                                                    }
                                            }
                                        }
                                        .fullScreenCover(isPresented: $showImageStocker) {
                                            ImageStockerTabView(photoCapture: photoCapture, showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex)
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
