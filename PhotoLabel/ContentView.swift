//
//  ContentView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI
import ZIPFoundation

struct ContentView: View {
    @State var mainCategoryIds: [MainCategoryId] = []
    @State var workSpace: [WorkSpaceImageFile] = []
    @State var duplicateSpace: [DuplicateImageFile] = []
    @State private var fileUrl: URL?
    @State var showPlistCreator = false
    @State var showPlistEditor1: [Bool]
    @State var showPlistEditor2: [Bool]
    @State private var showDocumentPicker = false
    @State var showCategorySelector1: [Bool]
    @State var showCategorySelector2: [Bool]
    @State var showConfig = false
    @State var isCancelLoad = false
    @State var cancelLoadMessage = ""
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    @State var documentDirectoryFiles: [String] = []
    @State var isChangeFlag = false
    @State var isRenameFlag = false
    @State var plistName = ""
    @State var targetRenameFile = ""
    @State var afterRenameFile = ""
    
    var body: some View {
        Button {
        } label: {
            VStack(spacing: 0) {
                HStack {
                    ZStack(alignment: .top) {
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(20)
                        Image(systemName: "camera").font(.system(size: 50))
                            .frame(width: 100, height: 79)
                            .foregroundColor(.white)
                            .background(.clear)
                            .cornerRadius(10)
                        Text("Label")
                            .baselineOffset(-59)
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                    }
                    .padding(.leading)
                    Spacer()
                    VStack {
                        HStack {
                            ZStack(alignment: .top) {
                                Image(systemName: "doc").font(.system(size:50))
                                    .baselineOffset(0)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.indigo)
                                    .background(.clear)
                                Text(".plist")
                                    .frame(width: 50, height: 50)
                                    .baselineOffset(-10)
                                    .foregroundColor(.indigo)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                            }
                            Image(systemName: "arrow.right").font(.system(size:20))
                                .baselineOffset(0)
                                .frame(width: 5, height: 50)
                                .foregroundColor(.indigo)
                                .background(.clear)
                                .fontWeight(.bold)
                            ZStack(alignment: .top) {
                                Image(systemName: "doc").font(.system(size:50))
                                    .baselineOffset(0)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.indigo)
                                    .background(.clear)
                                Text("&img")
                                    .frame(width: 50, height: 50)
                                    .baselineOffset(-5)
                                    .foregroundColor(.indigo)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                                Text(".plist")
                                    .frame(width: 50, height: 50)
                                    .baselineOffset(-25)
                                    .foregroundColor(.indigo)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                            }
                            Image(systemName: "plus").font(.system(size:20))
                                .baselineOffset(0)
                                .frame(width: 5, height: 50)
                                .foregroundColor(.indigo)
                                .background(.clear)
                                .fontWeight(.bold)
                            ZStack(alignment: .top) {
                                Image(systemName: "doc").font(.system(size:50))
                                    .baselineOffset(0)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.indigo)
                                    .background(.clear)
                                Text("ZIP")
                                    .frame(width: 50, height: 50)
                                    .baselineOffset(-10)
                                    .foregroundColor(.indigo)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                            }
                        }
                        HStack {
                            ZStack(alignment: .top) {
                                Text("Photo")
                                    .frame(width: 50, height: 10)
                                    .baselineOffset(10)
                                    .foregroundColor(.indigo)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                                Text("Labels")
                                    .frame(width: 50, height: 10)
                                    .baselineOffset(-10)
                                    .foregroundColor(.indigo)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                            }
                            Rectangle()
                                .frame(width: 5, height: 10)
                                .foregroundColor(.clear)
                            Image(systemName: "link").font(.system(size:15))
                                .baselineOffset(0)
                                .frame(width: 50, height: 10)
                                .foregroundColor(.indigo)
                                .background(.clear)
                            Rectangle()
                                .frame(width: 5, height: 10)
                                .foregroundColor(.clear)
                            Text("Photos")
                                .frame(width: 50, height: 10)
                                .baselineOffset(0)
                                .foregroundColor(.indigo)
                                .font(.system(size: 10))
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.trailing)
                }
            }
        }
        HStack {
            Button {
                showConfig = true
            } label: {
                Image(systemName: "gearshape")
                    .frame(width: 50, height: 30)
                    .background(.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.leading)
            }
            .fullScreenCover(isPresented: $showConfig) {
                ConfigView(showConfig: $showConfig)
            }
            Spacer()
            Button {
                showPlistCreator = true
            } label: {
                Text("New Photo Labels")
                    .frame(width: 180, height: 30)
                    .background(LinearGradient(gradient: Gradient(colors: [.indigo, .purple, .red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    //.padding(.trailing)
            }
            .onChange(of: showPlistCreator || isChangeFlag) { newValue in
                showPlistList()
            }
            .onAppear {
                let jsonUrl = documentDirectoryUrl.appendingPathComponent("config.json")
                if FileManager.default.fileExists(atPath: jsonUrl.path) {
                    let config = JsonManager.load(fileUrl: jsonUrl)
                    ConfigManager.iPadMainColumnNumber = config.iPadMaxColCatBtn
                    ConfigManager.iPadSubColumnNumber = config.iPadMaxColDetBtn
                    ConfigManager.iPadImageColumnNumber = config.iPadMaxColPhoto
                    ConfigManager.mainColumnNumber = config.maxColCatBtn
                    ConfigManager.subColumnNumber = config.maxColDetBtn
                    ConfigManager.imageColumnNumber = config.maxColPhoto
                    ConfigManager.iPadMainRowNumber = config.iPadMaxRowCatBtn
                    ConfigManager.iPadSubRowNumber = config.iPadMaxRowDetBtn
                    ConfigManager.mainRowNumber = config.maxRowCatBtn
                    ConfigManager.subRowNumber = config.maxRowDetBtn
                    ConfigManager.maxNumberOfMainCategory = config.maxEntCat
                    ConfigManager.maxNumberOfSubCategory = config.maxEntDet
                    ConfigManager.maxNumberOfImageFile = config.maxEntPhoto
                }
                showPlistList()
            }
            .fullScreenCover(isPresented: $showPlistCreator) {
                PlistCreatorView(showPlistCreator: $showPlistCreator)
            }
            Button {
                showPlistList()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 30, height: 30)
                    .background(.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.trailing)
            }
        }
        VStack {
            List {
                Section(header: Text("Photo Label").font(.title) + Text(" Plist (XML File)")) {
                    ForEach(documentDirectoryFiles.indices, id:\.self) { item in
                        if documentDirectoryFiles[item].suffix(6) == ".plist" && documentDirectoryFiles[item].suffix(10) != "&img.plist" {
                            let targetPlistUrl = documentDirectoryUrl.appendingPathComponent(documentDirectoryFiles[item])
                            Button {
                                loadPlist(fileUrl: targetPlistUrl, showCategorySelector: &showCategorySelector1[item])
                            } label: {
                                Text(documentDirectoryFiles[item])
                            }
                            .onChange(of: showPlistEditor1[item]) { newValue in
                                showPlistListEdit()
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    ZipManager.remove(fileUrl: targetPlistUrl)
                                    isChangeFlag.toggle()
                                } label : {
                                    Label("Remove", systemImage: "trash")
                                }
                                Button {
                                    showPlistEditor1[item] = true
                                    plistName = documentDirectoryFiles[item]
                                    plistName = plistName.replacingOccurrences(of: ".plist", with: "")
                                } label : {
                                    Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                                }
                                .tint(.blue)
                            }
                            .alert(isPresented: $isCancelLoad) {
                                Alert(title: Text("Notice"), message: Text(cancelLoadMessage))
                            }
                            .fullScreenCover(isPresented: $showCategorySelector1[item]) {
                                let mainCategoryIds: [MainCategoryId] = CategoryManager.convertIdentifiable(mainCategorys: CategoryManager.load(fileUrl: targetPlistUrl))
                                CategorySelectorView(showCategorySelector: $showCategorySelector1[item], mainCategoryIds: mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: targetPlistUrl, plistCategoryName: targetPlistUrl.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "&img", with: ""))
                            }
                            .fullScreenCover(isPresented: $showPlistEditor1[item]) {
                                let mainCategoryIds: [MainCategoryId] = CategoryManager.convertIdentifiable(mainCategorys: CategoryManager.load(fileUrl: targetPlistUrl))
                                PlistEditorView(showPlistEditor: $showPlistEditor1[item], plistName: plistName, mainCategoryIds: mainCategoryIds)
                            }
                        }
                    }
                }
                Section(header: Text("Photo Link Label").font(.title2) + Text(" &img.plist links photo labels to photos")) {
                    ForEach(documentDirectoryFiles.indices, id:\.self) { item in
                        if documentDirectoryFiles[item].suffix(10) == "&img.plist" {
                            let targetPlistUrl = documentDirectoryUrl.appendingPathComponent(documentDirectoryFiles[item])
                            HStack {
                                Button {
                                    loadPlist(fileUrl: targetPlistUrl, showCategorySelector: &showCategorySelector2[item])
                                } label: {
                                    Text(documentDirectoryFiles[item])
                                }
                                .onChange(of: showPlistEditor2[item]) { newValue in
                                    showPlistListEdit()
                                }
                                .swipeActions {
                                    Button {
                                        showPlistEditor2[item] = true
                                        plistName = documentDirectoryFiles[item]
                                        plistName = plistName.replacingOccurrences(of: ".plist", with: "")
                                    } label : {
                                        Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                                    }
                                    .tint(.blue)
                                }
                                .alert(isPresented: $isCancelLoad) {
                                    Alert(title: Text("Notice"), message: Text(cancelLoadMessage))
                                }
                                .fullScreenCover(isPresented: $showCategorySelector2[item]) {
                                    let mainCategoryIds: [MainCategoryId] = CategoryManager.convertIdentifiable(mainCategorys: CategoryManager.load(fileUrl: targetPlistUrl))
                                    CategorySelectorView(showCategorySelector: $showCategorySelector2[item], mainCategoryIds: mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: targetPlistUrl, plistCategoryName: targetPlistUrl.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "&img", with: ""))
                                }
                                .fullScreenCover(isPresented: $showPlistEditor2[item]) {
                                    let mainCategoryIds: [MainCategoryId] = CategoryManager.convertIdentifiable(mainCategorys: CategoryManager.load(fileUrl: targetPlistUrl))
                                    PlistEditorView(showPlistEditor: $showPlistEditor2[item], plistName: plistName, mainCategoryIds: mainCategoryIds)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            Spacer()
        }
    }
    private func showPlistList() {
        ZipManager.create(directoryUrl: tempDirectoryUrl)
        do {
            documentDirectoryFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: documentDirectoryUrl.path)
            showPlistEditor1 = Array(repeating: false, count: documentDirectoryFiles.count)
            showPlistEditor2 = Array(repeating: false, count: documentDirectoryFiles.count)
            showCategorySelector1 = Array(repeating: false, count: documentDirectoryFiles.count)
            showCategorySelector2 = Array(repeating: false, count: documentDirectoryFiles.count)
        } catch {
            print(error)
        }
        documentDirectoryFiles.sort { $0.description < $1.description}
    }
    private func showPlistListEdit() {
        ZipManager.create(directoryUrl: tempDirectoryUrl)
        do {
            documentDirectoryFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: documentDirectoryUrl.path)
            //showPlistEditor1 = Array(repeating: false, count: documentDirectoryFiles.count)
            //showPlistEditor2 = Array(repeating: false, count: documentDirectoryFiles.count)
            showCategorySelector1 = Array(repeating: false, count: documentDirectoryFiles.count)
            showCategorySelector2 = Array(repeating: false, count: documentDirectoryFiles.count)
        } catch {
            print(error)
        }
        documentDirectoryFiles.sort { $0.description < $1.description}
    }
    private func loadPlist(fileUrl: URL, showCategorySelector: inout Bool) {
        showCategorySelector = true
        isCancelLoad = false
        ZipManager.remove(directoryUrl: tempDirectoryUrl)
        var plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
        if let range = plistNoExtensionName.range(of: "&img") {
            plistNoExtensionName.replaceSubrange(range, with: "")
            let zipUrl = documentDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".zip")
            if ZipManager.fileManager.fileExists(atPath: zipUrl.path) {
                ZipManager.unzipDirectory(zipUrl: zipUrl, directoryUrl: documentDirectoryUrl)
                ZipManager.rename(atFileUrl: documentDirectoryUrl.appendingPathComponent(plistNoExtensionName, isDirectory: true), toFileUrl: tempDirectoryUrl)
            } else {
                showCategorySelector = false
                isCancelLoad = true
                cancelLoadMessage = "Loading plist has been canceled because the following files are required in the same folder:\n\(zipUrl.lastPathComponent)"
            }
        } else {
            let plistUrl = documentDirectoryUrl.appendingPathComponent(plistNoExtensionName + "&img.plist")
            let zipUrl = documentDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".zip")
            cancelLoadMessage = "Loading plist has been canceled because the following files exist in the same folder:"
            if ZipManager.fileManager.fileExists(atPath: plistUrl.path) {
                showCategorySelector = false
                isCancelLoad = true
                cancelLoadMessage += "\n\(plistUrl.lastPathComponent)"
            }
            if ZipManager.fileManager.fileExists(atPath: zipUrl.path) {
                showCategorySelector = false
                isCancelLoad = true
                cancelLoadMessage += "\n\(zipUrl.lastPathComponent)"
            }
            if isCancelLoad == false {
                ZipManager.create(directoryUrl: tempDirectoryUrl)
            }
        }
        let tempImageFiles: [String]
        var tempImageFile: String
        do {
            tempImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: tempDirectoryUrl.path)
            workSpace = []
            duplicateSpace = []
            for i in 0..<tempImageFiles.count {
                var isDir: ObjCBool = false
                tempImageFile = tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]).path
                if ZipManager.fileManager.fileExists(atPath: tempImageFile, isDirectory: &isDir) {
                    if isDir.boolValue {
                        let subDirImageFiles: [String]
                        do {
                            subDirImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: tempImageFile)
                            for j in 0..<subDirImageFiles.count {
                                if subDirImageFiles[j].first == "@" {
                                    workSpace.append(WorkSpaceImageFile(imageFile: subDirImageFiles[j], subDirectory: tempImageFiles[i]))
                                }
                            }
                        }
                    } else {
                        if tempImageFiles[i].first == "@" {
                            workSpace.append(WorkSpaceImageFile(imageFile: tempImageFiles[i], subDirectory: ""))
                        }
                    }
                }
            }
        } catch {
            print("Temp image files have failed to be obtained:\(error)")
        }
        let initialMainCategorys = CategoryManager.load(fileUrl: fileUrl)
        for i in 0..<initialMainCategorys.count {
            let mainCategoryName = initialMainCategorys[i].mainCategory
            for j in 0..<initialMainCategorys[i].items.count {
                let subCategoryName = initialMainCategorys[i].items[j].subCategory
                for k in 0..<initialMainCategorys[i].items[j].images.count {
                    duplicateSpace.append(DuplicateImageFile(imageFile: ImageFile(imageFile: initialMainCategorys[i].items[j].images[k].imageFile), mainCategoryName: mainCategoryName, subCategoryName: subCategoryName))
                }
            }
        }
    }
}

