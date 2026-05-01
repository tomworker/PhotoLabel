//
//  plistEditorView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistEditorView: View {
    @Binding var showPlistEditor: Bool
    @State var plistName: String
    @State var mainCategoryIds: [MainCategoryId]
    @ObservedObject var configManager = ConfigManager.shared
    @State var mainCategoryStrings: [String] = []
    @State var mainCategoryStrings2: [String] = []
    @State var subFolderModes: [Int] = []
    @State var subCategoryStrings: [[String]] = []
    @State var subCategoryStrings2: [[String]] = []
    @State var countStoredImages: [[Int]] = []
    @State var imageFiles: [[[String]]] = []
    @State var imageInfos: [[[String]]] = []
    @State var initialPlistName = ""
    @State var mainCategorys: [MainCategory] = []
    @State var isRename = false
    @State var isCopy = false
    @State var isPlistNameError = false
    @State var isMaxNumberMainError = false
    @State var isMaxNumberSubError = false
    @State var isMaxNumberImageError = false
    @State var selectedIndex: [Int] = [-1, -1]
    @State private var path = NavigationPath()
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                EditorHeaderView(
                    plistName: $plistName,
                    initialPlistName: initialPlistName,
                    isRename: $isRename,
                    showPlistEditor: $showPlistEditor,
                    onSave: {
                        if plistName == initialPlistName { savePlist(isRename: false, isCopy: false) }
                        else { isRename = true }
                    }
                )
                EditorActionBar(
                    selectedIndex: $selectedIndex,
                    subFolderModes: $subFolderModes,
                    onInsert: insertBlankPlist,
                    onChangePlace: changePlacePlist,
                    onCopy: copyPlist,
                    onToggleMode: subFolderMode
                )
                List {
                    Section(header: Text("Input Photo Label ") + Text("Category").font(.title)) {
                        ForEach(mainCategoryStrings.indices, id: \.self) { i in
                            CategoryRowEditorView(
                                item: i,
                                selectedIndex: $selectedIndex,
                                subFolderMode: $subFolderModes[i],
                                categoryText: $mainCategoryStrings[i],
                                onDetailsTap: {
                                    path.append(i)
                                }
                            )
                        }
                    }
                }
            }
            .navigationDestination(for: Int.self) { index in
                PlistEditorSubView(
                    subCategoryStrings: $subCategoryStrings[index],
                    countStoredImages: $countStoredImages[index],
                    imageFiles: $imageFiles[index],
                    imageInfos: $imageInfos[index]
                )
                .navigationTitle(mainCategoryStrings[index])
            }
            .alert("Canceled", isPresented: $isMaxNumberMainError) {
                Button("OK") { showPlistEditor = false }
            } message: {
                Text("Category max number exceeded the limit of \(configManager.maxNumberOfMainCategory).")
            }
            .alert("Canceled", isPresented: $isMaxNumberSubError) {
                Button("OK") { showPlistEditor = false }
            } message: {
                Text("Details max number exceeded the limit of \(configManager.maxNumberOfSubCategory).")
            }
            .alert("Canceled", isPresented: $isMaxNumberImageError) {
                Button("OK") { showPlistEditor = false }
            } message: {
                Text("Image file max number exceeded the limit of \(configManager.maxNumberOfImageFile).")
            }
            .onAppear {
                let mCount = ConfigManager.shared.maxNumberOfMainCategory
                let sCount = ConfigManager.shared.maxNumberOfSubCategory
                let iCount = ConfigManager.shared.maxNumberOfImageFile
                mainCategoryStrings = Array(repeating: "", count: mCount)
                mainCategoryStrings2 = Array(repeating: "", count: mCount)
                subFolderModes = Array(repeating: 0, count: mCount)
                subCategoryStrings = Array(repeating: Array(repeating: "", count: sCount), count: mCount)
                subCategoryStrings2 = Array(repeating: Array(repeating: "", count: sCount), count: mCount)
                countStoredImages = Array(repeating: Array(repeating: 0, count: sCount), count: mCount)
                imageFiles = Array(repeating: Array(repeating: Array(repeating: "", count: iCount), count: sCount), count: mCount)
                imageInfos = Array(repeating: Array(repeating: Array(repeating: "", count: iCount), count: sCount), count: mCount)
                initialPlistName = plistName
                mainCategorys = CategoryManager.convertNoIdentifiable(mainCategoryIds: mainCategoryIds)
                var array: [String] = ["", ""]
                for i in 0..<mainCategorys.count {
                    if mainCategorys.count > configManager.maxNumberOfMainCategory {
                        isMaxNumberMainError = true
                        break
                    }
                    if let range = mainCategorys[i].mainCategory.range(of: ":=") {
                        let idx = mainCategorys[i].mainCategory.index(range.lowerBound, offsetBy: -1)
                        let idx2 = mainCategorys[i].mainCategory.index(range.lowerBound, offsetBy: 1)
                        array[0] = String(mainCategorys[i].mainCategory[...idx])
                        array[1] = String(mainCategorys[i].mainCategory[idx2...])
                    } else {
                        array[0] = mainCategorys[i].mainCategory
                        array[1] = "=,,"
                    }
                    mainCategoryStrings[i] = array[0]
                    mainCategoryStrings2[i] = array[1]
                    subFolderModes[i] = mainCategorys[i].subFolderMode
                    for j in 0..<mainCategorys[i].items.count {
                        if mainCategorys[i].items.count > configManager.maxNumberOfSubCategory {
                            isMaxNumberSubError = true
                            break
                        }
                        if let range = mainCategorys[i].items[j].subCategory.range(of: ":=") {
                            let idx = mainCategorys[i].items[j].subCategory.index(range.lowerBound, offsetBy: -1)
                            let idx2 = mainCategorys[i].items[j].subCategory.index(range.lowerBound, offsetBy: 1)
                            array[0] = String(mainCategorys[i].items[j].subCategory[...idx])
                            array[1] = String(mainCategorys[i].items[j].subCategory[idx2...])
                        } else {
                            array[0] = mainCategorys[i].items[j].subCategory
                            array[1] = "=-,-,-"
                        }
                        subCategoryStrings[i][j] = array[0]
                        subCategoryStrings2[i][j] = array[1]
                        countStoredImages[i][j] = mainCategorys[i].items[j].countStoredImages
                        for k in 0..<mainCategorys[i].items[j].countStoredImages{
                            if mainCategorys[i].items[j].countStoredImages > configManager.maxNumberOfImageFile {
                                isMaxNumberImageError = true
                                break
                            }
                            imageFiles[i][j][k] = mainCategorys[i].items[j].images[k].imageFile
                            imageInfos[i][j][k] = mainCategorys[i].items[j].images[k].imageInfo
                        }
                    }
                }
            }
        }
    }
    private func subFolderMode() {
        autoreleasepool {
            var place1 = selectedIndex[0]
            if place1 == -1 {
                place1 = selectedIndex[1]
            }
            if subFolderModes[place1] == 1 {
                subFolderModes[place1] = 0
            } else {
                subFolderModes[place1] = 1
            }
        }
    }
    private func copyPlist() {
        autoreleasepool {
            let place1 = selectedIndex[0]
            let place2 = selectedIndex[1]
            if mainCategoryStrings[configManager.maxNumberOfMainCategory - 1] == "" {
                mainCategoryStrings.insert("", at: place2)
                subFolderModes.insert(0, at: place2)
                subCategoryStrings.insert(Array(repeating: "", count: configManager.maxNumberOfSubCategory), at: place2)
                countStoredImages.insert(Array(repeating: 0, count: configManager.maxNumberOfSubCategory), at: place2)
                imageFiles.insert(Array(repeating: Array(repeating: "", count: configManager.maxNumberOfImageFile), count: configManager.maxNumberOfSubCategory), at: place2)
                imageInfos.insert(Array(repeating: Array(repeating: "", count: configManager.maxNumberOfImageFile), count: configManager.maxNumberOfSubCategory), at: place2)
                if place1 < place2 {
                    mainCategoryStrings[place2] = mainCategoryStrings[place1]
                    subFolderModes[place2] = subFolderModes[place1]
                    subCategoryStrings[place2] = subCategoryStrings[place1]
                } else {
                    mainCategoryStrings[place2] = mainCategoryStrings[place1 + 1]
                    subFolderModes[place2] = subFolderModes[place1 + 1]
                    subCategoryStrings[place2] = subCategoryStrings[place1 + 1]
                }
            }
        }
    }
    private func insertBlankPlist() {
        autoreleasepool {
            var place1 = selectedIndex[0]
            if place1 == -1 {
                place1 = selectedIndex[1]
            }
            if mainCategoryStrings[configManager.maxNumberOfMainCategory - 1] == "" {
                mainCategoryStrings.insert("", at: place1)
                subFolderModes.insert(0, at: place1)
                subCategoryStrings.insert(Array(repeating: "", count: configManager.maxNumberOfSubCategory), at: place1)
                countStoredImages.insert(Array(repeating: 0, count: configManager.maxNumberOfSubCategory), at: place1)
                imageFiles.insert(Array(repeating: Array(repeating: "", count: configManager.maxNumberOfImageFile), count: configManager.maxNumberOfSubCategory), at: place1)
                imageInfos.insert(Array(repeating: Array(repeating: "", count: configManager.maxNumberOfImageFile), count: configManager.maxNumberOfSubCategory), at: place1)
            }
        }
    }
    private func changePlacePlist() {
        autoreleasepool {
            var place1 = selectedIndex[0]
            var place2 = selectedIndex[1]
            if place1 > place2 {
                place1 = selectedIndex[1]
                place2 = selectedIndex[0]
            }
            var tempMainCategoryString = ""
            var tempSubFolderModes = 0
            var tempSubCategoryStrings: [String] = []
            var tempCountStoredImages: [Int] = []
            var tempImageFiles: [[String]] = []
            var tempImageInfos: [[String]] = []
            for i in mainCategoryStrings.indices {
                if i == place1 {
                    tempMainCategoryString = mainCategoryStrings[place1]
                    tempSubFolderModes = subFolderModes[place1]
                    tempSubCategoryStrings = subCategoryStrings[place1]
                    tempCountStoredImages = countStoredImages[place1]
                    tempImageFiles = imageFiles[place1]
                    tempImageInfos = imageInfos[place1]
                }
                if i == place2 {
                    mainCategoryStrings[place1] = mainCategoryStrings[place2]
                    mainCategoryStrings[place2] = tempMainCategoryString
                    tempMainCategoryString = ""
                    subFolderModes[place1] = subFolderModes[place2]
                    subFolderModes[place2] = tempSubFolderModes
                    tempSubFolderModes = 0
                    subCategoryStrings[place1] = subCategoryStrings[place2]
                    subCategoryStrings[place2] = tempSubCategoryStrings
                    countStoredImages[place1] = countStoredImages[place2]
                    countStoredImages[place2] = tempCountStoredImages
                    imageFiles[place1] = imageFiles[place2]
                    imageFiles[place2] = tempImageFiles
                    imageInfos[place1] = imageInfos[place2]
                    imageInfos[place2] = tempImageInfos
                    break
                }
            }
        }
    }
    private func savePlist(isRename: Bool, isCopy: Bool) {
        autoreleasepool {
            plistName = ZipManager.replaceString(targetString: plistName)
            if isRename == true && plistName == initialPlistName {
                return
            }
            let fileUrl = CategoryManager.documentDirectoryUrl.appendingPathComponent(plistName + ".plist")
            var tempSubCategorys: [SubCategory] = []
            var tempImageFiles: [ImageFile] = []
            mainCategorys = []
            for i in 0..<mainCategoryStrings.count {
                if mainCategoryStrings[i] != "" {
                    tempSubCategorys = []
                    for j in 0..<subCategoryStrings[i].count {
                        if subCategoryStrings[i][j] != "" {
                            tempImageFiles = []
                            for k in 0..<imageFiles[i][j].count {
                                if imageFiles[i][j][k] != "" {
                                    tempImageFiles.append(ImageFile(imageFile: imageFiles[i][j][k], imageInfo: imageInfos[i][j][k]))
                                }
                            }
                            if subCategoryStrings2[i][j] == "" {
                                subCategoryStrings2[i][j] = "=-,-,-"
                            }
                            tempSubCategorys.append(SubCategory(subCategory: subCategoryStrings[i][j] + ":" + subCategoryStrings2[i][j], countStoredImages: countStoredImages[i][j], images: tempImageFiles))
                        }
                    }
                    if mainCategoryStrings2[i] == "" {
                        mainCategoryStrings2[i] = "=,,"
                    }
                    mainCategorys.append(MainCategory(mainCategory: mainCategoryStrings[i] + ":" + mainCategoryStrings2[i], items: tempSubCategorys, subFolderMode: subFolderModes[i]))
                }
            }
            CategoryManager.write(fileUrl: fileUrl, mainCategorys: mainCategorys)
            showPlistEditor = false
            if isRename {
                let atZipName = initialPlistName + ".zip"
                let atZipUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(atZipName)
                let toZipName = plistName + ".zip"
                let toZipUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(toZipName)
                if isCopy {
                    if ZipManager.fileManager.fileExists(atPath: atZipUrl.path) {
                        ZipManager.copyZip(atZipUrl: atZipUrl, toZipUrl: toZipUrl)
                    }
                } else {
                    if ZipManager.fileManager.fileExists(atPath: atZipUrl.path) {
                        ZipManager.renameZip(atZipUrl: atZipUrl, toZipUrl: toZipUrl)
                    }
                    let oldPlistName = initialPlistName + ".plist"
                    let oldPlistUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(oldPlistName)
                    ZipManager.remove(fileUrl: oldPlistUrl)
                }
            }
        }
    }
}
struct EditorHeaderView: View {
    @Binding var plistName: String
    var initialPlistName: String
    @Binding var isRename: Bool
    @Binding var showPlistEditor: Bool
    var onSave: () -> Void

