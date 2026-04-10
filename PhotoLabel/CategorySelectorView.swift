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
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @State var fileUrl: URL
    @State var plistCategoryName: String
    @State var downSizeImages: [[[UIImage]]]
    @Binding var isPresentedProgressView: Bool
    @State var isPresentedProgressView2 = false
    @State var showPhotoCapture = false
    @State var showPhotoLibrary = false
    @State var showImageStocker = false
    @State var showSubCategory = false
    @State var showCheckBox = false
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
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var mainScrollColumns: [GridItem] {
        UIDevice.current.userInterfaceIdiom == .pad ? mainScrollColumns2 : mainScrollColumns1
    }
    private var subScrollColumns: [GridItem] {
        UIDevice.current.userInterfaceIdiom == .pad ? subScrollColumns2 : subScrollColumns1
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                headerView
                titleSection
                mainCategorySection
                if showSubCategory {
                    subCategorySection
                }
            }
        }
        .fullScreenCover(isPresented: $showCheckBox) {
            CheckBoxView(workSpace: $workSpace, duplicateSpace: $duplicateSpace, plistCategoryName: $plistCategoryName, mainCategoryIds: $mainCategoryIds, fileUrl: $fileUrl, targetMainCategoryIndex: $targetMainCategoryIndex, showCheckBox: $showCheckBox, downSizeImages: $downSizeImages)
        }
        .fullScreenCover(isPresented: $showFinalReport) {
            FinalReportView(fileUrl: $fileUrl, showFinalReport: $showFinalReport, plistCategoryName: $plistCategoryName, mainCategoryIds: $mainCategoryIds, downSizeImages: $downSizeImages)
        }
        .fullScreenCover(isPresented: $showImageStocker) {
            ImageStockerTabView(showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex, downSizeImages: $downSizeImages)
        }
    }
}
extension CategorySelectorView {
    private var headerView: some View {
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
                checkSheetButton
                finalReportButton
            }
        }
    }
    private var checkSheetButton: some View {
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
    }
    private var finalReportButton: some View {
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
    }
    private var titleSection: some View {
        VStack {
            Text(plistCategoryName.replacingOccurrences(of: "_", with: " / "))
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.2), .indigo.opacity(0.2), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .foregroundColor(.indigo).bold()
            Text(selectedCategoryTitle)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .foregroundColor(.white)
        }
        .onAppear {
            isPresentedProgressView = false
            updateGridConfiguration()
        }
    }
    private var selectedCategoryTitle: String {
        if targetMainCategoryIndex != -1,
           let range = mainCategoryIds[targetMainCategoryIndex].mainCategory.range(of: ":=") {
            let idx = mainCategoryIds[targetMainCategoryIndex].mainCategory.index(range.lowerBound, offsetBy: -1)
            return "Category: " + mainCategoryIds[targetMainCategoryIndex].mainCategory[...idx]
        }
        return " "
    }
    private func updateGridConfiguration() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let screenWidth = UIScreen.main.bounds.width
        if isPad {
            let colCount = ConfigManager.iPadMainColumnNumber
            let rowCount = ConfigManager.iPadMainRowNumber
            if mainCategoryIds.count > colCount * rowCount {
                isMainScrollViewEnabled = true
                let itemWidth = (screenWidth - (CGFloat(colCount) - 1) * 5) * 2 / (CGFloat(colCount) * 2 - 1)
                let gridCount = mainCategoryIds.count % rowCount == 0 ?
                                            mainCategoryIds.count / rowCount :
                (mainCategoryIds.count - (mainCategoryIds.count % rowCount)) / rowCount + 1
                mainScrollColumns2 = Array(repeating: GridItem(.fixed(itemWidth), spacing: 5), count: gridCount)
            }
        } else {
            let colCount = ConfigManager.mainColumnNumber
            let rowCount = ConfigManager.mainRowNumber
            if mainCategoryIds.count > colCount * rowCount {
                isMainScrollViewEnabled = true
                let itemWidth = (screenWidth - (CGFloat(colCount) - 1) * 5) * 2 / (CGFloat(colCount) * 2 - 1)
                let gridCount = mainCategoryIds.count % rowCount == 0 ?
                                            mainCategoryIds.count / rowCount :
                (mainCategoryIds.count - (mainCategoryIds.count % rowCount)) / rowCount + 1
                mainScrollColumns1 = Array(repeating: GridItem(.fixed(itemWidth), spacing: 5), count: gridCount)
            }
        }
    }
    private var mainCategorySection: some View {
        VStack {
            ZStack {
                HStack {
                    Image(systemName: "hand.point.right")
                    Text("Select Category")
                }
                if isMainScrollViewEnabled {
                    HStack {
                        Spacer()
                        Text("scroll >")
                    }
                }
            }
            .onDataChange(of: isPresentedProgressView2) { newValue in
                if newValue {
                    DispatchQueue.global(qos: .userInteractive).async {
                        showSubCategory = true
                    }
                }
            }
            ScrollView(.horizontal) {
                LazyVGrid(columns: mainScrollColumns, spacing: 5) {
                    ForEach(mainCategoryIds) { mainCategoryId in
                        ZStack {
                            MainCategoryButton(
                                mainCategoryId: mainCategoryId,
                                targetMainCategoryIndex: $targetMainCategoryIndex,
                                showSubCategory: $showSubCategory,
                                mainCategoryIds: $mainCategoryIds,
                                targetSubCategoryIndex: $targetSubCategoryIndex,
                                isSubScrollViewEnabled: $isSubScrollViewEnabled,
                                isPresentedProgressView2: $isPresentedProgressView2,
                                subScrollColumns1: $subScrollColumns1,
                                subScrollColumns2: $subScrollColumns2
                            )
                            if isPresentedProgressView2, targetMainCategoryIndex == mainCategoryId.id, mainCategoryIds[targetMainCategoryIndex].items.count > 0 {
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
    }
    private var subCategorySection: some View {
        VStack(spacing: 5) {
            ZStack {
                HStack {
                    Image(systemName: "hand.point.right")
                    Text("Select Details")
                }
                if isSubScrollViewEnabled {
                    HStack {
                        Spacer()
                        Text("scroll >")
                    }
                }
            }
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    LazyVGrid(columns: subScrollColumns, spacing: 5) {
                        ForEach(mainCategoryIds[targetMainCategoryIndex].items) { subCategoryId in
                            SubCategoryButton(
                                subCategoryId: subCategoryId,
                                targetMainCategoryIndex: targetMainCategoryIndex,
                                showImageStocker: $showImageStocker,
                                targetSubCategoryId: $targetSubCategoryId,
                                targetSubCategoryIndex: $targetSubCategoryIndex
                            )
                        }
                    }
                    .onAppear {
                        isPresentedProgressView2 = false
                    }
                }
            }
        }
    }
}
struct MainCategoryButton: View {
    let mainCategoryId: MainCategoryId
    @Binding var targetMainCategoryIndex: Int
    @Binding var showSubCategory: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var targetSubCategoryIndex: [Int]
    @Binding var isSubScrollViewEnabled: Bool
    @Binding var isPresentedProgressView2: Bool
    @Binding var subScrollColumns1: [GridItem]
    @Binding var subScrollColumns2: [GridItem]

    var body: some View {
        Button {
            if targetMainCategoryIndex == mainCategoryId.id {
                if showSubCategory == true {
                    showSubCategory = false
                } else {
                    if mainCategoryIds[mainCategoryId.id].items.count > 0 {
                        isPresentedProgressView2 = true
                    } else {
                        showSubCategory = true
                    }
                }
            } else {
                showSubCategory = false
                if mainCategoryIds[mainCategoryId.id].items.count > 0 {
                    isPresentedProgressView2 = true
                } else {
                    showSubCategory = true
                }
            }
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
                    .background(mainCategoryId.id == targetMainCategoryIndex ? .cyan : .blue)
                    .foregroundColor(.white)
            }
        }
    }
}
struct SubCategoryButton: View {
    let subCategoryId: SubCategoryId
    let targetMainCategoryIndex: Int
    @Binding var showImageStocker: Bool
    @Binding var targetSubCategoryId: SubCategoryId
    @Binding var targetSubCategoryIndex: [Int]

    var body: some View {
        Button {
            targetSubCategoryId = subCategoryId
            targetSubCategoryIndex[0] = targetMainCategoryIndex
            targetSubCategoryIndex[1] = subCategoryId.id
            showImageStocker = true
        } label: {
            if let range = subCategoryId.subCategory.range(of: ":=") {
                let idx = subCategoryId.subCategory.index(range.lowerBound, offsetBy: -1)
                Text(subCategoryId.subCategory[...idx] + "\n(\(subCategoryId.countStoredImages))")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(subCategoryId.id == targetSubCategoryIndex[1] ? .cyan : .blue)
                    .foregroundColor(.white)
            }
        }
    }
}
