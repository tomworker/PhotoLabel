//
//  plistEditorView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistEditorView: View {
    @Binding var showPlistEditor: Bool
    @State var plistName: String = ""
    let edittingPlistName: String
    let mainCategoryIds: [MainCategoryId]
    @State private var mainCategories: [MCatId] = []
    @State var initialPlistName = ""
    @State var isMaxNumberMainError = false
    @State var isMaxNumberSubError = false
    @State var isMaxNumberImageError = false
    @State private var selectedIndex: [Int] = [-1, -1]
    @State private var path = NavigationPath()
    @State private var isDataInitialized = false
    @State private var showSaveSelection = false
    @State private var showOverwriteConfirmation = false
    @State private var pendingSaveMode: SaveMode? = nil
    enum SaveMode {
        case overwrite
        case rename
        case copy
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                EditorHeaderView(
                    plistName: $plistName,
                    initialPlistName: initialPlistName,
                    showPlistEditor: $showPlistEditor,
                    onSave: {
                        plistName = ZipManager.replaceString(targetString: plistName)
                        if plistName == initialPlistName {
                            savePlist(mode: .overwrite)
                        } else {
                            showSaveSelection = true
                        }
                    }
                )
                EditorActionBar(
                    selectedIndex: $selectedIndex,
                    mainCategories: $mainCategories,
                    onInsert: insertBlankPlist,
                    onChangePlace: changePlacePlist,
                    onCopy: copyPlist,
                    onToggleMode: subFolderMode
                )
                List {
                    Section(header: Text("Input Photo Label ") + Text("Category").font(.title)) {
                        ForEach($mainCategories) { $mCat in
                            let i = mainCategories.firstIndex(where: { $0.id == mCat.id }) ?? 0
                            CategoryRowEditorView(
                                item: i,
                                selectedIndex: $selectedIndex,
                                mCat: $mCat,
                                onDetailsTap: { path.append(i) }
                            )
                        }
                    }
                }
            }
            .alert("Rename or Save as?", isPresented: $showSaveSelection) {
                Button("Rename and Save") {
                    prepareSave(mode: .rename)
                }
                Button("Save as Copy") {
                    prepareSave(mode: .copy)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("The file name has changed. Would you like to rename the existing one or create a new file?")
            }
            .alert("File Already Exists", isPresented: $showOverwriteConfirmation) {
                Button("Overwrite", role: .destructive) {
                    executePendingSave()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("A file named \"\(plistName)\" already exists. Do you want to overwrite it?")
            }
            .navigationDestination(for: Int.self) { index in
                PlistEditorSubView(
                    sCats: $mainCategories[index].items
                )
                .navigationTitle(mainCategories[index].mainCategory)
            }
            .onAppear {
                if !isDataInitialized {
                    setupData()
                    isDataInitialized = true
                }
            }
        }
    }
    private func setupData() {
        plistName = edittingPlistName
        initialPlistName = plistName
        let baseCategories = CategoryManager.convertNoIdentifiable(mainCategoryIds: mainCategoryIds)
        self.mainCategories = baseCategories.map { m in
            let components = m.mainCategory.components(separatedBy: ":=")
            let name = components.first ?? ""
            let suffix = components.count > 1 ? components[1] : ConfigManager.shared.defaultSuffix
            let sCatIds = m.items.map { s in
                let sComponents = s.subCategory.components(separatedBy: ":=")
                return SCatId(
                    subCategory: sComponents.first ?? "",
                    subCategory2: sComponents.count > 1 ? sComponents[1] : ConfigManager.shared.defaultSuffix,
                    countStoredImages: s.countStoredImages,
                    images: s.images.map { ImgFile(imageFile: $0.imageFile, imageInfo: $0.imageInfo) }
                )
            }
            return MCatId(mainCategory: name, mainCategory2: suffix, items: sCatIds, subFolderMode: m.subFolderMode)
        }
    }
    private func prepareSave(mode: SaveMode) {
        pendingSaveMode = mode
        if checkIfFileExists(name: plistName) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showOverwriteConfirmation = true
            }
        } else {
            executePendingSave()
        }
    }
    private func executePendingSave() {
        guard let mode = pendingSaveMode else { return }
        savePlist(mode: mode)
        pendingSaveMode = nil
    }
    private func checkIfFileExists(name: String) -> Bool {
        let fileUrl = CategoryManager.documentDirectoryUrl.appendingPathComponent("\(name).plist")
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }
    private func savePlist(mode: SaveMode) {
        autoreleasepool {
            plistName = ZipManager.replaceString(targetString: plistName)
            if mode == .rename && plistName == initialPlistName { return }
            let fileUrl = CategoryManager.documentDirectoryUrl.appendingPathComponent(plistName + ".plist")
            let outputCategories: [MainCategory] = mainCategories.compactMap { m in
                guard !m.mainCategory.isEmpty else { return nil }
                let subItems: [SubCategory] = m.items.compactMap { s in
                    guard !s.subCategory.isEmpty else { return nil }
                    let images = s.images.map { img in
                        ImageFile(imageFile: img.imageFile, imageInfo: img.imageInfo)
                    }
                    let fullSubName = "\(s.subCategory):=\(s.subCategory2)"
                    return SubCategory(subCategory: fullSubName, countStoredImages: s.countStoredImages, images: images)
                }
                let fullMainName = "\(m.mainCategory):=\(m.mainCategory2)"
                return MainCategory(mainCategory: fullMainName, items: subItems, subFolderMode: m.subFolderMode)
            }
            CategoryManager.write(fileUrl: fileUrl, mainCategorys: outputCategories)
            handleZipOperation(mode: mode)
            showPlistEditor = false
        }
    }
    private func handleZipOperation(mode: SaveMode) {
        let atZipUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(initialPlistName + ".zip")
        let toZipUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(plistName + ".zip")
        let oldPlistUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(initialPlistName + ".plist")
        if ZipManager.fileManager.fileExists(atPath: atZipUrl.path) {
            switch mode {
            case .copy:
                ZipManager.copyZip(atZipUrl: atZipUrl, toZipUrl: toZipUrl)
            case .rename:
                ZipManager.renameZip(atZipUrl: atZipUrl, toZipUrl: toZipUrl)
            case .overwrite:
                break
            }
        }
        if mode == .rename {
            ZipManager.remove(fileUrl: oldPlistUrl)
        }
    }
    private func subFolderMode() {
        let idx = selectedIndex[0] != -1 ? selectedIndex[0] : selectedIndex[1]
        guard idx != -1 else { return }
        mainCategories[idx].subFolderMode = (mainCategories[idx].subFolderMode == 1) ? 0 : 1
    }
    private func copyPlist() {
        let p1 = selectedIndex[0]
        let p2 = selectedIndex[1]
        guard p1 != -1 && p2 != -1 else { return }
        if mainCategories.count < ConfigManager.shared.maxNumberOfMainCategory {
            var copiedCat = mainCategories[p1]
            copiedCat.id = UUID()
            copiedCat.items = copiedCat.items.map { s in
                var newSub = s
                newSub.id = UUID()
                newSub.images = []
                newSub.countStoredImages = 0
                return newSub
            }
            mainCategories.insert(copiedCat, at: p2)
        }
    }
    private func insertBlankPlist() {
        let pos = selectedIndex[0] != -1 ? selectedIndex[0] : selectedIndex[1]
        guard pos != -1 else { return }
        let sCount = ConfigManager.shared.maxNumberOfSubCategory
        let blankSubCategories = (0..<sCount).map { _ in
            SCatId(subCategory: "", countStoredImages: 0, images: [])
        }
        let newCat = MCatId(mainCategory: "", items: blankSubCategories, subFolderMode: 0)
        mainCategories.insert(newCat, at: pos)
    }
    private func changePlacePlist() {
        let p1 = selectedIndex[0]
        let p2 = selectedIndex[1]
        guard p1 != -1 && p2 != -1 else { return }
        mainCategories.swapAt(p1, p2)
    }
}
struct EditorHeaderView: View {
    @Binding var plistName: String
    var initialPlistName: String
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
    @Binding var mainCategories: [MCatId]
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
        return mainCategories[idx].subFolderMode == 1 ? "SubFolder Mode OFF" : "SubFolder Mode ON"
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
    @Binding var mCat: MCatId
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
            Text(mCat.subFolderMode == 1 ? "S" : "")
                .frame(width: 10)
            Text(String(item + 1))
                .frame(width: 32)
            TextField("Category", text: $mCat.mainCategory)
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
struct ImgFile: Decodable, Encodable, Equatable {
    let imageFile: String
    var imageInfo: String = ""
}
struct SCatId: Identifiable {
    var id = UUID()
    var subCategory: String
    var subCategory2: String
    var countStoredImages: Int
    var images: [ImgFile]

    init(subCategory: String, subCategory2: String? = nil, countStoredImages: Int, images: [ImgFile]) {
        self.subCategory = subCategory
        self.subCategory2 = subCategory2 ?? ConfigManager.shared.defaultSuffix
        self.countStoredImages = countStoredImages
        self.images = images
    }
}
struct MCatId: Identifiable {
    var id = UUID()
    var mainCategory: String
    var mainCategory2: String
    var items: [SCatId]
    var subFolderMode: Int
    
    init(mainCategory: String, mainCategory2: String? = nil, items: [SCatId], subFolderMode: Int) {
        self.mainCategory = mainCategory
        self.mainCategory2 = mainCategory2 ?? ConfigManager.shared.defaultSuffix
        self.items = items
        self.subFolderMode = subFolderMode
    }
}
