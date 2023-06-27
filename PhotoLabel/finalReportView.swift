//
//  finalReportView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct finalReportView: View {
    @Binding var showFinalReport: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @State var targetImageFile = ""
    @State var showImageView = false
    var columns1 = Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 5), count: 2)
    var columns2 = Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 5), count: 5)

    var body: some View {
        ScrollView {
            VStack {
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
                Spacer()
            }
            ForEach(mainCategoryIds) { mainCategoryId in
                HStack {
                    Text(mainCategoryId.mainCategory + ":")
                        .bold()
                    Spacer()
                }
                ForEach(mainCategoryId.items) { subCategoryId in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("- " + subCategoryId.subCategory)
                            if subCategoryId.countStoredImages == 0 {
                                Text("  N/A")
                            }
                        }
                        Spacer()
                    }
                    LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? columns2 : columns1) {
                        ForEach(CategoryManager.convertIdentifiable(imageFiles: subCategoryId.images)) { imageFileId in
                            if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                Image(uiImage: uiimage)
                                    .resizable()
                                    .aspectRatio(uiimage.size.width > uiimage.size.height ? 4 / 3 : uiimage.size.width == uiimage.size.height ? 1 : 3 / 4, contentMode: .fit)
                                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - 40 ) / 5 : (UIScreen.main.bounds.width - 40 ) / 5 * 3 / 4 : uiimage.size.width > uiimage.size.height ? (UIScreen.main.bounds.width - 10 ) / 2 : (UIScreen.main.bounds.width - 10 ) / 2 * 3 / 4)
                                    .cornerRadius(10)
                                    //Recovery code for onTapGesture problem
                                    .onChange(of: showImageView) { newValue in }
                                    //Above code goes well for some reason.
                                    .onTapGesture(count: 1) {
                                        showImageView = true
                                        self.targetImageFile = imageFileId.imageFile.imageFile
                                    }
                                    .fullScreenCover(isPresented: $showImageView) {
                                        ImageView(showImageView: $showImageView, imageFile: targetImageFile)
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}
