//
//  plistEditorSubView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct plistEditorSubView: View {
    @Binding var subCategoryStrings: [String]
    @Binding var countStoredImages: [Int]
    @State var countStoredImagesString: [String] = Array(repeating: "", count: 32)
    var body: some View {
        List {
            Section(header: Text("Input Photo Label ") + Text("Details").font(.title)) {
                ForEach(0..<32) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 25)
                        TextField("Details", text: $subCategoryStrings[item])
                            .frame(maxWidth: .infinity)
                        TextField("0", text: $countStoredImagesString[item])
                            .frame(width: 25)
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
                    countStoredImagesString[i] = String(countStoredImages[i])
                }
            }
        }
    }
}
