//
//  finalReportView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct FinalReportView: View {
    @Binding var showFinalReport: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @State var targetImageFile = ""
    @State var showImageView = false

    let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 2)
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
                    LazyVGrid(columns: columns) {
                        ForEach(CategoryManager.convertIdentifiable(imageFiles: subCategoryId.images)) { imageFileId in
                            if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                Image(uiImage: uiimage)
                                    .resizable()
                                    .frame(width: uiimage.size.width >= uiimage.size.height ? 180 : 135, height: uiimage.size.width >= uiimage.size.height ? 135 : 180)
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
