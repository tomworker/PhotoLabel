//
//  ImageStockerTabView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct ImageStockerTabView: View {
    @Binding var showImageStocker: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var fileUrl: URL
    @Binding var plistCategoryName: String
    @Binding var targetSubCategoryIndex: [Int]
    @Binding var downSizeImages: [[[UIImage]]]
    @EnvironmentObject var alertCenter: AlertCenter
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    
    init(showImageStocker: Binding<Bool>, mainCategoryIds: Binding<[MainCategoryId]>, workSpace: Binding<[WorkSpaceImageFile]>, fileUrl: Binding<URL>, plistCategoryName: Binding<String>, targetSubCategoryIndex: Binding<[Int]>, downSizeImages: Binding<[[[UIImage]]]>) {
        UIPageControl.appearance().isHidden = true
        self._showImageStocker = showImageStocker
        self._mainCategoryIds = mainCategoryIds
        self._workSpace = workSpace
        self._fileUrl = fileUrl
        self._plistCategoryName = plistCategoryName
        self._targetSubCategoryIndex = targetSubCategoryIndex
        self._downSizeImages = downSizeImages
    }

    var body: some View {
        TabView(selection: $targetSubCategoryIndex[1]) {
            ForEach(mainCategoryIds[targetSubCategoryIndex[0]].items.indices, id: \.self) {subCategoryIndex in
                EachTabView(showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: $targetSubCategoryIndex, tabSubCategoryIndex: subCategoryIndex, downSizeImages: $downSizeImages).tag(subCategoryIndex)
                    .alert(alertCenter.message?.title ?? "",
                           isPresented: Binding(
                                get: { alertCenter.message != nil },
                                set: { if !$0 { alertCenter.message = nil } }
                           )
                    ) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(alertCenter.message?.body ?? "")
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}
