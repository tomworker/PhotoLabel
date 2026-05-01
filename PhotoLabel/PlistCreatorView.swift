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
    @State private var path = NavigationPath()
    
    init(showPlistCreator: Binding<Bool>) {
        self._showPlistCreator = showPlistCreator
        let mCount = ConfigManager.shared.maxNumberOfMainCategory
        let sCount = ConfigManager.shared.maxNumberOfSubCategory
        self._mainCategory = State(initialValue: Array(repeating: "", count: mCount))
        self._subCategoryStrings = State(initialValue: Array(repeating: Array(repeating: "", count: sCount), count: mCount))
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                headerView
                List {
                    Section(header: Text("Input Photo Label ") + Text("Category").font(.title)) {
                        ForEach(mainCategory.indices, id: \.self) { i in
                            CategoryRowCreatorView(
                                item: i,
                                categoryText: $mainCategory[i],
                                onDetailsTap: {
                                    path.append(i)
                                }
                            )
                        }
                    }
                }
            }
            .alert(isPresented: $isSaveError) {
                Alert(title: Text("Save Error"), message: Text("Zip file already exists!"))
            }
            .navigationDestination(for: Int.self) { index in
                PlistCreatorSubView(subCategoryStrings: $subCategoryStrings[index])
                .navigationTitle(mainCategory[index])
            }
        }
    }
    private var headerView: some View {
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
            Button(action: saveAction) {
                Text("Save")
                    .frame(width: 50, height: 30)
                    .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
    }
    private func saveAction() {
        guard !plistName.isEmpty else { return }
        plistName = ZipManager.replaceString(targetString: plistName)
        let zipUrl = CategoryManager.documentDirectoryUrl.appendingPathComponent(plistName + ".zip")
        if ZipManager.fileManager.fileExists(atPath: zipUrl.path) {
            isSaveError = true
        } else {
            let fileUrl = CategoryManager.documentDirectoryUrl.appendingPathComponent(plistName + ".plist")
            var tempSubCategorys: [SubCategory] = []
            for i in 0..<mainCategory.count {
                if mainCategory[i] != "" {
                    tempSubCategorys = []
                    let suffix = ":=\(Array(repeating: "-", count: configManager.maxColumnsCheckBoxMatrix).joined(separator: ","))"
                    for j in 0..<subCategoryStrings[i].count {
                        if subCategoryStrings[i][j] != "" {
                            tempSubCategorys.append(SubCategory(subCategory: subCategoryStrings[i][j] + suffix, countStoredImages: 0, images: []))
                        }
                    }
                    mainCategorys.append(MainCategory(mainCategory: mainCategory[i] + suffix, items: tempSubCategorys, subFolderMode: 0))
                }
            }
            CategoryManager.write(fileUrl: fileUrl, mainCategorys: mainCategorys)
            showPlistCreator = false
        }
    }
}
struct CategoryRowCreatorView: View {
    let item: Int
    @Binding var categoryText: String
    var onDetailsTap: () -> Void
    
    var body: some View {
        HStack {
            Text(String(item + 1))
                .frame(width: 35)
            TextField("Category", text: $categoryText)
                .frame(maxWidth: .infinity)
            Button(action: onDetailsTap) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
    }
}
