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
    @State var initialPlistName = ""
    @State var mainCategoryIds: [MainCategoryId]
    @State var mainCategoryStrings: [String] = Array(repeating: "", count: ConfigManager.maxNumberOfMainCategory)
    @State var mainCategoryStrings2: [String] = Array(repeating: "", count: ConfigManager.maxNumberOfMainCategory)
    @State var subFolderModes: [Int] = Array(repeating: 0, count: ConfigManager.maxNumberOfMainCategory)
    @State var subCategoryStrings: [[String]] = Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfSubCategory), count: ConfigManager.maxNumberOfMainCategory)
    @State var subCategoryStrings2: [[String]] = Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfSubCategory), count: ConfigManager.maxNumberOfMainCategory)
    @State var countStoredImages: [[Int]] = Array(repeating: Array(repeating: 0, count: ConfigManager.maxNumberOfSubCategory), count: ConfigManager.maxNumberOfMainCategory)
    @State var imageFiles: [[[String]]] = Array(repeating: Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfImageFile), count: ConfigManager.maxNumberOfSubCategory), count: ConfigManager.maxNumberOfMainCategory)
    @State var imageInfos: [[[String]]] = Array(repeating: Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfImageFile), count: ConfigManager.maxNumberOfSubCategory), count: ConfigManager.maxNumberOfMainCategory)
    @State var mainCategorys: [MainCategory] = []
    @State var isRename = false
    @State var isCopy = false
    @State var isPlistNameError = false
    @State var isMaxNumberMainError = false
    @State var isMaxNumberSubError = false
    @State var isMaxNumberImageError = false
    @State var selectedIndex: [Int] = [-1, -1]
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)

    var body: some View {
        HStack {
            Spacer()
            HStack {
                TextField("Ex) Topics_2023", text: $plistName)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text(".plist")
                    .multilineTextAlignment(.leading)
                    .frame(width: 40)
            }
            .confirmationDialog("Save as another plist or Rename?", isPresented: $isRename, titleVisibility: .visible) {
                Button("Save as another plist") {
                    savePlist(isRename: true, isCopy: true)
                }
                Button("Rename") {
                    savePlist(isRename: true, isCopy: false)
                }
                Button("Cancel", role: .cancel) {
                    plistName = initialPlistName
                }
            }
            Button {
                if plistName == initialPlistName {
                    savePlist(isRename: false, isCopy: false)
                } else {
                    isRename = true
                }
            } label : {
                Text("Save")
                    .frame(width: 50, height: 30)
                    .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button {
                showPlistEditor = false
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 30, height: 30)
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.trailing)
            }
        }
        ZStack {
            VStack{
            }
            .alert(isPresented: $isMaxNumberMainError) {
                Alert(title: Text("Canceled"), message: Text("Category max number exceeded the limit of \(ConfigManager.maxNumberOfMainCategory)."),
                      dismissButton: .default(Text("OK"), action: {
                    showPlistEditor = false
                }))
            }
            VStack{
            }
            .alert(isPresented: $isMaxNumberSubError) {
                Alert(title: Text("Canceled"), message: Text("Details max number exceeded the limit of \(ConfigManager.maxNumberOfSubCategory)."),
                      dismissButton: .default(Text("OK"), action: {
                    showPlistEditor = false
                }))
            }
            VStack{
            }
            .alert(isPresented: $isMaxNumberImageError) {
                Alert(title: Text("Canceled"), message: Text("Image file max number exceeded the limit of \(ConfigManager.maxNumberOfImageFile)."),
                      dismissButton: .default(Text("OK"), action: {
                    showPlistEditor = false
                }))
            }
        }
        .onAppear {
            initialPlistName = plistName
            mainCategorys = CategoryManager.convertNoIdentifiable(mainCategoryIds: mainCategoryIds)
            var array: [String] = ["", ""]
            for i in 0..<mainCategorys.count {
                if mainCategorys.count > ConfigManager.maxNumberOfMainCategory {
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
                    if mainCategorys[i].items.count > ConfigManager.maxNumberOfSubCategory {
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
                        if mainCategorys[i].items[j].countStoredImages > ConfigManager.maxNumberOfImageFile {
                            isMaxNumberImageError = true
                            break
                        }
                        imageFiles[i][j][k] = mainCategorys[i].items[j].images[k].imageFile
                        imageInfos[i][j][k] = mainCategorys[i].items[j].images[k].imageInfo
                    }
                }
            }
        }
        VStack {
            if selectedIndex[0] != -1 && selectedIndex[1] != -1 {
                Spacer(minLength: 8)
                HStack {
                    Button {
                        changePlacePlist()
                    } label: {
                        Text("Change Places")
                            .frame(width: 140, height: 30)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.leading)
                    }
                    Button {
                        copyPlist()
                    } label: {
                        Text("Copy \(selectedIndex[0] + 1) to \(selectedIndex[1] + 1) w/o photos")
                        .frame(width: 220, height: 30)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    Spacer()
                }
            } else if (selectedIndex[0] != -1 && selectedIndex[1] == -1) || (selectedIndex[0] == -1 && selectedIndex[1] != -1) {
                Spacer(minLength: 8)
                HStack {
                    Button {
                        insertBlankPlist()
                    } label: {
                        Text("Insert Blank")
                            .frame(width: 130, height: 30)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.leading)
                    }
                    Button {
                        subFolderMode()
                    } label: {
                        if selectedIndex[0] != -1 {
                            Text(subFolderModes[selectedIndex[0]] == 1 ? "SubFolder Mode OFF" : "SubFolder Mode ON")
                                .frame(width: 200, height: 30)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.leading)
                        }
                    }
                    Spacer()
                }
            }
            List {
                Section(header: Text("Input Photo Label ") + Text("Category").font(.title)) {
                    ForEach(0..<ConfigManager.maxNumberOfMainCategory, id: \.self) { item in
                        HStack {
                            VStack {
                                Image(systemName: selectedIndex[0] == item || selectedIndex[1] == item ? "checkmark.circle.fill" : "circle")
                                    .frame(width: 25)
                                    .foregroundColor(selectedIndex[0] != -1 && selectedIndex[1] != -1 ? selectedIndex[0] == item || selectedIndex[1] == item ? .blue : .gray : .blue)
                            }
                            .onTapGesture {
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
                                    } else {
                                        if selectedIndex[1] == -1 {
                                            selectedIndex[1] = item
                                        }
                                    }
                                }
                            }
                            Text(subFolderModes[item] == 1 ? "S" : "")
                                .frame(width: 10)
                            Text(String(item + 1))
                                .frame(width: 32)
                            TextField("Category", text: $mainCategoryStrings[item])
                        }
                    }
                }
            }
            NavigationView {
                List {
                    Section(header: Text("Photo Label ") + Text("Category").font(.title) + Text(" - Topics, etc.")) {
                        ForEach(0..<ConfigManager.maxNumberOfMainCategory, id: \.self) { item in
                            NavigationLink(destination: PlistEditorSubView(subCategoryStrings: $subCategoryStrings[item], countStoredImages: $countStoredImages[item], imageFiles: $imageFiles[item], imageInfos: $imageInfos[item])) {
                                Text(mainCategoryStrings[item])
                            }
                        }
                    }
                }
                .listStyle(.grouped)
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
            if mainCategoryStrings[ConfigManager.maxNumberOfMainCategory - 1] == "" {
                mainCategoryStrings.insert("", at: place2)
                subFolderModes.insert(0, at: place2)
                subCategoryStrings.insert(Array(repeating: "", count: ConfigManager.maxNumberOfSubCategory), at: place2)
                countStoredImages.insert(Array(repeating: 0, count: ConfigManager.maxNumberOfSubCategory), at: place2)
                imageFiles.insert(Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfImageFile), count: ConfigManager.maxNumberOfSubCategory), at: place2)
                imageInfos.insert(Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfImageFile), count: ConfigManager.maxNumberOfSubCategory), at: place2)
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
            if mainCategoryStrings[ConfigManager.maxNumberOfMainCategory - 1] == "" {
                mainCategoryStrings.insert("", at: place1)
                subFolderModes.insert(0, at: place1)
                subCategoryStrings.insert(Array(repeating: "", count: ConfigManager.maxNumberOfSubCategory), at: place1)
                countStoredImages.insert(Array(repeating: 0, count: ConfigManager.maxNumberOfSubCategory), at: place1)
                imageFiles.insert(Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfImageFile), count: ConfigManager.maxNumberOfSubCategory), at: place1)
                imageInfos.insert(Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfImageFile), count: ConfigManager.maxNumberOfSubCategory), at: place1)
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
