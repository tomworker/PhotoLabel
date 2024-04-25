//
//  PhotoLibraryImagePickerView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/07/23.
//

import SwiftUI
import PhotosUI

struct PhotoLibraryImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showImagePicker: Bool
    @State var images: [UIImage] = []
    @Binding var mainCategoryIds: [MainCategoryId]
    let mainCategoryIndex: Int
    let subCategoryIndex: Int
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    let fileUrl: URL
    @Binding var downSizeImages: [[[UIImage]]]
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)

    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryImagePickerView
        init(_ parent: PhotoLibraryImagePickerView) {
            self.parent = parent
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            var itemProvider: NSItemProvider
            for i in 0..<results.count {
                itemProvider = results[i].itemProvider
                itemProvider.canLoadObject(ofClass: UIImage.self)
                itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    guard let image = image as? UIImage else { return }
                    DispatchQueue.main.sync {
                        self.parent.images.append(image)
                        let jpgImageData = image.jpegData(compressionQuality: 0.5)
                        let workSpaceImageFileName = "@\(dateFormatter.string(from: Date()))\(String(i)).jpg"
                        let workSpaceJpgUrl = self.parent.tempDirectoryUrl.appendingPathComponent(workSpaceImageFileName)
                        let plistImageFileName = "\(dateFormatter.string(from: Date()))\(String(i)).jpg"
                        var plistJpgUrl = self.parent.tempDirectoryUrl.appendingPathComponent(plistImageFileName)
                        let duplicateSpaceImageFileName = plistImageFileName
                        do {
                            if self.parent.mainCategoryIds[self.parent.mainCategoryIndex].subFolderMode == 1 {
                                ZipManager.create(directoryUrl: self.parent.tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].subCategory)))
                                plistJpgUrl = self.parent.tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].subCategory)).appendingPathComponent(plistImageFileName)
                            }
                            try jpgImageData!.write(to: plistJpgUrl, options: .atomic)
                            self.parent.duplicateSpace.insert(DuplicateImageFile(imageFile: duplicateSpaceImageFileName, subFolderMode: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].subFolderMode, mainCategoryName: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].mainCategory, subCategoryName: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].subCategory), at: self.parent.duplicateSpace.count)
                            self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].images.insert(ImageFile(imageFile: plistImageFileName), at: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].images.count)
                            self.parent.downSizeImages[self.parent.mainCategoryIndex][self.parent.subCategoryIndex].append(UIImage(contentsOfFile: self.parent.tempDirectoryUrl.path + "/" + plistImageFileName)!.resize(targetSize: CGSize(width: 200, height: 200)))
                            self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].countStoredImages += 1
                        } catch {
                            print("Writing Jpg file failed with error:\(error)")
                        }
                        if i == results.count - 1 {
                            ZipManager.savePlistAndZip(fileUrl: self.parent.fileUrl, mainCategoryIds: self.parent.mainCategoryIds)
                        }
                    }
                }
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages >= ConfigManager.maxNumberOfImageFile {
            configuration.selectionLimit = 0
            presentationMode.wrappedValue.dismiss()
        } else {
            configuration.selectionLimit = ConfigManager.maxNumberOfImageFile - mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages
        }
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        //none
    }
}