    var body: some View {
        HStack {
            Spacer()
            HStack {
                TextField("Ex) Topics_2023", text: $plistName)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text(".plist")
                    .frame(width: 40)
            }
            Button(action: onSave) {
                Text("Save")
                    .frame(width: 50, height: 30)
                    .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button { showPlistEditor = false } label: {
                Image(systemName: "xmark")
                    .frame(width: 30, height: 30)
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.trailing)
            }
        }
    }
}
struct EditorActionBar: View {
    @Binding var selectedIndex: [Int]
    @Binding var subFolderModes: [Int]
    var onInsert: () -> Void
    var onChangePlace: () -> Void
    var onCopy: () -> Void
    var onToggleMode: () -> Void

    var body: some View {
        VStack {
            if selectedIndex[0] != -1 && selectedIndex[1] != -1 {
                HStack {
                    ActionButton(title: "Change Places", action: onChangePlace)
                    ActionButton(title: "Copy \(selectedIndex[0] + 1) to \(selectedIndex[1] + 1) w/o photos", width: 200, action: onCopy)
                    Spacer()
                }
            } else if isAnySelected {
                HStack {
                    ActionButton(title: "Insert Blank", action: onInsert)
                    ActionButton(title: currentModeTitle, width: 200, action: onToggleMode)
                    Spacer()
                }
            }
        }
    }
    private var isAnySelected: Bool {
        selectedIndex[0] != -1 || selectedIndex[1] != -1
    }
    private var currentModeTitle: String {
        let idx = selectedIndex[0] != -1 ? selectedIndex[0] : selectedIndex[1]
        return subFolderModes[idx] == 1 ? "SubFolder Mode OFF" : "SubFolder Mode ON"
    }
}
struct ActionButton: View {
    let title: String
    var width: CGFloat = 130
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: width, height: 30)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.leading)
        }
    }
}
struct CategoryRowEditorView: View {
    let item: Int
    @Binding var selectedIndex: [Int]
    @Binding var subFolderMode: Int
    @Binding var categoryText: String
    var onDetailsTap: () -> Void

    var body: some View {
        HStack {
            VStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .frame(width: 25)
                    .foregroundColor(selectionColor)
            }
            .onTapGesture {
                updateSelection()
            }
            Text(subFolderMode == 1 ? "S" : "")
                .frame(width: 10)
            Text(String(item + 1))
                .frame(width: 32)
            TextField("Category", text: $categoryText)
            Button(action: onDetailsTap) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
    }
    private var isSelected: Bool {
        selectedIndex[0] == item || selectedIndex[1] == item
    }
    private var selectionColor: Color {
        if selectedIndex[0] != -1 && selectedIndex[1] != -1 {
            return isSelected ? .blue : .gray
        }
        return .blue
    }
    private func updateSelection() {
        if selectedIndex[0] == item {
            if selectedIndex[1] == -1 {
                selectedIndex[0] = -1
            } else {
                selectedIndex[0] = selectedIndex[1]
                selectedIndex[1] = -1
            }
        } else if selectedIndex[1] == item {
            selectedIndex[1] = -1
        } else {
            if selectedIndex[0] == -1 {
                selectedIndex[0] = item
            } else if selectedIndex[1] == -1 {
                selectedIndex[1] = item
            }
        }
    }
}
