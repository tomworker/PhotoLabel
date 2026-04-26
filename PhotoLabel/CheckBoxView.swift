//
//  CheckBoxView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/12/02.
//

import SwiftUI

struct CheckBoxView: View {
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @Binding var plistCategoryName: String
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var fileUrl: URL
    @Binding var targetMainCategoryIndex: Int
    @Binding var showCheckBox: Bool
    @Binding var downSizeImages: [[[UIImage]]]
    @ObservedObject var configManager = ConfigManager.shared
    @State var mainCategoryArray: [String] = [""]
    @State var mainCategoryArray2: [[String]] = []
    @State var subCategory2: [[[String]]] = []
    @State var subCategory3: [[[String]]] = []
    @State var subCategory4: [[[String]]] = []
    @State var targetSubCategoryIndex: [Int] = [-1, -1]
    @State var targetImageFileIndex = 0
    @State var showImageView = false
    @State var showImageView3 = false
    @State var showImageStocker = false
    @State var isEditCheckItem: [Bool] = []
    @State var isEditCheckInfo: [[Bool]] = []
    @State var isClear = false
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let initialOriginx = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5) + CGFloat(10) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3) + CGFloat(10))
    let imageWidth = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) / CGFloat(5) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(3))
    let imageHeight = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - CGFloat((5 - 1) * 10)) * CGFloat(0.15) : (UIScreen.main.bounds.width - CGFloat((3 - 1) * 10)) / CGFloat(4))
    private var rowCount: Int {
        mainCategoryIds.reduce(0) { $0 + $1.items.count}
    }
    private var columnCount: Int {
        configManager.maxColumnsCheckBoxMatrix
    }
    private var cellSize: CGSize {
        CGSize(width: CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? configManager.iPadCheckBoxMatrixColumnWidth : configManager.checkBoxMatrixColumnWidth), height: imageHeight + 25)
    }
    private var freezeSize: CGSize {
        CGSize(width: UIDevice.current.userInterfaceIdiom == .pad ? initialOriginx * 2.4 : initialOriginx * 1.4, height: 60)
    }
    let initialScroll: CGPoint = .zero

    var body: some View {
        VStack(spacing: 0) {
            headerView
            if subCategory2.count > 1 || (subCategory2.count == 1 && !subCategory2[0].isEmpty) {
                FreezeScrollView(
                    rowCount: rowCount,
                    columnCount: columnCount,
                    cellSize: cellSize,
                    freezeSize: freezeSize,
                    initialScroll: initialScroll,
                    anchor: { rowRange in
                        anchorView(rowRange: rowRange)
                    },
                    col: { _, idx in
                        colView(index: idx, colCount: columnCount, fileUrl: fileUrl, mCatIds: $mainCategoryIds, mCatArr: $mainCategoryArray, mCatArr2: $mainCategoryArray2, isEditCheckItem: $isEditCheckItem)
                    },
                    row: { _, idx in
                        rowView(index: idx, mCatIds: mainCategoryIds)
                    },
                    cell: { _, _, idx1, idx2 in
                        cellView(rowIdx: idx1, colIdx: idx2)
                    }
                )
                .clipped()
            } else {
                ProgressView()
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
            ImageStockerTabView(showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex, downSizeImages: $downSizeImages)
        }
        .onAppear {
            rebuildArrays()
        }
        .onDataChange(of: configManager.maxColumnsCheckBoxMatrix) { _ in
            rebuildArrays()
        }
    }
    private func rebuildArrays() {
        let mainCount = mainCategoryIds.count
        var fullTitles = Array(repeating: "", count: mainCount)
        var fullMain2 = Array(repeating: [String](), count: mainCount)
        var fullSub2 = Array(repeating: [[String]](), count: mainCount)
        var fullSub3 = Array(repeating: [[String]](), count: mainCount)
        var fullSub4 = Array(repeating: [[String]](), count: mainCount)
        let totalRowCount = mainCategoryIds.reduce(0) { $0 + $1.items.count }
        let totalColCount = configManager.maxColumnsCheckBoxMatrix
        /* Note: The 0th MainCategory is designated as the primary container for
               check sheet column headers. Headers in subsequent MainCategories
               (index 1+) are not utilized in the current spreadsheet layout.
        */
        for mIdx in 0..<mainCount {
            let parsed = parseCategoryData(at: mIdx)
            fullTitles[mIdx] = parsed.mainTitle
            fullMain2[mIdx] = parsed.mainRow
            fullSub2[mIdx] = parsed.sub2
            fullSub3[mIdx] = parsed.sub3
            fullSub4[mIdx] = parsed.sub4
        }
        self.mainCategoryArray = fullTitles
        self.mainCategoryArray2 = fullMain2
        self.subCategory2 = fullSub2
        self.subCategory3 = fullSub3
        self.subCategory4 = fullSub4
        self.isEditCheckItem = Array(repeating: false, count: configManager.maxColumnsCheckBoxMatrix)
        self.isEditCheckInfo = Array(repeating: Array(repeating: false, count: totalColCount), count: totalRowCount)
    }
    struct ParsedData {
        let mainTitle: String
        let mainRow: [String]
        let sub2: [[String]]
        let sub3: [[String]]
        let sub4: [[String]]
    }
    private func parseCategoryData(at mIdx: Int) -> ParsedData {
        let targetCount = configManager.maxColumnsCheckBoxMatrix
        let maxSubRows = configManager.maxNumberOfSubCategory
        let rawMain = mainCategoryIds[mIdx].mainCategory
        var parsedMainTitle = ""
        var mainCSV = ""
        if let range = rawMain.range(of: ":=") {
            parsedMainTitle = String(rawMain[..<range.lowerBound])
            mainCSV = String(rawMain[range.upperBound...])
        } else {
            parsedMainTitle = rawMain
            mainCSV = ""
        }
        let mainElements = adjustElements(mainCSV.components(separatedBy: ","), to: targetCount)
        var newSub2 = Array(repeating: Array(repeating: "", count: targetCount), count: maxSubRows)
        var newSub3 = newSub2
        var newSub4 = newSub2
        for item in mainCategoryIds[mIdx].items {
            let sIdx = item.id
            guard sIdx < maxSubRows else { continue }
            let rawStr = item.subCategory
            let csvPart: String
            if let range = rawStr.range(of: ":=") {
                csvPart = String(rawStr[range.upperBound...])
            } else { csvPart = "" }
            let elements = adjustElements(csvPart.components(separatedBy: ","), to: targetCount, paddingWith: "-")
            for cIdx in 0..<targetCount {
                let val = elements[cIdx]
                newSub2[sIdx][cIdx] = val
                if !val.isEmpty {
                    newSub3[sIdx][cIdx] = String(val.prefix(1))
                    newSub4[sIdx][cIdx] = String(val.dropFirst())
                } else {
                    newSub3[sIdx][cIdx] = "-"
                    newSub4[sIdx][cIdx] = ""
                }
            }
        }
        return ParsedData(mainTitle: parsedMainTitle, mainRow: mainElements, sub2: newSub2, sub3: newSub3, sub4: newSub4)
    }
    private func adjustElements(_ elements: [String], to count: Int, paddingWith paddingValue: String = "") -> [String] {
        var result = elements
        if result.count < count {
            let suffix = Array(repeating: paddingValue, count: count - result.count)
            result.append(contentsOf: suffix)
        } else if result.count > count {
            result = Array(result.prefix(count))
        }
        return result
    }
    private var headerView: some View {
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
            if targetMainCategoryIndex == -1 {
                targetMainCategoryIndex = 0
            }
        }
    }
    private func clearCheckBox() {
        let columnCount = configManager.maxColumnsCheckBoxMatrix
        let resetCSV = Array(repeating: "-", count: columnCount).joined(separator: ",")
        let suffix = ":=" + resetCSV
        autoreleasepool {
            for i in mainCategoryIds.indices {
                for j in mainCategoryIds[i].items.indices {
                    let rawStr = mainCategoryIds[i].items[j].subCategory
                    if let range = rawStr.range(of: ":=") {
                        let title = rawStr[..<range.lowerBound]
                        mainCategoryIds[i].items[j].subCategory = title + suffix
                    }
                }
            }
            rebuildArrays()
            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
        }
    }
    private func anchorView(rowRange: ClosedRange<Int>) -> some View {
        let fromRange = rowRange.lowerBound
        guard let rt = findNestedIndex(from: fromRange, in: mainCategoryIds) else {
            return AnyView(EmptyView())
        }
        let mIdx = rt.main
        let rawContent = VStack(spacing: 0) {
            HStack {
                Text(mainCategoryIds[mIdx].mainCategory.cleanedTitle)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        return AnyView(rawContent)
    }
    private func colView(index: Int, colCount: Int, fileUrl: URL, mCatIds: Binding<[MainCategoryId]>, mCatArr: Binding<[String]>, mCatArr2: Binding<[[String]]>, isEditCheckItem: Binding<[Bool]>) -> some View {
        let isPresented = Binding(
            get: {
                if isEditCheckItem.indices.contains(index) {
                    return isEditCheckItem.wrappedValue[index]
                } else { return false }
            },
            set: { newValue in
                if isEditCheckItem.indices.contains(index) {
                    isEditCheckItem.wrappedValue[index] = newValue
                }
            }
        )
        /* Note: We intentionally reference index [0] here because the column headers
               for the entire spreadsheet are globally managed by the first MainCategory
               in the current data structure.
        */
        let textBinding = Binding(
            get: {
                if mCatArr2.wrappedValue[0].indices.contains(index) {
                    return mCatArr2.wrappedValue[0][index]
                } else { return "" }
            },
            set: { newValue in
                if mCatArr2.wrappedValue[0].indices.contains(index) {
                    mCatArr2.wrappedValue[0][index] = newValue
                }
            }
        )
        let displayText: String = {
            if mCatArr2.wrappedValue.indices.contains(0) && mCatArr2.wrappedValue[0].indices.contains(index) {
                let value = mCatArr2.wrappedValue[0][index]
                return value.isEmpty ? "CHK" + String(index + 1) : value
            }
            return "CHK" + String(index + 1)
        }()
        return Text(displayText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(index % 2 == 0 ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
            .onLongPressGesture {
                isEditCheckItem.wrappedValue[index] = true
            }
            .alert("", isPresented: isPresented, actions: {
                let initialValue = textBinding.wrappedValue
                TextField("CheckItem", text: textBinding)
                Button("Edit") {
                    let colLabels = (0..<min(colCount, mCatArr2.wrappedValue[0].count)).map { mCatArr2.wrappedValue[0][$0] }.joined(separator: ",")
                    mCatIds.wrappedValue[0].mainCategory = mCatArr.wrappedValue[0] + ":=" + colLabels
                   ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mCatIds.wrappedValue)
                }
                Button("Cancel", role: .cancel) {
                    mCatArr2.wrappedValue[0][index] = initialValue
                }
            }, message: {
                
            })
    }
    private func rowView(index: Int, mCatIds: [MainCategoryId]) -> some View {
        guard let rt = findNestedIndex(from: index, in: mCatIds) else {
            return AnyView(EmptyView())
        }
        let mIdx = rt.main
        let sIdx = rt.sub
        let mCat = mCatIds[mIdx].mainCategory
        let sCatItem = mCatIds[mIdx].items[sIdx]
        let prefix = (sIdx == 0) ? mCat.cleanedTitle + ": " : ""
        let title = sCatItem.subCategory.cleanedTitle
        let rowContent = VStack(spacing: 0) {
            HStack {
                Text(prefix + title)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 25)
            .background(targetSubCategoryIndex[0] == mIdx && targetSubCategoryIndex[1] == sIdx ? Color(.cyan) : index % 2 == 0 ? Color(UIColor.systemGray3) : Color(UIColor.systemGray5))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    if sCatItem.countStoredImages == 0 {
                        VStack(alignment: .center, spacing: 0) {
                            Image(systemName: "camera")
                            Text("Take photo").font(.system(size: 8))
                            Text("Long press").font(.system(size: 8))
                        }
                        .frame(width: imageWidth, height: imageHeight)
                        .foregroundColor(.white)
                        .background(.gray.opacity((0.3)))
                        .cornerRadius(10)
                        // Recovery code for onLongPressGesture problem
                        .onDataChange(of: showImageStocker) { _ in }
                        // Above code goes well for some reason.
                        .onTapGesture { }
                        .onLongPressGesture {
                            self.showImageStocker = true
                            self.targetSubCategoryIndex = [mIdx, sIdx]
                        }
                    } else {
                        ForEach(sCatItem.images.indices, id: \.self) { imgIdx in
                            if downSizeImages.indices.contains(mIdx),
                               downSizeImages[mIdx].indices.contains(sIdx),
                               downSizeImages[mIdx][sIdx].indices.contains(imgIdx) {
                                Image(uiImage: downSizeImages[mIdx][sIdx][imgIdx])
                                    .resizable()
                                    .aspectRatio(downSizeImages[mIdx][sIdx][imgIdx].size.width > downSizeImages[mIdx][sIdx][imgIdx].size.height ? 4 / 3 : downSizeImages[mIdx][sIdx][imgIdx].size.width == downSizeImages[mIdx][sIdx][imgIdx].size.height ? 1 : 3 / 4, contentMode: .fit)
                                    .frame(width: downSizeImages[mIdx][sIdx][imgIdx].size.width > downSizeImages[mIdx][sIdx][imgIdx].size.height ? imageWidth : imageHeight, height: imageHeight)
                                    .cornerRadius(10)
                                    // Recovery code for onTapGesture problem
                                    .onDataChange(of: showImageView) { _ in  }
                                    // Above code goes well for some reason.
                                    .onTapGesture(count: 1) {
                                        self.showImageView = true
                                        self.targetSubCategoryIndex = [mIdx, sIdx]
                                        self.targetImageFileIndex = imgIdx
                                    }
                                    // Recovery code for onLongPressGesture problem
                                    .onDataChange(of: showImageStocker) { _ in  }
                                    // Above code goes well for some reason.
                                    .onLongPressGesture {
                                        self.showImageStocker = true
                                        self.targetSubCategoryIndex = [mIdx, sIdx]
                                    }
                            }
                        }
                    }
                }
            }
        }
        return AnyView(rowContent)
    }
    func findNestedIndex(from flatIndex: Int, in mainArray: [MainCategoryId]) -> (main: Int, sub: Int)? {
        var remainingIndex = flatIndex
        for (mIndex, subArray) in mainArray.enumerated() {
            if remainingIndex < subArray.items.count {
                return (main: mIndex, sub: remainingIndex)
            }
            remainingIndex -= subArray.items.count
        }
        return nil
    }
    private func cellView(rowIdx: Int, colIdx: Int) -> some View {
        Group {
            guard let rt = findNestedIndex(from: rowIdx, in: mainCategoryIds) else {
                return AnyView(EmptyView())
            }
            let mIdx = rt.main
            let sIdx = rt.sub
            guard subCategory3.indices.contains(mIdx),
                  subCategory3[mIdx].indices.contains(sIdx),
                  subCategory3[mIdx][sIdx].indices.contains(colIdx),
                  subCategory4.indices.contains(mIdx),
                  subCategory4[mIdx].indices.contains(sIdx),
                  subCategory4[mIdx][sIdx].indices.contains(colIdx) else {
                return AnyView(EmptyView())
            }
            let remarksBinding = Binding(
                get: { self.subCategory4[mIdx][sIdx][colIdx] },
                set: { self.subCategory4[mIdx][sIdx][colIdx] = $0 }
            )
            let currentRemarks = subCategory4[mIdx][sIdx][colIdx]
            return AnyView(
                VStack(spacing: 0) {
                    let checkStatus = subCategory3[mIdx][sIdx][colIdx]
                    ZStack {
                        Image(systemName: checkStatus == "*" ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.blue)
                            .offset(y: 8)
                        Circle()
                            .foregroundColor(.gray.opacity(0.1))
                            .frame(width: 35, height: 35)
                            .offset(y: 8)
                            .onTapGesture {
                                toggleCheckBox(mIdx: mIdx, sIdx: sIdx, colIdx: colIdx)
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 45)
                    VStack(spacing: 0) {
                        if currentRemarks == "" {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .frame(width: 30, height: 30)
                                .background(.black.opacity(0.3))
                                .foregroundColor(.white.opacity(0.3))
                                .cornerRadius(10)
                        } else {
                            Text(currentRemarks)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onLongPressGesture {
                        isEditCheckInfo[rowIdx][colIdx] = true
                    }
                }
                .background((rowIdx + colIdx) % 2 == 0 ? Color(UIColor.systemGray5) : Color(UIColor.systemGray3))
                .alert("Edit Remarks", isPresented: $isEditCheckInfo[rowIdx][colIdx]) {
                    let initialValue = currentRemarks
                    TextField("Remarks", text: remarksBinding)
                    Button("Update") {
                        updateRemarks(mIdx: mIdx, sIdx: sIdx, colIdx: colIdx)
                    }
                    Button("Cancel", role: .cancel) {
                        self.subCategory4[mIdx][sIdx][colIdx] = initialValue
                    }
                } message: {
                    Text("Enter notes for this item.")
                }
            )
        }
    }
    private func updateRemarks(mIdx: Int, sIdx: Int, colIdx: Int) {
        autoreleasepool {
            let status = subCategory3[mIdx][sIdx][colIdx]
            let text = subCategory4[mIdx][sIdx][colIdx]
            subCategory2[mIdx][sIdx][colIdx] = status + text
            if let range = mainCategoryIds[mIdx].items[sIdx].subCategory.range(of: ":=") {
                let titlePart = mainCategoryIds[mIdx].items[sIdx].subCategory[..<range.lowerBound]
                let csvString = subCategory2[mIdx][sIdx].joined(separator: ",")
                mainCategoryIds[mIdx].items[sIdx].subCategory = titlePart + ":=" + csvString
                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
            }
        }
    }
    private func toggleCheckBox(mIdx: Int, sIdx: Int, colIdx: Int) {
        autoreleasepool {
            let checkStatus = subCategory3[mIdx][sIdx][colIdx]
            if checkStatus == "-" {
                subCategory3[mIdx][sIdx][colIdx] = "*"
            } else if checkStatus == "*" {
                subCategory3[mIdx][sIdx][colIdx] = "-"
            }
            subCategory2[mIdx][sIdx][colIdx] = subCategory3[mIdx][sIdx][colIdx] + subCategory4[mIdx][sIdx][colIdx]
            if let range = mainCategoryIds[mIdx].items[sIdx].subCategory.range(of: ":=") {
                let titlePart = mainCategoryIds[mIdx].items[sIdx].subCategory[..<range.lowerBound]
                let csvString = subCategory2[mIdx][sIdx].joined(separator: ",")
                mainCategoryIds[mIdx].items[sIdx].subCategory = titlePart + ":=" + csvString
            }
            ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
        }
    }
}
extension String {
    var cleanedTitle: String {
        self.components(separatedBy: ":=").first ?? self
    }
}
