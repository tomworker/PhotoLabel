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
    @Binding var mainCategoryIds: [MainCategoryId]
    @State var targetMainCategoryIndex = -1
    @State var targetSubCategoryIndex = -1
    @State var targetImageFileIndex = -1
    @State var showImageView = false
    var columns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber)), spacing: 5), count: ConfigManager.imageColumnNumber)
    var columns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber)), spacing: 5), count: ConfigManager.iPadImageColumnNumber)

    var body: some View {
        ZStack {
            Text("Final Report")
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
            ForEach(mainCategoryIds) { mainCategoryId in
                HStack {
                    if let range = mainCategoryId.mainCategory.range(of: ":=") {
                        let idx = mainCategoryId.mainCategory.index(range.lowerBound, offsetBy: -1)
                        Text(mainCategoryId.mainCategory[...idx] + ":")
                            .bold()
                    }
                    Spacer()
                }
                ForEach(mainCategoryId.items) { subCategoryId in
                    HStack {
                        VStack(alignment: .leading) {
                            if let range = subCategoryId.subCategory.range(of: ":=") {
                                let idx = subCategoryId.subCategory.index(range.lowerBound, offsetBy: -1)
                                Text("- " + subCategoryId.subCategory[...idx])
                            }
                            if subCategoryId.countStoredImages == 0 {
                                Text("  N/A")
                            }
                        }
                        Spacer()
                    }
                    LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1) {
                        ForEach(CategoryManager.convertIdentifiable(imageFiles: subCategoryId.images, subFolderMode: mainCategoryId.subFolderMode, mainCategoryName: mainCategoryId.mainCategory, subCategoryName: subCategoryId.subCategory)) { imageFileId in
                            if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                Image(uiImage: ImageManager.downSize(uiimage: uiimage, scale: 0.3))
                                    .resizable()
                                    .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber) : (UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber) * 0.75 : uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber) : (UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber) * 0.75)
                                    .cornerRadius(10)
                                //Recovery code for onTapGesture problem
                                    .onChange(of: showImageView) { newValue in }
                                //Above code goes well for some reason.
                                    .onTapGesture(count: 1) {
                                        showImageView = true
                                        self.targetMainCategoryIndex = mainCategoryId.id
                                        self.targetSubCategoryIndex = subCategoryId.id
                                        self.targetImageFileIndex = imageFileId.id
                                    }
                                    .fullScreenCover(isPresented: $showImageView) {
                                        ImageTabView(fileUrl: $fileUrl, showImageView: $showImageView, targetImageFileIndex: self.targetImageFileIndex, imageFileIds: CategoryManager.convertIdentifiable(imageFiles: mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex].images, subFolderMode: mainCategoryIds[targetMainCategoryIndex].subFolderMode, mainCategoryName: mainCategoryIds[targetMainCategoryIndex].mainCategory, subCategoryName: mainCategoryIds[targetMainCategoryIndex].items[targetSubCategoryIndex].subCategory))
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}
