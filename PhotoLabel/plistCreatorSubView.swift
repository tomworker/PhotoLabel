//
//  plistCreatorSubView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct plistCreatorSubView: View {
    @Binding var subCategoryStrings: [String]
    var body: some View {
        List {
            Section(header: Text("Input Photo Label ") + Text("Details").font(.title)) {
                ForEach(0..<32) { item in
                    HStack {
                        Text(String(item + 1))
                            .frame(width: 25)
                        TextField("Details", text: $subCategoryStrings[item])
                    }
                }
            }
        }
        .listStyle(.grouped)
    }
}

