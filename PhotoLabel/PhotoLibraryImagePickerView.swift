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
    let sheetId: Int
    @Binding var showImagePicker: Bool
    @State var images: [UIImage] = []
    @Binding var mainCategoryIds: [MainCategoryId]
    let mainCategoryIndex: Int
    let subCategoryIndex: Int
    @Binding var workSpace: [WorkSpaceImageFile]
    @Binding var duplicateSpace: [DuplicateImageFile]
    let fileUrl: URL
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
                            switch self.parent.sheetId {
                            case 1:
                                try jpgImageData!.write(to: workSpaceJpgUrl, options: .atomic)
                                self.parent.workSpace.insert(WorkSpaceImageFile(imageFile: workSpaceImageFileName, subDirectory: ""), at: self.parent.workSpace.count)
                            case 2:
                                if self.parent.mainCategoryIds[self.parent.mainCategoryIndex].subFolderMode == 1 {
                                    ZipManager.create(directoryUrl: self.parent.tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].subCategory)))
                                    plistJpgUrl = self.parent.tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].subCategory)).appendingPathComponent(plistImageFileName)
                                }
                                try jpgImageData!.write(to: plistJpgUrl, options: .atomic)
                                self.parent.duplicateSpace.insert(DuplicateImageFile(imageFile: ImageFile(imageFile: duplicateSpaceImageFileName), subFolderMode: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].subFolderMode, mainCategoryName: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].mainCategory, subCategoryName: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].subCategory), at: self.parent.duplicateSpace.count)
                                self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].images.insert(ImageFile(imageFile: plistImageFileName), at: self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].images.count)
                                self.parent.mainCategoryIds[self.parent.mainCategoryIndex].items[self.parent.subCategoryIndex].countStoredImages += 1
                            default:
                                print("SheetId have failed to be found:\(self.parent.sheetId)")
                            }
                        } catch {
                            print("Writing Jpg file failed with error:\(error)")
                        }
                        if i == results.count - 1 {
                            switch self.parent.sheetId {
                            case 1:
                                ZipManager.savePlistAndZip(fileUrl: self.parent.fileUrl, mainCategoryIds: self.parent.mainCategoryIds)
                            case 2:
                                ZipManager.savePlistAndZip(fileUrl: self.parent.fileUrl, mainCategoryIds: self.parent.mainCategoryIds)
                                default:
                                print("SheetId have failed to be found:\(self.parent.sheetId)")
                            }
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
        switch sheetId {
        case 1:
            configuration.selectionLimit = ConfigManager.maxNumberOfImageFile
        case 2:
            if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages >= ConfigManager.maxNumberOfImageFile {
                configuration.selectionLimit = 0
                presentationMode.wrappedValue.dismiss()
            } else {
                configuration.selectionLimit = ConfigManager.maxNumberOfImageFile - mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages
            }
        default:
            print("SheetId has failed to be found:\(sheetId)")
        }
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        //none
    }
}
