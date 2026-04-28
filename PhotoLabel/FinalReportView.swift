//
//  finalReportView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct FinalReportView: View {
    @Binding var fileUrl: URL
    @Binding var showFinalReport: Bool
    @Binding var plistCategoryName: String
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var downSizeImages: [[[UIImage]]]
    @State var targetMainCategoryIndex = -1
    @State var targetSubCategoryIndex = -1
    @State var targetImageFileIndex = -1
    @State var showImageView = false
    @State var showImageView3 = false
    @ObservedObject var configManager = ConfigManager.shared
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    private var columns: [GridItem] {
        let count = UIDevice.current.userInterfaceIdiom == .pad ?
            configManager.iPadImageColumnNumber : configManager.imageColumnNumber
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            ScrollView {
                ForEach(mainCategoryIds.indices, id: \.self) { mainCategoryIndex in
                    HStack {
                        let rawStr = mainCategoryIds[mainCategoryIndex].mainCategory
                        if let range = rawStr.range(of: ":=") {
                            let title = rawStr[..<range.lowerBound]
                            Text(title + ":")
                                .bold()
                        }
                        Spacer()
                    }
                    ForEach(mainCategoryIds[mainCategoryIndex].items.indices, id: \.self) { subCategoryIndex in
                        HStack {
                            VStack(alignment: .leading) {
                                let rawStr = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory
                                let sCount = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages
                                if let range = rawStr.range(of: ":=") {
                                    let subTitle = rawStr[..<range.lowerBound]
                                    Text("- " + subTitle)
                                }
                                if sCount == 0 {
                                    Text("  N/A")
                                }
                            }
                            Spacer()
                        }
                        LazyVGrid(columns: columns) {
                            ForEach(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.indices, id: \.self) { imageFileIndex in
                                let uiimage = downSizeImages[mainCategoryIndex][subCategoryIndex][imageFileIndex]
                                ZStack {
                                    Image(uiImage: uiimage)
                                        .resizable()
                                        .aspectRatio(uiimage.displayAspectRatio, contentMode: .fit)
                                        .frame(width: calculateImageWidth(uiImage: uiimage))
                                        .cornerRadius(10)
                                        // Recovery code for onTapGesture problem
                                        .onDataChange(of: showImageView) { _ in }
                                        // Above code goes well for some reason.
                                        .onTapGesture(count: 1) {
                                            showImageView = true
                                            targetMainCategoryIndex = mainCategoryIndex
                                            targetSubCategoryIndex = subCategoryIndex
                                            targetImageFileIndex = imageFileIndex
                                        }
                                    if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageInfo != "" {
                                        Text("with image info")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.5))
                                            .background(.black.opacity(0.5))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showImageView) {
            ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView, showImageView3: $showImageView3, targetImageFileIndex: $targetImageFileIndex, images: mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex].images, mainCategoryIndex: targetMainCategoryIndex, subCategoryIndex: $targetSubCategoryIndex, downSizeImages: $downSizeImages, mainCategoryIds: $mainCategoryIds)
        }
        .fullScreenCover(isPresented: $showImageView3) {
            VStack { } //dummmy
            ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView, showImageView3: $showImageView3, targetImageFileIndex: $targetImageFileIndex, images: mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex].images, mainCategoryIndex: targetMainCategoryIndex, subCategoryIndex: $targetSubCategoryIndex, downSizeImages: $downSizeImages, mainCategoryIds: $mainCategoryIds)
        }
    }
    private func calculateImageWidth(uiImage: UIImage) -> CGFloat {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let columnCount = CGFloat(isPad ? configManager.iPadImageColumnNumber : configManager.imageColumnNumber)
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 10
        let totalSpacing = (columnCount - 1) * spacing
        let baseWidth = (screenWidth - totalSpacing) / columnCount
        let isLandscape = uiImage.size.width > uiImage.size.height
        return isLandscape ? baseWidth : baseWidth * 0.75
    }
    private var headerView: some View {
        ZStack {
            Text(plistCategoryName.replacingOccurrences(of: "_", with: " / "))
                .bold()
            HStack {
                Spacer()
                Button {
                    showFinalReport = false
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 30, height: 30)
                        .background(.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.trailing)
                }
            }
        }
    }
}
