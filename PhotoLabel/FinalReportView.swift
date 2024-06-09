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
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    var columns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber)), spacing: 5), count: ConfigManager.imageColumnNumber)
    var columns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber)), spacing: 5), count: ConfigManager.iPadImageColumnNumber)

    var body: some View {
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
        ScrollView {
            ForEach(mainCategoryIds.indices, id: \.self) { mainCategoryIndex in
                HStack {
                    if let range = mainCategoryIds[mainCategoryIndex].mainCategory.range(of: ":=") {
                        let idx = mainCategoryIds[mainCategoryIndex].mainCategory.index(range.lowerBound, offsetBy: -1)
                        Text(mainCategoryIds[mainCategoryIndex].mainCategory[...idx] + ":")
                            .bold()
                    }
                    Spacer()
                }
                ForEach(mainCategoryIds[mainCategoryIndex].items.indices, id: \.self) { subCategoryIndex in
                    HStack {
                        VStack(alignment: .leading) {
                            if let range = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.range(of: ":=") {
                                let idx = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory.index(range.lowerBound, offsetBy: -1)
                                Text("- " + mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory[...idx])
                            }
                            if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages == 0 {
                                Text("  N/A")
                            }
                        }
                        Spacer()
                    }
                    LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1) {
                        ForEach(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.indices, id: \.self) { imageFileIndex in
                            if let uiimage = UIImage(contentsOfFile: tempDirectoryUrl.path + "/" + mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[imageFileIndex].imageFile) {
                                ZStack {
                                    Image(uiImage: downSizeImages[mainCategoryIndex][subCategoryIndex][imageFileIndex])
                                        .resizable()
                                        .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber) : (UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber) * 0.75 : uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber) : (UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber) * 0.75)
                                        .cornerRadius(10)
                                    //Recovery code for onTapGesture problem
                                        .onChange(of: showImageView) { }
                                    //Above code goes well for some reason.
                                        .onTapGesture(count: 1) {
                                            showImageView = true
                                            self.targetMainCategoryIndex = mainCategoryIndex
                                            self.targetSubCategoryIndex = subCategoryIndex
                                            self.targetImageFileIndex = imageFileIndex
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
}
