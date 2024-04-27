//
//  ImageTabView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/07/27.
//

import SwiftUI

struct ImageTabView: View {
    @Binding var fileUrl: URL
    @Binding var showImageView: Bool
    @State var targetImageFileIndex: Int
    let images: [ImageFile]
    let mainCategoryIndex: Int
    let subCategoryIndex: Int
    @Binding var downSizeImages: [[[UIImage]]]
    @Binding var mainCategoryIds: [MainCategoryId]
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)

    var body: some View {
        TabView(selection: $targetImageFileIndex) {
            ForEach(images.indices, id: \.self) { index in
                ImageView(fileUrl: $fileUrl, showImageView: $showImageView, imageFile: tempDirectoryUrl.path + "/" + images[index].imageFile, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, imageFileIndex: index, downSizeImages: $downSizeImages, mainCategoryIds: $mainCategoryIds).tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}

