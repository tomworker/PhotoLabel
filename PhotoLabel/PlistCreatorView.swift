//
//  plistCreatorView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistCreatorView: View {
    @Binding var showPlistCreator: Bool
    @ObservedObject var configManager = ConfigManager.shared
    @State var mainCategory: [String]
    @State var subCategoryStrings: [[String]]
    @State var plistName: String = ""
    @State var isSaveError = false
    @State var mainCategorys: [MainCategory] = []
    
    init(showPlistCreator: Binding<Bool>) {
        self._showPlistCreator = showPlistCreator
        let mCount = ConfigManager.shared.maxNumberOfMainCategory
        let sCount = ConfigManager.shared.maxNumberOfSubCategory
        self._mainCategory = State(initialValue: Array(repeating: "", count: mCount))
        self._subCategoryStrings = State(initialValue: Array(repeating: Array(repeating: "", count: sCount), count: mCount))
    }

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
            Button {
                if plistName != "" {
                    plistName = ZipManager.replaceString(targetString: plistName)
                    let zipUrl = CategoryManager.documentDirectoryUrl.appendingPathComponent(plistName + ".zip")
                    if ZipManager.fileManager.fileExists(atPath: zipUrl.path) {
                        isSaveError = true;
                    } else {
                        let fileUrl = CategoryManager.documentDirectoryUrl.appendingPathComponent(plistName + ".plist")
                        var tempSubCategorys: [SubCategory] = []
                        for i in 0..<mainCategory.count {
                            if mainCategory[i] != "" {
                                tempSubCategorys = []
                                for j in 0..<subCategoryStrings[i].count {
                                    if subCategoryStrings[i][j] != "" {
                                        tempSubCategorys.append(SubCategory(subCategory: subCategoryStrings[i][j] + ":=-,-,-", countStoredImages: 0, images: []))
                                    }
                                }
                                mainCategorys.append(MainCategory(mainCategory: mainCategory[i] + ":=,,", items: tempSubCategorys, subFolderMode: 0))
                            }
                        }
                        CategoryManager.write(fileUrl: fileUrl, mainCategorys: mainCategorys)
                        showPlistCreator = false
                    }
                }
            } label : {
                Text("Save")
                    .frame(width: 50, height: 30)
                    .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .alert(isPresented: $isSaveError) {
                Alert(title: Text("Save Error"), message: Text("Zip file already exists!"))
            }
            Button {
                showPlistCreator = false
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 30, height: 30)
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.trailing)
            }
        }
        List {
            Section(header: Text("Input Photo Label ") + Text("Category").font(.title)) {
                ForEach(0..<configManager.maxNumberOfMainCategory, id: \.self) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 35)
                        TextField("Category", text: $mainCategory[item])
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        NavigationView {
            List {
                Section(header: Text("Photo Label ") + Text("Category").font(.title) + Text(" - Topics, etc.")) {
                    ForEach(0..<configManager.maxNumberOfMainCategory, id: \.self) { item in
                        NavigationLink(destination: PlistCreatorSubView(subCategoryStrings: $subCategoryStrings[item])) {
                            Text(mainCategory[item])
                        }
                    }
                }
            }
            .listStyle(.grouped)
        }
    }
}
