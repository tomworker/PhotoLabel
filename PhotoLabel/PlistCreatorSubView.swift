//
//  plistCreatorSubView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistCreatorSubView: View {
    @Binding var subCategoryStrings: [String]
    @State var subCategoryStrings2: [String] = Array(repeating: "", count: CategoryManager.maxNumberOfSubCategory)

    var body: some View {
        List {
            Section(header: Text("Input Photo Label ") + Text("Details").font(.title)) {
                ForEach(0..<CategoryManager.maxNumberOfSubCategory, id: \.self) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 25)
                        TextField("Details", text: $subCategoryStrings2[item])
                            .frame(maxWidth: .infinity)
                            .keyboardType(.default)
                    }
                    .onChange(of: subCategoryStrings2[item]) { newValue in
                        subCategoryStrings[item] = subCategoryStrings2[item]
                    }
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            for i in 0..<CategoryManager.maxNumberOfSubCategory {
                if subCategoryStrings[i] != "" {
                    subCategoryStrings2[i] = subCategoryStrings[i]
                }
            }
        }
    }
}
