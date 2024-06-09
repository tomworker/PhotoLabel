//
//  ImageStockerTabView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct ImageStockerTabView: View {
    @StateObject var photoCapture: PhotoCapture
    @Binding var showImageStocker: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    @Binding var fileUrl: URL
    @Binding var plistCategoryName: String
    @Binding var targetSubCategoryIndex: [Int]
    @Binding var downSizeImages: [[[UIImage]]]
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    
    init(photoCapture: StateObject<PhotoCapture>, showImageStocker: Binding<Bool>, mainCategoryIds: Binding<[MainCategoryId]>, workSpace: Binding<[WorkSpaceImageFile]>, duplicateSpace: Binding<[DuplicateImageFile]>, fileUrl: Binding<URL>, plistCategoryName: Binding<String>, targetSubCategoryIndex: Binding<[Int]>, downSizeImages: Binding<[[[UIImage]]]>) {
        UIPageControl.appearance().isHidden = true
        self._photoCapture = photoCapture
        self._showImageStocker = showImageStocker
        self._mainCategoryIds = mainCategoryIds
        self._workSpace = workSpace
        self._duplicateSpace = duplicateSpace
        self._fileUrl = fileUrl
        self._plistCategoryName = plistCategoryName
        self._targetSubCategoryIndex = targetSubCategoryIndex
        self._downSizeImages = downSizeImages
    }

    var body: some View {
        TabView(selection: $targetSubCategoryIndex[1]) {
            ForEach(mainCategoryIds[targetSubCategoryIndex[0]].items.indices, id: \.self) {subCategoryIndex in
                EachTabView(photoCapture: photoCapture, showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex, downSizeImages: $downSizeImages).tag(subCategoryIndex)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}
