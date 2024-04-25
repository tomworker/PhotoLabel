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

    var body: some View {
        TabView(selection: $targetSubCategoryIndex[1]) {
            ForEach(mainCategoryIds[targetSubCategoryIndex[0]].items.indices, id: \.self) {subCategoryIndex in
                EachTabView(photoCapture: photoCapture, showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: .constant([targetSubCategoryIndex[0], subCategoryIndex]), downSizeImages: $downSizeImages).tag(subCategoryIndex)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}
