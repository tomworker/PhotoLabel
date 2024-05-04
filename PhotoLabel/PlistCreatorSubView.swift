//
//  plistCreatorSubView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistCreatorSubView: View {
    @Binding var subCategoryStrings: [String]
    @State var subCategoryStrings2: [String] = Array(repeating: "", count: ConfigManager.maxNumberOfSubCategory)

    var body: some View {
        List {
            Section(header: Text("Input Photo Label ") + Text("Detail").font(.title)) {
                ForEach(0..<ConfigManager.maxNumberOfSubCategory, id: \.self) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 35)
                        TextField("Detail", text: $subCategoryStrings2[item])
                            .frame(maxWidth: .infinity)
                            .keyboardType(.default)
                    }
                    .onChange(of: subCategoryStrings2[item]) {
                        subCategoryStrings[item] = subCategoryStrings2[item]
                    }
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            for i in 0..<ConfigManager.maxNumberOfSubCategory {
                if subCategoryStrings[i] != "" {
                    subCategoryStrings2[i] = subCategoryStrings[i]
                }
            }
        }
    }
}
