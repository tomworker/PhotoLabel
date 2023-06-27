//
//  plistCreatorView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistCreatorView: View {
    @State var mainCategory: [String] = Array(repeating: "", count: 15)
    @State var subCategoryStrings: [[String]] = Array(repeating: Array(repeating: "", count: 32), count: 15)
    @State var plistName: String = ""
    @Binding var showPlistCreator: Bool
    @State var showPlistCreatorSub: [Bool] = Array(repeating: false, count: 32)
    @State var mainCategorys: [MainCategory] = []

    var body: some View {
        HStack {
            Spacer()
            Button {
            } label : {
                HStack {
                    TextField("Ex) Topics_2023", text: $plistName)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 160, height: 30)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text(".plist")
                        .multilineTextAlignment(.leading)
                        .frame(width: 40)
                        .foregroundColor(.black)
                }
            }
            Button {
                if plistName != "" {
                    plistName = plistName.replacingOccurrences(of: " ", with: "_")
                    let fileUrl = CategoryManager.documentDirectoryUrl.appendingPathComponent(plistName + ".plist")
                    var tempSubCategorys: [SubCategory] = []
                    for i in 0..<mainCategory.count {
                        if mainCategory[i] != "" {
                            tempSubCategorys = []
                            for j in 0..<subCategoryStrings[i].count {
                                if subCategoryStrings[i][j] != "" {
                                    tempSubCategorys.append(SubCategory(subCategory: subCategoryStrings[i][j], countStoredImages: 0, images: []))
                                }
                            }
                            mainCategorys.append(MainCategory(mainCategory: mainCategory[i], items: tempSubCategorys))
                        }
                    }
                    CategoryManager.write(fileUrl: fileUrl, mainCategorys: mainCategorys)
                    showPlistCreator = false
                }
            } label : {
                Text("Save & exit")
                    .frame(width: 100, height: 30)
                    .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
            Button {
                showPlistCreator = false
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 30, height: 30)
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
        List {
            Section(header: Text("Input Photo Label ") + Text("Category").font(.title)) {
                ForEach(0..<15) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 25)
                        TextField("Category", text: $mainCategory[item])
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        NavigationView {
            List {
                Section(header: Text("Photo Label ") + Text("Category").font(.title) + Text(" - Topics, etc.")) {
                    ForEach(0..<15) { item in
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
