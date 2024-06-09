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
    @Binding var showImageView3: Bool
    @Binding var targetImageFileIndex: Int
    let images: [ImageFile]
    let mainCategoryIndex: Int
    @Binding var subCategoryIndex: Int
    @Binding var downSizeImages: [[[UIImage]]]
    @Binding var mainCategoryIds: [MainCategoryId]
    @State var isDetectQRMode = false
    @State var isDetectTextMode = false
    @State var isShowMenuIcon = true
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)

    init(fileUrl: Binding<URL>, showImageView: Binding<Bool>, showImageView3: Binding<Bool>, targetImageFileIndex: Binding<Int>, images: [ImageFile], mainCategoryIndex: Int, subCategoryIndex: Binding<Int>, downSizeImages: Binding<[[[UIImage]]]>, mainCategoryIds: Binding<[MainCategoryId]>) {
        UIPageControl.appearance().isHidden = true
        self._fileUrl = fileUrl
        self._showImageView = showImageView
        self._showImageView3 = showImageView3
        self._targetImageFileIndex = targetImageFileIndex
        self.images = images
        self.mainCategoryIndex = mainCategoryIndex
        self._subCategoryIndex = subCategoryIndex
        self._downSizeImages = downSizeImages
        self._mainCategoryIds = mainCategoryIds
    }
    
    var body: some View {
        TabView(selection: $targetImageFileIndex) {
            ForEach(images.indices, id: \.self) { index in
                ImageView(fileUrl: $fileUrl, showImageView: $showImageView, showImageView3: $showImageView3, imageFile: tempDirectoryUrl.path + "/" + images[index].imageFile, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: $subCategoryIndex, targetImageFileIndex: $targetImageFileIndex, downSizeImages: $downSizeImages, mainCategoryIds: $mainCategoryIds, isDetectQRMode: $isDetectQRMode, isShowMenuIcon: $isShowMenuIcon, isDetectTextMode: $isDetectTextMode).tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}

