//
//  plistCreatorSubView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistCreatorSubView: View {
    @Binding var subCategoryStrings: [String]
    @ObservedObject var configManager = ConfigManager.shared
    @State var subCategoryStrings2: [String]
    
    init(subCategoryStrings: Binding<[String]>) {
        self._subCategoryStrings = subCategoryStrings
        let count = ConfigManager.shared.maxNumberOfSubCategory
        self._subCategoryStrings2 = State(initialValue: Array(repeating: "", count: count))
    }
 
    var body: some View {
        List {
            Section(header: Text("Input Photo Label ") + Text("Detail").font(.title)) {
                ForEach(0..<configManager.maxNumberOfSubCategory, id: \.self) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 35)
                        TextField("Detail", text: $subCategoryStrings2[item])
                            .frame(maxWidth: .infinity)
                            .keyboardType(.default)
                    }
                    .onDataChange(of: subCategoryStrings2[item]) { _ in
                        subCategoryStrings[item] = subCategoryStrings2[item]
                    }
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            for i in 0..<configManager.maxNumberOfSubCategory {
                if subCategoryStrings[i] != "" {
                    subCategoryStrings2[i] = subCategoryStrings[i]
                }
            }
        }
    }
}
