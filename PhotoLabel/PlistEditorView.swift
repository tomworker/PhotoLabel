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
    @State var subCategoryStrings: [[String]] = Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfSubCategory), count: ConfigManager.maxNumberOfMainCategory)
    @State var countStoredImages: [[Int]] = Array(repeating: Array(repeating: 0, count: ConfigManager.maxNumberOfSubCategory), count: ConfigManager.maxNumberOfMainCategory)
    @State var imageFiles: [[[String]]] = Array(repeating: Array(repeating: Array(repeating: "", count: ConfigManager.maxNumberOfImageFile), count: ConfigManager.maxNumberOfSubCategory), count: ConfigManager.maxNumberOfMainCategory)
    @State var mainCategorys: [MainCategory] = []
    @State var isRename = false
    @State var isPlistNameError = false
    @State var isMaxNumberMainError = false
    @State var isMaxNumberSubError = false
    @State var isMaxNumberImageError = false

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
            .alert(isPresented: $isRename) {
                Alert(title: Text("Rename?"), message: Text(""),
                      primaryButton: .default(Text("OK"), action: {
                    savePlist(isRename: true)
                }),
                      secondaryButton: .cancel(Text("Cancel"), action:{
                    plistName = initialPlistName
                }))
            }
            Button {
                if plistName == initialPlistName {
                    savePlist(isRename: false)
                } else {
                    if initialPlistName.range(of: "&img") == nil {
                        savePlist(isRename: false)
                    } else {
                        if String(plistName.suffix(4)) == "&img" && plistName.count >= 5 {
                            isRename = true
                        } else {
                            isPlistNameError = true
                        }
                    }
                }
            } label : {
                Text("Save & exit")
                    .frame(width: 100, height: 30)
                    .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .alert(isPresented: $isPlistNameError) {
                Alert(title: Text("Canceled"), message: Text("It needs \"&img.plist\"."),
                    dismissButton: .default(Text("OK"), action: {
                }))
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
            for i in 0..<mainCategorys.count {
                if mainCategorys.count > ConfigManager.maxNumberOfMainCategory {
                    isMaxNumberMainError = true
                    break
                }
                mainCategoryStrings[i] = mainCategorys[i].mainCategory
                for j in 0..<mainCategorys[i].items.count {
                    if mainCategorys[i].items.count > ConfigManager.maxNumberOfSubCategory {
                        isMaxNumberSubError = true
                        break
                    }
                    subCategoryStrings[i][j] = mainCategorys[i].items[j].subCategory
                    countStoredImages[i][j] = mainCategorys[i].items[j].countStoredImages
                    for k in 0..<mainCategorys[i].items[j].countStoredImages{
                        if mainCategorys[i].items[j].countStoredImages > ConfigManager.maxNumberOfImageFile {
                            isMaxNumberImageError = true
                            break
                        }
                        imageFiles[i][j][k] = mainCategorys[i].items[j].images[k].imageFile
                    }
                }
            }
        }
        List {
            Section(header: Text("Input Photo Label ") + Text("Category").font(.title)) {
                ForEach(0..<ConfigManager.maxNumberOfMainCategory, id: \.self) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 25)
                        TextField("Category", text: $mainCategoryStrings[item])
                    }
                }
            }
        }
        NavigationView {
            List {
                Section(header: Text("Photo Label ") + Text("Category").font(.title) + Text(" - Topics, etc.")) {
                    ForEach(0..<ConfigManager.maxNumberOfMainCategory, id: \.self) { item in
                        NavigationLink(destination: PlistEditorSubView(subCategoryStrings: $subCategoryStrings[item], countStoredImages: $countStoredImages[item])) {
                            Text(mainCategoryStrings[item])
                        }
                    }
                }
            }
            .listStyle(.grouped)
        }
    }
    private func savePlist(isRename: Bool) {
        plistName = plistName.replacingOccurrences(of: " ", with: "_")
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
                                tempImageFiles.append(ImageFile(imageFile: imageFiles[i][j][k]))
                            }
                        }
                        tempSubCategorys.append(SubCategory(subCategory: subCategoryStrings[i][j], countStoredImages: countStoredImages[i][j], images: tempImageFiles))
                    }
                }
                mainCategorys.append(MainCategory(mainCategory: mainCategoryStrings[i], items: tempSubCategorys))
            }
        }
        CategoryManager.write(fileUrl: fileUrl, mainCategorys: mainCategorys)
        showPlistEditor = false
        if isRename {
            var atZipName = initialPlistName
            atZipName = atZipName.replacingOccurrences(of: "&img", with: "") + ".zip"
            let atZipUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(atZipName)
            var toZipName = plistName
            toZipName = toZipName.replacingOccurrences(of: "&img", with: "") + ".zip"
            let toZipUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(toZipName)
            ZipManager.renameZip(atZipUrl: atZipUrl, toZipUrl: toZipUrl)
            let oldPlistName = initialPlistName + ".plist"
            let oldPlistUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(oldPlistName)
            ZipManager.remove(fileUrl: oldPlistUrl)
        }
    }
}
