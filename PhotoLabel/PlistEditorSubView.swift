//
//  plistEditorSubView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistEditorSubView: View {
    @Binding var subCategoryStrings: [String]
    @Binding var countStoredImages: [Int]
    @Binding var imageFiles: [[String]]
    @Binding var imageInfos: [[String]]
    @ObservedObject var configManager = ConfigManager.shared
    @State var subCategoryStrings2: [String]
    @State var countStoredImagesString: [String]
    @State var selectedIndex: [Int] = [-1, -1]
    
    init(subCategoryStrings: Binding<[String]>, countStoredImages: Binding<[Int]>, imageFiles: Binding<[[String]]>, imageInfos: Binding<[[String]]>) {
        self._subCategoryStrings = subCategoryStrings
        self._countStoredImages = countStoredImages
        self._imageFiles = imageFiles
        self._imageInfos = imageInfos
        let count = ConfigManager.shared.maxNumberOfSubCategory
        self._subCategoryStrings2 = State(initialValue: Array(repeating: "", count: count))
        self._countStoredImagesString = State(initialValue: Array(repeating: "", count: count))
    }

    var body: some View {
        if selectedIndex[0] != -1 && selectedIndex[1] != -1 {
            Spacer(minLength: 8)
            HStack {
                Button {
                    changePlacePlist()
                } label: {
                    Text("Change Places")
                        .frame(width: 150, height: 30)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.leading)
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
                        .frame(width: 150, height: 30)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.leading)
                }
                Spacer()
            }
        }
        List {
            Section(header: Text("Input Photo Label ") + Text("Detail").font(.title)) {
                ForEach(0..<configManager.maxNumberOfSubCategory, id: \.self) { item in
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
                        Text(String(item + 1))
                            .frame(width: 32)
                        TextField("Detail", text: $subCategoryStrings2[item])
                            .frame(maxWidth: .infinity)
                            .keyboardType(.default)
                        TextField("0", text: $countStoredImagesString[item])
                            .frame(width: 25)
                            .keyboardType(.numberPad)
                    }
                    .onDataChange(of: subCategoryStrings2[item]) { _ in
                        if subCategoryStrings2[item] != "" && countStoredImagesString[item] == "" {
                            countStoredImagesString[item] = "0"
                        }
                        subCategoryStrings[item] = subCategoryStrings2[item]
                    }
                    .onDataChange(of: countStoredImagesString[item]) { _ in
                        if let countStoredImagesInt = Int(countStoredImagesString[item]) {
                            countStoredImages[item] = countStoredImagesInt
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            for i in 0..<countStoredImages.count {
                if subCategoryStrings[i] != "" {
                    subCategoryStrings2[i] = subCategoryStrings[i]
                    countStoredImagesString[i] = String(countStoredImages[i])
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
            if subCategoryStrings2[configManager.maxNumberOfSubCategory - 1] == "" {
                subCategoryStrings2.insert("", at: place1)
                countStoredImagesString.insert("0", at: place1)
                subCategoryStrings.insert("", at: place1)
                countStoredImages.insert(0, at: place1)
                imageFiles.insert(Array(repeating: "", count: configManager.maxNumberOfImageFile), at: place1)
                imageInfos.insert(Array(repeating: "", count: configManager.maxNumberOfImageFile), at: place1)
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
            var tempSubCategoryString2 = ""
            var tempCountStoredImagesString = "0"
            var tempImageFiles: [String] = []
            var tempImageInfos: [String] = []
            for i in 0..<subCategoryStrings2.count {
                if i == place1 {
                    tempSubCategoryString2 = subCategoryStrings2[place1]
                    tempCountStoredImagesString = countStoredImagesString[place1]
                    for j in 0..<imageFiles[place1].count {
                        tempImageFiles.append(imageFiles[place1][j])
                        tempImageInfos.append(imageInfos[place1][j])
                    }
                }
                if i == place2 {
                    subCategoryStrings2[place1] = subCategoryStrings2[place2]
                    subCategoryStrings2[place2] = tempSubCategoryString2
                    tempSubCategoryString2 = ""
                    countStoredImagesString[place1] = countStoredImagesString[place2]
                    countStoredImagesString[place2] = tempCountStoredImagesString
                    tempCountStoredImagesString = "0"
                    for j in 0..<imageFiles[place2].count {
                        imageFiles[place1][j] = imageFiles[place2][j]
                        imageFiles[place2][j] = tempImageFiles[j]
                        imageInfos[place1][j] = imageInfos[place2][j]
                        imageInfos[place2][j] = tempImageInfos[j]
                    }
                }
            }
        }
    }
}