struct ImageFile: Decodable, Encodable, Equatable {
    let imageFile: String
}
struct SubCategory: Decodable, Encodable {
    let subCategory: String
    var countStoredImages: Int
    var images: [ImageFile]
}
struct MainCategory: Decodable, Encodable {
    let mainCategory: String
    let items: [SubCategory]
}
struct ImageFileId: Identifiable {
    var id: Int
    let imageFile: ImageFile
}
struct SubCategoryId: Identifiable {
    var id: Int
    let subCategory: String
    var countStoredImages: Int
    var images: [ImageFile]
    var isTargeted: Bool
}
struct MainCategoryId: Identifiable {
    var id: Int
    let mainCategory: String
    var items: [SubCategoryId]
}
struct WorkSpaceImageFile: Equatable {
    let imageFile: String
    let subDirectory: String
}
struct WorkSpaceImageFileId: Identifiable {
    let id: Int
    let workSpaceImageFile: WorkSpaceImageFile
}
struct DuplicateImageFile: Equatable {
    let imageFile: ImageFile
    let mainCategoryName: String
    let subCategoryName: String
}
struct DuplicateImageFileId: Identifiable{
    var id: Int
    let duplicateImageFile: DuplicateImageFile
}
class ConfigManager {
    static var iPadMainColumnNumber = 6
    static var iPadSubColumnNumber = 4
    static var iPadImageColumnNumber = 5
    static var mainColumnNumber = 3
    static var subColumnNumber = 2
    static var imageColumnNumber = 2
    static var iPadMainRowNumber = 5
    static var iPadSubRowNumber = 5
    static var mainRowNumber = 3
    static var subRowNumber = 3
    static var maxNumberOfMainCategory = 99
    static var maxNumberOfSubCategory = 99
    static var maxNumberOfImageFile = 99
    static let initialIPadMainColumnNumber = 6
    static let initialIPadSubColumnNumber = 4
    static let initialIPadImageColumnNumber = 5
    static let initialMainColumnNumber = 3
    static let initialSubColumnNumber = 2
    static let initialImageColumnNumber = 2
    static let initialIPadMainRowNumber = 5
    static let initialIPadSubRowNumber = 5
    static let initialMainRowNumber = 3
    static let initialSubRowNumber = 3
    static let initialMaxNumberOfMainCategory = 99
    static let initialMaxNumberOfSubCategory = 99
    static let initialMaxNumberOfImageFile = 99
}
class CategoryManager {
    static let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    static let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static func write(fileUrl: URL, mainCategorys: [MainCategory]) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        guard let data = try? encoder.encode(mainCategorys) else { return }
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            try? data.write(to: fileUrl)
        } else {
            FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
        }
    }
    static func load(fileUrl: URL) -> [MainCategory] {
        let decoder = PropertyListDecoder()
        do {
            let data = try Data.init(contentsOf: fileUrl)
            let mainCategorys = try decoder.decode([MainCategory].self, from: data)
            return mainCategorys
        } catch {
            print(error)
            return [MainCategory(mainCategory: "", items: [SubCategory(subCategory: "", countStoredImages: 0, images: [ImageFile(imageFile: "")])])]
        }
    }
    static func convertIdentifiable(workSpaceImageFiles: [WorkSpaceImageFile]) -> [WorkSpaceImageFileId] {
        var workSpaceImageFileIds: [WorkSpaceImageFileId] = []
        for i in 0..<workSpaceImageFiles.count {
            if workSpaceImageFiles[i].subDirectory != "" {
                workSpaceImageFileIds.append(WorkSpaceImageFileId(id: i, workSpaceImageFile: WorkSpaceImageFile(imageFile: tempDirectoryUrl.path + "/" + workSpaceImageFiles[i].subDirectory + "/" + workSpaceImageFiles[i].imageFile, subDirectory: workSpaceImageFiles[i].subDirectory)))
            } else {
                workSpaceImageFileIds.append(WorkSpaceImageFileId(id: i, workSpaceImageFile: WorkSpaceImageFile(imageFile: tempDirectoryUrl.path + "/" + workSpaceImageFiles[i].imageFile, subDirectory: workSpaceImageFiles[i].subDirectory)))
            }
        }
        return workSpaceImageFileIds
    }
    static func convertIdentifiable(duplicateImageFiles: [DuplicateImageFile]) -> [DuplicateImageFileId] {
        var duplicateImageFileIds: [DuplicateImageFileId] = []
        for i in 0..<duplicateImageFiles.count {
            duplicateImageFileIds.append(DuplicateImageFileId(id: i, duplicateImageFile: DuplicateImageFile(imageFile: ImageFile(imageFile: tempDirectoryUrl.path + "/" + duplicateImageFiles[i].imageFile.imageFile), mainCategoryName: duplicateImageFiles[i].mainCategoryName, subCategoryName: duplicateImageFiles[i].subCategoryName)))
        }
        return duplicateImageFileIds
    }
    static func convertIdentifiable(imageFiles: [ImageFile]) -> [ImageFileId] {
        var imageFileIds: [ImageFileId] = []
        for i in 0..<imageFiles.count {
            imageFileIds.append(ImageFileId(id: i, imageFile: ImageFile(imageFile: tempDirectoryUrl.path + "/" + imageFiles[i].imageFile)))
        }
        return imageFileIds
    }
    static func convertIdentifiable(subCategorys: [SubCategory]) -> [SubCategoryId] {
        var subCategoryIds: [SubCategoryId] = []
        for i in 0..<subCategorys.count {
            subCategoryIds.append(SubCategoryId(id: i, subCategory: subCategorys[i].subCategory, countStoredImages: subCategorys[i].countStoredImages, images: subCategorys[i].images, isTargeted: false))
        }
        return subCategoryIds
    }
    static func convertIdentifiable(mainCategorys: [MainCategory]) -> [MainCategoryId] {
        var mainCategoryIds: [MainCategoryId] = []
        for i in 0..<mainCategorys.count {
            mainCategoryIds.append(MainCategoryId(id: i, mainCategory: mainCategorys[i].mainCategory, items: convertIdentifiable(subCategorys: mainCategorys[i].items)))
        }
        return mainCategoryIds
    }
    static func convertNoIdentifiable(subCategoryIds: [SubCategoryId]) -> [SubCategory] {
        var subCategorys: [SubCategory] = []
        for i in 0..<subCategoryIds.count {
            subCategorys.append(SubCategory(subCategory: subCategoryIds[i].subCategory, countStoredImages: subCategoryIds[i].countStoredImages, images: subCategoryIds[i].images))
        }
        return subCategorys
    }
    static func convertNoIdentifiable(mainCategoryIds: [MainCategoryId]) -> [MainCategory] {
        var mainCategorys: [MainCategory] = []
        for i in 0..<mainCategoryIds.count {
            mainCategorys.append(MainCategory(mainCategory: mainCategoryIds[i].mainCategory, items: convertNoIdentifiable(subCategoryIds: mainCategoryIds[i].items)))
        }
        return mainCategorys
    }
    static func reorderItems(image: ImageFileId, indexs: [String], imageSpace: inout [ImageFile]) {
        let moveToIndex = image.id
        let targetIndex = Int(indexs.first!)!
        let lastIndex = imageSpace.count - 1
        var imageSpace2: [ImageFile] = []
        if moveToIndex <= targetIndex {
            if moveToIndex != 0 {
                imageSpace2 += imageSpace[0...moveToIndex - 1]
            }
            imageSpace2 += imageSpace[targetIndex...targetIndex]
            if moveToIndex != targetIndex {
                imageSpace2 += imageSpace[moveToIndex...targetIndex - 1]
            }
            if targetIndex != lastIndex {
                imageSpace2 += imageSpace[targetIndex + 1...lastIndex]
            }
        }
        if moveToIndex > targetIndex {
            if targetIndex != 0 {
                imageSpace2 += imageSpace[0...targetIndex - 1]
            }
            if moveToIndex != targetIndex + 1 {
                imageSpace2 += imageSpace[targetIndex + 1...moveToIndex - 1]
            }
            imageSpace2 += imageSpace[targetIndex...targetIndex]
            imageSpace2 += imageSpace[moveToIndex...lastIndex]
        }
        imageSpace = imageSpace2
    }
    static func reorderItems(image: WorkSpaceImageFileId, indexs: [String], workSpace: inout [WorkSpaceImageFile]) {
        let moveToIndex = image.id
        let targetIndex = Int(indexs.first!)!
        let lastIndex = workSpace.count - 1
        var workSpace2: [WorkSpaceImageFile] = []
        if moveToIndex <= targetIndex {
            if moveToIndex != 0 {
                workSpace2 += workSpace[0...moveToIndex - 1]
            }
            workSpace2 += workSpace[targetIndex...targetIndex]
            if moveToIndex != targetIndex {
                workSpace2 += workSpace[moveToIndex...targetIndex - 1]
            }
            if targetIndex != lastIndex {
                workSpace2 += workSpace[targetIndex + 1...lastIndex]
            }
        }
        if moveToIndex > targetIndex {
            if targetIndex != 0 {
                workSpace2 += workSpace[0...targetIndex - 1]
            }
            if moveToIndex != targetIndex + 1 {
                workSpace2 += workSpace[targetIndex + 1...moveToIndex - 1]
            }
            workSpace2 += workSpace[targetIndex...targetIndex]
            workSpace2 += workSpace[moveToIndex...lastIndex]
        }
        workSpace = workSpace2
    }
    static func reorderItems(image: DuplicateImageFileId, indexs: [String], duplicateSpace: inout [DuplicateImageFile]) {
        let moveToIndex = image.id
        let targetIndex = Int(indexs.first!)!
        let lastIndex = duplicateSpace.count - 1
        var duplicateSpace2: [DuplicateImageFile] = []
        if moveToIndex <= targetIndex {
            if moveToIndex != 0 {
                duplicateSpace2 += duplicateSpace[0...moveToIndex - 1]
            }
            duplicateSpace2 += duplicateSpace[targetIndex...targetIndex]
            if moveToIndex != targetIndex {
                duplicateSpace2 += duplicateSpace[moveToIndex...targetIndex - 1]
            }
            if targetIndex != lastIndex {
                duplicateSpace2 += duplicateSpace[targetIndex + 1...lastIndex]
            }
        }
        if moveToIndex > targetIndex {
            if targetIndex != 0 {
                duplicateSpace2 += duplicateSpace[0...targetIndex - 1]
            }
            if moveToIndex != targetIndex + 1 {
                duplicateSpace2 += duplicateSpace[targetIndex + 1...moveToIndex - 1]
            }
            duplicateSpace2 += duplicateSpace[targetIndex...targetIndex]
            duplicateSpace2 += duplicateSpace[moveToIndex...lastIndex]
        }
        duplicateSpace = duplicateSpace2
    }
    static func moveItemFromLastToFirst(image: ImageFileId, imageSpace: inout [ImageFile]) {
        let targetIndex = image.id
        let lastIndex = imageSpace.count - 1
        var imageSpace2: [ImageFile] = []
        if targetIndex > 0 {
            imageSpace2 += imageSpace[targetIndex...targetIndex]
            imageSpace2 += imageSpace[0...targetIndex - 1]
            if targetIndex != lastIndex {
                imageSpace2 += imageSpace[targetIndex + 1...lastIndex]
            }
            imageSpace = imageSpace2
        }
    }
    static func moveItemFromLastToFirst(image: WorkSpaceImageFileId, workSpace: inout [WorkSpaceImageFile]) {
        let targetIndex = image.id
        let lastIndex = workSpace.count - 1
        var workSpace2: [WorkSpaceImageFile] = []
        if targetIndex > 0 {
            workSpace2 += workSpace[targetIndex...targetIndex]
            workSpace2 += workSpace[0...targetIndex - 1]
            if targetIndex != lastIndex {
                workSpace2 += workSpace[targetIndex + 1...lastIndex]
            }
            workSpace = workSpace2
        }
    }
    static func moveItemFromLastToFirst(image: DuplicateImageFileId, duplicateSpace: inout [DuplicateImageFile]) {
        let targetIndex = image.id
        let lastIndex = duplicateSpace.count - 1
        var duplicateSpace2: [DuplicateImageFile] = []
        if targetIndex > 0 {
            duplicateSpace2 += duplicateSpace[targetIndex...targetIndex]
            duplicateSpace2 += duplicateSpace[0...targetIndex - 1]
            if targetIndex != lastIndex {
                duplicateSpace2 += duplicateSpace[targetIndex + 1...lastIndex]
            }
            duplicateSpace = duplicateSpace2
        }
    }
}
class ZipManager {
    static let fileManager = FileManager.default
    static let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    static let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static func moveImagesFromWorkSpaceToTrashBox(images: [String], workSpace: inout [WorkSpaceImageFile]) {
        let workSpaceImageFile = workSpace[Int(images.first!)!].imageFile
        ZipManager.remove(fileUrl: tempDirectoryUrl.appendingPathComponent(workSpaceImageFile))
        workSpace.removeAll(where: {$0 == WorkSpaceImageFile(imageFile: workSpaceImageFile, subDirectory: "")})
    }
    static func moveImagesFromPlistToWorkSpace(images: [String], mainCategoryIds: inout [MainCategoryId], mainCategoryIndex: Int, subCategoryIndex: Int, workSpace: inout [WorkSpaceImageFile], duplicateSpace: inout [DuplicateImageFile]) {
        let targetImageFile = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[Int(images.first!)!].imageFile
        let workSpaceImageFile = "@\(targetImageFile)"
        let beforeRenameUrl = tempDirectoryUrl.appendingPathComponent(targetImageFile)
        let afterRenameUrl = tempDirectoryUrl.appendingPathComponent(workSpaceImageFile)
        ZipManager.rename(atFileUrl: beforeRenameUrl, toFileUrl: afterRenameUrl)
        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.removeAll(where: { $0 == ImageFile(imageFile: targetImageFile)})
        duplicateSpace.removeAll(where: {$0.imageFile == ImageFile(imageFile: targetImageFile)})
        workSpace.append(WorkSpaceImageFile(imageFile: workSpaceImageFile, subDirectory: ""))
        print("Removed from plist:\(targetImageFile)")
        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages -= 1
    }
    static func moveImagesFromWorkSpaceToPlist(images: [String], mainCategoryIds: inout [MainCategoryId], mainCategoryIndex: Int, subCategoryIndex: Int, workSpace: inout [WorkSpaceImageFile]) {
        let workSpaceImageFile = workSpace[Int(images.first!)!].imageFile
        let subDirectory = workSpace[Int(images.first!)!].subDirectory
        var plistImageFile = workSpaceImageFile
        if let range = workSpaceImageFile.range(of: "@") {
            plistImageFile.replaceSubrange(range, with: "")
        }
        let beforeRenameUrl: URL
        if subDirectory == "" {
            beforeRenameUrl = tempDirectoryUrl.appendingPathComponent(workSpaceImageFile)
        } else {
            beforeRenameUrl = tempDirectoryUrl.appendingPathComponent(subDirectory + "/" + workSpaceImageFile)
        }
        let afterRenameUrl = tempDirectoryUrl.appendingPathComponent(plistImageFile)
        ZipManager.rename(atFileUrl: beforeRenameUrl, toFileUrl: afterRenameUrl)
        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.insert(ImageFile(imageFile: plistImageFile), at: 0)
        workSpace.removeAll(where: {$0 == WorkSpaceImageFile(imageFile: workSpaceImageFile, subDirectory: "")})
        print("Added to plist:\(plistImageFile)")
        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages += 1
    }
    static func moveImagesFromDuplicateSpaceToPlist(imageFile: String, mainCategoryIds: inout [MainCategoryId], mainCategoryIndex: Int, subCategoryIndex: Int) {
        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.insert(ImageFile(imageFile: imageFile), at: 0)
        print("Added to plist:\(imageFile)")
        mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages += 1
    }
    static func savePlistAndZip(fileUrl: URL, mainCategoryIds: [MainCategoryId]) {
        var plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
        if let range = plistNoExtensionName.range(of: "&img") {
            plistNoExtensionName.replaceSubrange(range, with: "")
        }
        let plistDirectoryUrl = fileUrl.deletingLastPathComponent()
        let targetPlistUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName + "&img.plist")
        CategoryManager.write(fileUrl: targetPlistUrl, mainCategorys: CategoryManager.convertNoIdentifiable(mainCategoryIds: mainCategoryIds))
        let targetUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName)
        let targetZipUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".zip")
        ZipManager.remove(fileUrl: targetZipUrl)
        ZipManager.copy(atFileUrl: tempDirectoryUrl, toFileUrl: targetUrl)
        ZipManager.create(targetUrl: targetUrl, toZipUrl: targetZipUrl)
        ZipManager.remove(fileUrl: targetUrl)
    }
    static func savePlist(fileUrl: URL, mainCategoryIds: [MainCategoryId]) {
        var plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
        if let range = plistNoExtensionName.range(of: "&img") {
            plistNoExtensionName.replaceSubrange(range, with: "")
        }
        let plistDirectoryUrl = fileUrl.deletingLastPathComponent()
        let targetPlistUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName + "&img.plist")
        CategoryManager.write(fileUrl: targetPlistUrl, mainCategorys: CategoryManager.convertNoIdentifiable(mainCategoryIds: mainCategoryIds))
    }
    static func saveZip(fileUrl: URL) {
        var plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
        if let range = plistNoExtensionName.range(of: "&img") {
            plistNoExtensionName.replaceSubrange(range, with: "")
        }
        let plistDirectoryUrl = fileUrl.deletingLastPathComponent()
        let targetUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName)
        let targetZipUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".zip")
        ZipManager.remove(fileUrl: targetZipUrl)
        ZipManager.copy(atFileUrl: tempDirectoryUrl, toFileUrl: targetUrl)
        ZipManager.create(targetUrl: targetUrl, toZipUrl: targetZipUrl)
        ZipManager.remove(fileUrl: targetUrl)
    }
    static func copyZip(atZipUrl: URL, toZipUrl: URL) {
        let atDirUrl = atZipUrl.deletingPathExtension()
        let toDirUrl = toZipUrl.deletingPathExtension()
        ZipManager.unzipDirectory(zipUrl: atZipUrl, directoryUrl: documentDirectoryUrl)
        ZipManager.copy(atFileUrl: atDirUrl, toFileUrl: toDirUrl)
        ZipManager.create(targetUrl: toDirUrl, toZipUrl: toZipUrl)
        if fileManager.fileExists(atPath: toZipUrl.path) {
            ZipManager.remove(fileUrl: atDirUrl)
            ZipManager.remove(fileUrl: toDirUrl)
        }
    }
    static func renameZip(atZipUrl: URL, toZipUrl: URL) {
        let atDirUrl = atZipUrl.deletingPathExtension()
        let toDirUrl = toZipUrl.deletingPathExtension()
        ZipManager.unzipDirectory(zipUrl: atZipUrl, directoryUrl: documentDirectoryUrl)
        ZipManager.copy(atFileUrl: atDirUrl, toFileUrl: toDirUrl)
        ZipManager.create(targetUrl: toDirUrl, toZipUrl: toZipUrl)
        if fileManager.fileExists(atPath: toZipUrl.path) {
            ZipManager.remove(fileUrl: atDirUrl)
            ZipManager.remove(fileUrl: atZipUrl)
            ZipManager.remove(fileUrl: toDirUrl)
        }
    }
    static func remove(directoryUrl: URL) {
        if fileManager.fileExists(atPath: directoryUrl.path) {
            do {
                try fileManager.removeItem(atPath: directoryUrl.path)
                print("Removed directory:\(directoryUrl.path)")
            } catch {
                print("Remove of directory has failed with error:\(error)")
            }
        }
    }
    static func remove(fileUrl: URL) {
        if fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.removeItem(atPath: fileUrl.path)
                print("Removed file:\(fileUrl.path)")
            } catch {
                print("Remove of file has failed with error:\(error)")
            }
        }
    }
    static func unzipDirectory(zipUrl: URL, directoryUrl: URL) {
        do {
            try fileManager.unzipItem(at: zipUrl, to: directoryUrl)
            print("Extracted ZIP archive:\(zipUrl)->\(directoryUrl)")
        } catch {
            print("Extracting ZIP archive has failed with error:\(error)")
        }
        let macosxUrl = directoryUrl.appendingPathComponent("__MACOSX")
        if fileManager.fileExists(atPath: macosxUrl.path) {
            self.remove(fileUrl: macosxUrl)
        }
    }
    static func create(directoryUrl: URL) {
        if fileManager.fileExists(atPath: directoryUrl.path) {
        } else {
            do {
                try fileManager.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true)
                print("Created directory:\(directoryUrl.path)")
            } catch {
                print("Creating director has failed with error:\(error)")
            }
        }
    }
    static func create(targetUrl: URL, toZipUrl: URL) {
        if fileManager.fileExists(atPath: toZipUrl.path) {
        } else {
            do {
                try FileManager.default.zipItem(at: targetUrl, to: toZipUrl)
                //try FileManager.default.zipItem(at: targetUrl, to: toZipUrl, compressionMethod: .deflate)
                print("Created ZIP archive:\(toZipUrl)")
            } catch {
                print("Creating ZIP archive has failed with error:\(error)")
            }
        }
    }
    static func rename(atFileUrl: URL, toFileUrl: URL) {
        if fileManager.fileExists(atPath: toFileUrl.path) {
        } else {
            do {
                try fileManager.moveItem(atPath: atFileUrl.path, toPath: toFileUrl.path)
                print("Renamed jpg file")
            } catch {
                print("Rename of jpg file failed with error:\(error)")
            }
        }
    }
    static func copy(atFileUrl: URL, toFileUrl: URL) {
        if fileManager.fileExists(atPath: toFileUrl.path) {
        } else {
            do {
                try fileManager.copyItem(atPath: atFileUrl.path, toPath: toFileUrl.path)
                print("Copied jpg file")
            } catch {
                print("Copy of jpg file failed with error:\(error)")
            }
        }
    }
}
