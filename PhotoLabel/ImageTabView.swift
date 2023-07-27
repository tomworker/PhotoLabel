//
//  ImageTabView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/07/27.
//

import SwiftUI

struct ImageTabView: View {
    @Binding var showImageView: Bool
    @State var targetImageFileIndex: Int
    let imageFileIds: [ImageFileId]

    var body: some View {
        TabView(selection: $targetImageFileIndex) {
            ForEach(imageFileIds.indices, id: \.self) { index in
                ImageView(showImageView: $showImageView, imageFile: imageFileIds[index].imageFile.imageFile).tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}

