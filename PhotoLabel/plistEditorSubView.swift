//
//  plistEditorSubView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct plistEditorSubView: View {
    @Binding var subCategoryStrings: [String]
    @State var subCategoryStrings2: [String] = Array(repeating: "", count: 32)
    @Binding var countStoredImages: [Int]
    @State var countStoredImagesString: [String] = Array(repeating: "", count: 32)

    var body: some View {
        List {
            Section(header: Text("Input Photo Label ") + Text("Details").font(.title)) {
                ForEach(0..<32) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 25)
                        TextField("Details", text: $subCategoryStrings2[item])
                            .frame(maxWidth: .infinity)
                            .keyboardType(.default)
                        TextField("0", text: $countStoredImagesString[item])
                            .frame(width: 25)
                            .keyboardType(.numberPad)
                    }
                    .onChange(of: subCategoryStrings2[item]) { newValue in
                        subCategoryStrings[item] = subCategoryStrings2[item]
                    }
                    .onChange(of: countStoredImagesString[item]) { newValue in
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
}
