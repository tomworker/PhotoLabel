//
//  ContentView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI
import ZIPFoundation

struct ContentView: View {
    @StateObject var photoCapture = PhotoCapture()
    @State var mainCategoryIds: [MainCategoryId] = []
    @State var workSpace: [WorkSpaceImageFile] = []
    @State var duplicateSpace: [DuplicateImageFile] = []
    @State private var fileUrl: URL?
    @State var showPlistCreator = false
    @State var showPlistEditor: [Bool]
    @State private var showDocumentPicker = false
    @State var showCategorySelector: [Bool]
    @State var showConfig = false
    @State var showAppVersion = false
    @State var isRemove: [Bool]
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
    @State var isPresentedProgressView = false
    @State var targetItem = 0
    
    var body: some View {
        Button {
            showAppVersion = true
        } label: {
            VStack(spacing: 0) {
                HStack {
                    ZStack(alignment: .top) {
                        VStack(spacing: 7) {
                            ForEach(0..<4) { i in
                                HStack(spacing: 7) {
                                    ForEach(0..<4) { j in
                                        VStack {
                                        }
                                        .frame(width: 33, height: 33)
                                        .background((i + j) % 2 == 0 ? .orange : .brown)
                                    }
                                }
                            }
                        }
                        .frame(width: 99, height: 99)
                        .background(.black)
                        .cornerRadius(20)
                        Image(systemName: "camera").font(.system(size: 50))
                            .frame(width: 100, height: 79)
                            .foregroundColor(.white)
                            .background(.clear)
                            .cornerRadius(10)
                        Text("Label")
                            .baselineOffset(-58.5)
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
                                Text(".plist")
                                    .frame(width: 50, height: 50)
                                    .baselineOffset(-10)
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
        .fullScreenCover(isPresented: $showAppVersion) {
            AppVersionView(showAppVersion: $showAppVersion)
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
            }
            .onChange(of: showPlistCreator || isChangeFlag) {
                showPlistList()
            }
            .onAppear {
                let jsonUrl = documentDirectoryUrl.appendingPathComponent("config.json")
                if FileManager.default.fileExists(atPath: jsonUrl.path) {
                    let config = JsonManager.load(fileUrl: jsonUrl)
                    if config.iPadMaxColCatBtn == 0 {
                    } else {
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
                        ConfigManager.iPadCheckBoxMatrixColumnWidth = config.iPadChkBoxMtxColWidth
                        ConfigManager.checkBoxMatrixColumnWidth = config.chkBoxMtxColWidth
                    }
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
                        if documentDirectoryFiles[item].suffix(6) == ".plist" {
                            let targetPlistUrl = documentDirectoryUrl.appendingPathComponent(documentDirectoryFiles[item])
                            ZStack {
                                Button {
                                    photoCapture.interestTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                                        if showCategorySelector[item] == false {
                                            isPresentedProgressView = true
                                            targetItem = item
                                        }
                                    }
                                    DispatchQueue.global(qos: .userInteractive).async {
                                        loadPlist(fileUrl: targetPlistUrl, showCategorySelector: &showCategorySelector[item])
                                    }
                                } label: {
                                    if documentDirectoryFiles[item].range(of: "InOutMgr") != nil {
                                        if getIsToday(target: documentDirectoryFiles[item]) == true {
                                            Text(documentDirectoryFiles[item])
                                        } else {
                                            Text(documentDirectoryFiles[item])
                                                .foregroundColor(.red)
                                        }
                                    } else {
                                        Text(documentDirectoryFiles[item])
                                    }
                                }
                                .onChange(of: showPlistEditor[item]) {
                                    showPlistListEdit()
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        isRemove[item] = true;
                                    } label : {
                                        Label("Remove", systemImage: "trash")
                                    }
                                    Button {
                                        showPlistEditor[item] = true
                                        plistName = documentDirectoryFiles[item]
                                        plistName = plistName.replacingOccurrences(of: ".plist", with: "")
                                    } label : {
                                        Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                                    }
                                    .tint(.blue)
                                }
                                .alert(isPresented: $isRemove[item]) {
                                    Alert(title: Text("Really remove it?"),
                                          primaryButton: .cancel(Text("Cancel")),
                                          secondaryButton: .destructive(Text("Remove"), action: {
                                        ZipManager.remove(fileUrl: targetPlistUrl)
                                        let targetZipName = targetPlistUrl.lastPathComponent.replacingOccurrences(of: ".plist", with: ".zip")
                                        let targetZipUrl = ZipManager.documentDirectoryUrl.appendingPathComponent(targetZipName)
                                        ZipManager.remove(fileUrl: targetZipUrl)
                                        isChangeFlag.toggle()
                                    }))
                                }
                                .fullScreenCover(isPresented: $showCategorySelector[item]) {
                                    let mainCategoryIds: [MainCategoryId] = CategoryManager.convertIdentifiable(mainCategorys: CategoryManager.load(fileUrl: targetPlistUrl))
                                    let downSizeImages = mainCategoryIds.map{$0.items.map{$0.images.map{UIImage(contentsOfFile: tempDirectoryUrl.path + "/" + $0.imageFile)!.resize(targetSize: CGSize(width: 200, height: 200))}}}
                                    CategorySelectorView(photoCapture: photoCapture, showCategorySelector: $showCategorySelector[item], mainCategoryIds: mainCategoryIds, workSpace: $workSpace, duplicateSpace: $duplicateSpace, fileUrl: targetPlistUrl, plistCategoryName: targetPlistUrl.deletingPathExtension().lastPathComponent, downSizeImages: downSizeImages, isPresentedProgressView: $isPresentedProgressView)
                                }
                                .fullScreenCover(isPresented: $showPlistEditor[item]) {
                                    let mainCategoryIds: [MainCategoryId] = CategoryManager.convertIdentifiable(mainCategorys: CategoryManager.load(fileUrl: targetPlistUrl))
                                    PlistEditorView(showPlistEditor: $showPlistEditor[item], plistName: plistName, mainCategoryIds: mainCategoryIds)
                                }
                                if isPresentedProgressView, item == targetItem {
                                    ProgressView()
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
    private func getIsToday(target: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let strDate = dateFormatter.string(from: Date())
        if target.range(of: strDate) != nil {
            return true
        } else {
            return false
        }
    }
    private func showPlistList() {
        ZipManager.create(directoryUrl: tempDirectoryUrl)
        do {
            documentDirectoryFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: documentDirectoryUrl.path)
            showPlistEditor = Array(repeating: false, count: documentDirectoryFiles.count)
            showCategorySelector = Array(repeating: false, count: documentDirectoryFiles.count)
            isRemove = Array(repeating: false, count: documentDirectoryFiles.count)
        } catch {
            print(error)
        }
        documentDirectoryFiles.sort { $0.description < $1.description}
    }
    private func showPlistListEdit() {
        ZipManager.create(directoryUrl: tempDirectoryUrl)
        do {
            documentDirectoryFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: documentDirectoryUrl.path)
            showCategorySelector = Array(repeating: false, count: documentDirectoryFiles.count)
        } catch {
            print(error)
        }
        documentDirectoryFiles.sort { $0.description < $1.description}
    }
    private func loadPlist(fileUrl: URL, showCategorySelector: inout Bool) {
        showCategorySelector = true
        ZipManager.remove(directoryUrl: tempDirectoryUrl)
        let plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
        let zipUrl = documentDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".zip")
        if ZipManager.fileManager.fileExists(atPath: zipUrl.path) {
            ZipManager.unzipDirectory(zipUrl: zipUrl, directoryUrl: documentDirectoryUrl)
            ZipManager.rename(atFileUrl: documentDirectoryUrl.appendingPathComponent(plistNoExtensionName, isDirectory: true), toFileUrl: tempDirectoryUrl)
        } else {
            ZipManager.create(directoryUrl: tempDirectoryUrl)
        }
        var tempImageFiles: [String]
        var initialTempImageFileUrl: URL
        var tempImageFileUrl: URL
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
                        initialTempImageFileUrl = tempDirectoryUrl.appendingPathComponent(tempImageFiles[i])
                        tempImageFiles[i] = ZipManager.replaceString(targetString: tempImageFiles[i])
                        tempImageFileUrl = tempDirectoryUrl.appendingPathComponent(tempImageFiles[i])
                        tempImageFile = tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]).path
                        if initialTempImageFileUrl != tempImageFileUrl {
                            ZipManager.rename(atFileUrl: initialTempImageFileUrl, toFileUrl: tempImageFileUrl)
                        }
                        var subDirImageFiles: [String]
                        var subDirImageFile: String
                        do {
                            subDirImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: tempImageFile)
                            if subDirImageFiles.count == 0 {
                                ZipManager.remove(directoryUrl: tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]))
                            }
                            var j2 = 0
                            for j in 0..<subDirImageFiles.count {
                                var isDir2: ObjCBool = false
                                subDirImageFile = tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]).appendingPathComponent(subDirImageFiles[j - j2]).path
                                if ZipManager.fileManager.fileExists(atPath: subDirImageFile, isDirectory: &isDir2) {
                                    if isDir2.boolValue {
                                        var subx2DirImageFiles: [String]
                                        var subx2DirImageFile: String
                                        do {
                                            subx2DirImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: subDirImageFile)
                                            if subx2DirImageFiles.count == 0 {
                                                ZipManager.remove(directoryUrl: tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]).appendingPathComponent(subDirImageFiles[j - j2]))
                                                j2 = j2 + 1
                                                subDirImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: tempImageFile)
                                                if subDirImageFiles.count == 0 {
                                                    ZipManager.remove(directoryUrl: tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]))
                                                }
                                            }
                                            var k2 = 0
                                            for k in 0..<subx2DirImageFiles.count {
                                                var isDir3: ObjCBool = false
                                                subx2DirImageFile = tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]).appendingPathComponent(subDirImageFiles[j - j2]).appendingPathComponent(subx2DirImageFiles[k - k2]).path
                                                if ZipManager.fileManager.fileExists(atPath: subx2DirImageFile, isDirectory: &isDir3) {
                                                    if isDir3.boolValue {
                                                    } else {
                                                        let beforeRenameUrl = tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]).appendingPathComponent(subDirImageFiles[j - j2]).appendingPathComponent(subx2DirImageFiles[k - k2])
                                                        let afterRenameUrl = tempDirectoryUrl.appendingPathComponent(subx2DirImageFiles[k - k2])
                                                        ZipManager.rename(atFileUrl: beforeRenameUrl, toFileUrl: afterRenameUrl)
                                                        k2 = k2 + 1
                                                        subx2DirImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: subDirImageFile)
                                                        if subx2DirImageFiles.count == 0 {
                                                            ZipManager.remove(directoryUrl: tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]).appendingPathComponent(subDirImageFiles[j - j2]))
                                                            j2 = j2 + 1
                                                            subDirImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: tempImageFile)
                                                            if subDirImageFiles.count == 0 {
                                                                ZipManager.remove(directoryUrl: tempDirectoryUrl.appendingPathComponent(tempImageFiles[i]))
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } catch {
                                            print("Subx2Folder image files have failed to be obtained:\(error)")
                                        }
                                    } else {
                                        if subDirImageFiles[j - j2].first == "@" {
                                            workSpace.append(WorkSpaceImageFile(imageFile: subDirImageFiles[j - j2], subDirectory: tempImageFiles[i]))
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("SubFolder image files have failed to be obtained:\(error)")
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
                    if initialMainCategorys[i].subFolderMode == 1 {
                        ZipManager.create(directoryUrl: tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: subCategoryName)))
                        let beforeRenameUrl = tempDirectoryUrl.appendingPathComponent(initialMainCategorys[i].items[j].images[k].imageFile)
                        let afterRenameUrl = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryName)).appendingPathComponent(ZipManager.replaceString(targetString: subCategoryName)).appendingPathComponent(initialMainCategorys[i].items[j].images[k].imageFile)
                        ZipManager.rename(atFileUrl: beforeRenameUrl, toFileUrl: afterRenameUrl)
                    }
                    duplicateSpace.append(DuplicateImageFile(imageFile: initialMainCategorys[i].items[j].images[k].imageFile, subFolderMode: initialMainCategorys[i].subFolderMode, mainCategoryName: mainCategoryName, subCategoryName: subCategoryName))
                }
            }
        }
    }
}
struct ImageFile: Decodable, Encodable, Equatable {
    let imageFile: String
    var imageInfo: String = ""
}
struct OldImageFile: Decodable, Encodable, Equatable {
    let imageFile: String
}
struct SubCategory: Decodable, Encodable {
    let subCategory: String
    var countStoredImages: Int
    var images: [ImageFile]
}
struct OldSubCategory: Decodable, Encodable {
    let subCategory: String
    var countStoredImages: Int
    var images: [OldImageFile]
}
struct MainCategory: Decodable, Encodable {
    let mainCategory: String
    let items: [SubCategory]
    let subFolderMode: Int
}
struct OldMainCategory: Decodable, Encodable {
    let mainCategory: String
    let items: [OldSubCategory]
    let subFolderMode: Int
}
struct SubCategoryId: Identifiable {
    var id: Int
    var subCategory: String
    var countStoredImages: Int
    var images: [ImageFile]
    var isTargeted: Bool
}
struct MainCategoryId: Identifiable {
    var id: Int
    var mainCategory: String
    var items: [SubCategoryId]
    let subFolderMode: Int
}
struct WorkSpaceImageFile: Equatable {
    let imageFile: String
    let subDirectory: String
}
struct DuplicateImageFile: Equatable {
    let imageFile: String
    let subFolderMode: Int
    let mainCategoryName: String
    let subCategoryName: String
}
class ImageManager {
    static func downSize(uiimage: UIImage, scale: CGFloat) -> UIImage {
        autoreleasepool {
            let cgimage = uiimage.cgImage
            let ciimage = CIImage(cgImage: cgimage!)
            let matrix = CGAffineTransform(scaleX: scale, y: scale)
            let ciimage2 = ciimage.transformed(by: matrix)
            let context = CIContext(options: nil)
            let cgimage2 = context.createCGImage(ciimage2, from: ciimage2.extent)
            let uiimage2 = UIImage(cgImage: cgimage2!, scale: uiimage.scale, orientation: uiimage.imageOrientation)
            return uiimage2
        }
    }
}
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
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
    static var maxNumberOfSubCategory = 999
    static var maxNumberOfImageFile = 999
    static var iPadCheckBoxMatrixColumnWidth = 90
    static var checkBoxMatrixColumnWidth = 60
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
    static let initialMaxNumberOfSubCategory = 999
    static let initialMaxNumberOfImageFile = 999
    static let initialIPadCheckBoxMatrixColumnWidth = 90
    static let initialCheckBoxMatrixColumnWidth = 60
}
class CategoryManager {
    static let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    static let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static func write(fileUrl: URL, mainCategorys: [MainCategory]) {
        autoreleasepool {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            guard let data = try? encoder.encode(mainCategorys) else { return }
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                try? data.write(to: fileUrl)
            } else {
                FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
            }
        }
    }
    static func load(fileUrl: URL) -> [MainCategory] {
        autoreleasepool {
            let decoder = PropertyListDecoder()
            do {
                let data = try Data.init(contentsOf: fileUrl)
                let mainCategorys = try decoder.decode([MainCategory].self, from: data)
                return mainCategorys
            } catch {
                print(error)
                do {
                    let data = try Data.init(contentsOf: fileUrl)
                    let oldMainCategorys = try decoder.decode([OldMainCategory].self, from: data)
                    let mainCategorys = oldMainCategorys.map{MainCategory(mainCategory: $0.mainCategory, items: $0.items.map{SubCategory(subCategory: $0.subCategory, countStoredImages: $0.countStoredImages, images: $0.images.map{ImageFile(imageFile: $0.imageFile, imageInfo: "")})}, subFolderMode: $0.subFolderMode)}
                    return mainCategorys
                } catch {
                    print(error)
                    return [MainCategory(mainCategory: "", items: [SubCategory(subCategory: "", countStoredImages: 0, images: [ImageFile(imageFile: "")])], subFolderMode: 0)]
                }
            }
        }
    }
    static func getColumns(userInterfaceIdiom: UIUserInterfaceIdiom) -> [GridItem] {
        autoreleasepool {
            let columns1 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber)), spacing: 5), count: ConfigManager.imageColumnNumber)
            let columns2 = Array(repeating: GridItem(.fixed((UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber)), spacing: 5), count: ConfigManager.iPadImageColumnNumber)
            if userInterfaceIdiom == .pad {
                return columns2
            } else {
                return columns1
            }
        }
    }
    static func getAspectRatio(width: CGFloat, height: CGFloat) -> CGFloat {
        autoreleasepool {
            var aspectRatio = 1.0
            if width > height {
                aspectRatio = 4 / 3
            } else if width == height {
                aspectRatio = 1.0
            } else {
                aspectRatio = 3 / 4
            }
            return aspectRatio
        }
    }
    static func getImageWidth(width: CGFloat, height: CGFloat, userInterfaceIdiom: UIUserInterfaceIdiom) -> CGFloat {
        autoreleasepool {
            var imageWidth: CGFloat
            if userInterfaceIdiom == .pad {
                imageWidth = (UIScreen.main.bounds.width - (CGFloat(ConfigManager.iPadImageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.iPadImageColumnNumber)
            } else {
                imageWidth = (UIScreen.main.bounds.width - (CGFloat(ConfigManager.imageColumnNumber) - 1) * 10) / CGFloat(ConfigManager.imageColumnNumber)
            }
            if width > height {
                return imageWidth
            } else {
                return imageWidth * 0.75
            }
        }
    }
    static func getBorderWidth(isTargeted: Bool, index: Int, isTargetedIndex: Int) -> CGFloat {
        autoreleasepool {
            if isTargeted && index == isTargetedIndex {
                return 3.0
            } else {
                return 0.0
            }
        }
    }
    static func isLocatedWithinArea(originy: CGFloat, id: Int, lowerLoadLimit: Int, upperLoadLimit: Int) -> Bool {
        autoreleasepool {
            if UIDevice.current.userInterfaceIdiom == .pad {
                if originy > 150 - (ceil(Double(id / ConfigManager.iPadImageColumnNumber)) + Double(lowerLoadLimit)) * (CategoryManager.getImageWidth(width: 1.0, height: 0.75, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom) + 25) && originy < 150 - (ceil(Double(id / ConfigManager.iPadImageColumnNumber)) - Double(upperLoadLimit)) * (CategoryManager.getImageWidth(width: 0.75, height: 1.0, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom) + 25) {
                    return true
                } else {
                    return false
                }
            } else {
                if originy > 150 - (ceil(Double(id / ConfigManager.imageColumnNumber)) + Double(lowerLoadLimit)) * (CategoryManager.getImageWidth(width: 1.0, height: 0.75, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom) + 25) && originy < 150 - (ceil(Double(id / ConfigManager.imageColumnNumber)) - Double(upperLoadLimit)) * (CategoryManager.getImageWidth(width: 0.75, height: 1.0, userInterfaceIdiom: UIDevice.current.userInterfaceIdiom) + 25) {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    static func convertIdentifiable(subCategorys: [SubCategory]) -> [SubCategoryId] {
        autoreleasepool {
            var subCategoryIds: [SubCategoryId] = []
            for i in 0..<subCategorys.count {
                subCategoryIds.append(SubCategoryId(id: i, subCategory: subCategorys[i].subCategory, countStoredImages: subCategorys[i].countStoredImages, images: subCategorys[i].images, isTargeted: false))
            }
            return subCategoryIds
        }
    }
    static func convertIdentifiable(mainCategorys: [MainCategory]) -> [MainCategoryId] {
        autoreleasepool {
            var mainCategoryIds: [MainCategoryId] = []
            for i in 0..<mainCategorys.count {
                mainCategoryIds.append(MainCategoryId(id: i, mainCategory: mainCategorys[i].mainCategory, items: convertIdentifiable(subCategorys: mainCategorys[i].items), subFolderMode: mainCategorys[i].subFolderMode))
            }
            return mainCategoryIds
        }
    }
    static func convertNoIdentifiable(subCategoryIds: [SubCategoryId]) -> [SubCategory] {
        autoreleasepool {
            var subCategorys: [SubCategory] = []
            for i in 0..<subCategoryIds.count {
                subCategorys.append(SubCategory(subCategory: subCategoryIds[i].subCategory, countStoredImages: subCategoryIds[i].countStoredImages, images: subCategoryIds[i].images))
            }
            return subCategorys
        }
    }
    static func convertNoIdentifiable(mainCategoryIds: [MainCategoryId]) -> [MainCategory] {
        autoreleasepool {
            var mainCategorys: [MainCategory] = []
            for i in 0..<mainCategoryIds.count {
                mainCategorys.append(MainCategory(mainCategory: mainCategoryIds[i].mainCategory, items: convertNoIdentifiable(subCategoryIds: mainCategoryIds[i].items), subFolderMode: mainCategoryIds[i].subFolderMode))
            }
            return mainCategorys
        }
    }
    static func reorderItems(imageKey: Int, index: Int, imageSpace: inout [ImageFile], downSizeImages: inout [UIImage]) {
        autoreleasepool {
            let moveToIndex = imageKey
            let targetIndex = index
            let lastIndex = imageSpace.count - 1
            var imageSpace2: [ImageFile] = []
            var downSizeImages2: [UIImage] = []
            if moveToIndex <= targetIndex {
                if moveToIndex != 0 {
                    imageSpace2 += imageSpace[0..<moveToIndex]
                    downSizeImages2 += downSizeImages[0..<moveToIndex]
                }
                imageSpace2 += imageSpace[targetIndex...targetIndex]
                downSizeImages2 += downSizeImages[targetIndex...targetIndex]
                if moveToIndex != targetIndex {
                    imageSpace2 += imageSpace[moveToIndex..<targetIndex]
                    downSizeImages2 += downSizeImages[moveToIndex..<targetIndex]
                }
                if targetIndex != lastIndex {
                    imageSpace2 += imageSpace[targetIndex + 1...lastIndex]
                    downSizeImages2 += downSizeImages[targetIndex + 1...lastIndex]
                }
            }
            if moveToIndex > lastIndex {
                imageSpace2 += imageSpace[0..<targetIndex]
                imageSpace2 += imageSpace[targetIndex + 1..<moveToIndex]
                imageSpace2 += imageSpace[targetIndex...targetIndex]
                downSizeImages2 += downSizeImages[0..<targetIndex]
                downSizeImages2 += downSizeImages[targetIndex + 1..<moveToIndex]
                downSizeImages2 += downSizeImages[targetIndex...targetIndex]
            } else {
                if moveToIndex > targetIndex {
                    if targetIndex != 0 {
                        imageSpace2 += imageSpace[0..<targetIndex]
                        downSizeImages2 += downSizeImages[0..<targetIndex]
                    }
                    if moveToIndex != targetIndex + 1 {
                        imageSpace2 += imageSpace[targetIndex + 1..<moveToIndex]
                        imageSpace2 += imageSpace[targetIndex...targetIndex]
                        imageSpace2 += imageSpace[moveToIndex...lastIndex]
                        downSizeImages2 += downSizeImages[targetIndex + 1..<moveToIndex]
                        downSizeImages2 += downSizeImages[targetIndex...targetIndex]
                        downSizeImages2 += downSizeImages[moveToIndex...lastIndex]
                    } else {
                        imageSpace2 += imageSpace[targetIndex + 1...targetIndex + 1]
                        imageSpace2 += imageSpace[targetIndex...targetIndex]
                        downSizeImages2 += downSizeImages[targetIndex + 1...targetIndex + 1]
                        downSizeImages2 += downSizeImages[targetIndex...targetIndex]
                        if moveToIndex < lastIndex {
                            imageSpace2 += imageSpace[moveToIndex + 1...lastIndex]
                            downSizeImages2 += downSizeImages[moveToIndex + 1...lastIndex]
                        }
                    }
                }
            }
            imageSpace = imageSpace2
            downSizeImages = downSizeImages2
        }
    }
    static func reorderItems(imageKey: Int, indexs: [String], workSpace: inout [WorkSpaceImageFile]) {
        autoreleasepool {
            let moveToIndex = imageKey
            let targetIndex = Int(indexs.first!)!
            let lastIndex = workSpace.count - 1
            var workSpace2: [WorkSpaceImageFile] = []
            if moveToIndex <= targetIndex {
                if moveToIndex != 0 {
                    workSpace2 += workSpace[0..<moveToIndex]
                }
                workSpace2 += workSpace[targetIndex...targetIndex]
                if moveToIndex != targetIndex {
                    workSpace2 += workSpace[moveToIndex..<targetIndex]
                }
                if targetIndex != lastIndex {
                    workSpace2 += workSpace[targetIndex + 1...lastIndex]
                }
            }
            if moveToIndex > targetIndex {
                if targetIndex != 0 {
                    workSpace2 += workSpace[0..<targetIndex]
                }
                if moveToIndex != targetIndex + 1 {
                    workSpace2 += workSpace[targetIndex + 1..<moveToIndex]
                    workSpace2 += workSpace[targetIndex...targetIndex]
                    workSpace2 += workSpace[moveToIndex...lastIndex]
                } else {
                    workSpace2 += workSpace[targetIndex + 1...targetIndex + 1]
                    workSpace2 += workSpace[targetIndex...targetIndex]
                    if moveToIndex < lastIndex {
                        workSpace2 += workSpace[moveToIndex + 1...lastIndex]
                    }
                }
            }
            workSpace = workSpace2
        }
    }
    static func reorderItems(imageKey: Int, indexs: [String], duplicateSpace: inout [DuplicateImageFile]) {
        autoreleasepool {
            let moveToIndex = imageKey
            let targetIndex = Int(indexs.first!)!
            let lastIndex = duplicateSpace.count - 1
            var duplicateSpace2: [DuplicateImageFile] = []
            if moveToIndex <= targetIndex {
                if moveToIndex != 0 {
                    duplicateSpace2 += duplicateSpace[0..<moveToIndex]
                }
                duplicateSpace2 += duplicateSpace[targetIndex...targetIndex]
                if moveToIndex != targetIndex {
                    duplicateSpace2 += duplicateSpace[moveToIndex..<targetIndex]
                }
                if targetIndex != lastIndex {
                    duplicateSpace2 += duplicateSpace[targetIndex + 1...lastIndex]
                }
            }
            if moveToIndex > targetIndex {
                if targetIndex != 0 {
                    duplicateSpace2 += duplicateSpace[0..<targetIndex]
                }
                if moveToIndex != targetIndex + 1 {
                    duplicateSpace2 += duplicateSpace[targetIndex + 1..<moveToIndex]
                    duplicateSpace2 += duplicateSpace[targetIndex...targetIndex]
                    duplicateSpace2 += duplicateSpace[moveToIndex...lastIndex]
                } else {
                    duplicateSpace2 += duplicateSpace[targetIndex + 1...targetIndex + 1]
                    duplicateSpace2 += duplicateSpace[targetIndex...targetIndex]
                    if moveToIndex < lastIndex {
                        duplicateSpace2 += duplicateSpace[moveToIndex + 1...lastIndex]
                    }
                }
            }
            duplicateSpace = duplicateSpace2
        }
    }
    static func moveItemFromLastToFirst(imageKey: Int, imageSpace: inout [ImageFile], downSizeImages: inout [UIImage]) {
        autoreleasepool {
            let targetIndex = imageKey
            let lastIndex = imageSpace.count - 1
            var imageSpace2: [ImageFile] = []
            var downSizeImages2: [UIImage] = []
            if targetIndex > 0 {
                imageSpace2 += imageSpace[targetIndex...targetIndex]
                imageSpace2 += imageSpace[0...targetIndex - 1]
                downSizeImages2 += downSizeImages[targetIndex...targetIndex]
                downSizeImages2 += downSizeImages[0...targetIndex - 1]
                if targetIndex != lastIndex {
                    imageSpace2 += imageSpace[targetIndex + 1...lastIndex]
                    downSizeImages2 += downSizeImages[targetIndex + 1...lastIndex]
                }
                imageSpace = imageSpace2
                downSizeImages = downSizeImages2
            }
        }
    }
    static func moveItemFromLastToFirst(imageKey: Int, workSpace: inout [WorkSpaceImageFile]) {
        autoreleasepool {
            let targetIndex = imageKey
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
    }
    static func moveItemFromLastToFirst(imageKey: Int, duplicateSpace: inout [DuplicateImageFile]) {
        autoreleasepool {
            let targetIndex = imageKey
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
}
class ZipManager {
    static let fileManager = FileManager.default
    static let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    static let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static func replaceString(targetString: String) -> String {
        autoreleasepool {
            var replacedString: String {
                let dictionary = [" ": "_", ".": ",", ":": "", "¥": "", "/": "", "?": "", "<": "", ">": "", "*": "", "|": "", "\"": ""]
                return dictionary.reduce(targetString) { $0.replacingOccurrences(of: $1.key, with: $1.value)}
            }
            return replacedString != "" ? replacedString : "_"
        }
    }
    static func moveImagesFromPlistToWorkSpace(images: [String], mainCategoryIds: inout [MainCategoryId], mainCategoryIndex: Int, subCategoryIndex: Int, workSpace: inout [WorkSpaceImageFile], duplicateSpace: inout [DuplicateImageFile], downSizeImages: inout [UIImage]) {
        autoreleasepool {
            let targetImageFile = mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images[Int(images.first!)!].imageFile
            let workSpaceImageFile = "@\(targetImageFile)"
            var beforeRenameUrl = tempDirectoryUrl.appendingPathComponent(targetImageFile)
            if mainCategoryIds[mainCategoryIndex].subFolderMode == 1 {
                beforeRenameUrl = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)).appendingPathComponent(targetImageFile)
            }
            let afterRenameUrl = tempDirectoryUrl.appendingPathComponent(workSpaceImageFile)
            ZipManager.rename(atFileUrl: beforeRenameUrl, toFileUrl: afterRenameUrl)
            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.remove(at: Int(images.first!)!)
            downSizeImages.remove(at: Int(images.first!)!)
            duplicateSpace.removeAll(where: {$0.imageFile == targetImageFile})
            workSpace.append(WorkSpaceImageFile(imageFile: workSpaceImageFile, subDirectory: ""))
            print("Removed from plist:\(targetImageFile)")
            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages -= 1
        }
    }
    static func moveImagesFromWorkSpaceToPlist(images: [String], mainCategoryIds: inout [MainCategoryId], mainCategoryIndex: Int, subCategoryIndex: Int, workSpace: inout [WorkSpaceImageFile], downSizeImages: inout [UIImage]) {
        autoreleasepool {
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
            var afterRenameUrl = tempDirectoryUrl.appendingPathComponent(plistImageFile)
            if mainCategoryIds[mainCategoryIndex].subFolderMode == 1 {
                ZipManager.create(directoryUrl: tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)))
                afterRenameUrl = tempDirectoryUrl.appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].mainCategory)).appendingPathComponent(ZipManager.replaceString(targetString: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)).appendingPathComponent(plistImageFile)
            }
            ZipManager.rename(atFileUrl: beforeRenameUrl, toFileUrl: afterRenameUrl)
            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.insert(ImageFile(imageFile: plistImageFile), at: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.count)
            downSizeImages.append(UIImage(contentsOfFile: tempDirectoryUrl.path + "/" + plistImageFile)!.resize(targetSize: CGSize(width: 200, height: 200)))
            workSpace.removeAll(where: {$0 == WorkSpaceImageFile(imageFile: workSpaceImageFile, subDirectory: "")})
            print("Added to plist:\(plistImageFile)")
            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages += 1
        }
    }
    static func moveImagesFromDuplicateSpaceToPlist(imageFile: String, mainCategoryIds: inout [MainCategoryId], mainCategoryIndex: Int, subCategoryIndex: Int, downSizeImages: inout [UIImage]) {
        autoreleasepool {
            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.insert(ImageFile(imageFile: imageFile), at: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images.count)
            downSizeImages.append(UIImage(contentsOfFile: tempDirectoryUrl.path + "/" + imageFile)!.resize(targetSize: CGSize(width: 200, height: 200)))
            print("Added to plist:\(imageFile)")
            mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages += 1
        }
    }
    static func savePlistAndZip(fileUrl: URL, mainCategoryIds: [MainCategoryId]) {
        autoreleasepool {
            let plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
            let plistDirectoryUrl = fileUrl.deletingLastPathComponent()
            var tempImageFiles: [String]
            let targetPlistUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".plist")
            let targetUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName)
            let targetZipUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".zip")
            do {
                tempImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: tempDirectoryUrl.path)
                CategoryManager.write(fileUrl: targetPlistUrl, mainCategorys: CategoryManager.convertNoIdentifiable(mainCategoryIds: mainCategoryIds))
                if tempImageFiles.count == 0 {
                    ZipManager.remove(fileUrl: targetZipUrl)
                } else {
                    ZipManager.remove(fileUrl: targetZipUrl)
                    ZipManager.copy(atFileUrl: tempDirectoryUrl, toFileUrl: targetUrl)
                    ZipManager.create(targetUrl: targetUrl, toZipUrl: targetZipUrl)
                    ZipManager.remove(fileUrl: targetUrl)
                }
            } catch {
                print(error)
            }
        }
    }
    static func savePlist(fileUrl: URL, mainCategoryIds: [MainCategoryId]) {
        autoreleasepool {
            let plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
            let plistDirectoryUrl = fileUrl.deletingLastPathComponent()
            let targetPlistUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".plist")
            CategoryManager.write(fileUrl: targetPlistUrl, mainCategorys: CategoryManager.convertNoIdentifiable(mainCategoryIds: mainCategoryIds))
        }
    }
    static func saveZip(fileUrl: URL) {
        autoreleasepool {
            let plistNoExtensionName = fileUrl.deletingPathExtension().lastPathComponent
            let plistDirectoryUrl = fileUrl.deletingLastPathComponent()
            var tempImageFiles: [String]
            let targetUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName)
            let targetZipUrl = plistDirectoryUrl.appendingPathComponent(plistNoExtensionName + ".zip")
            do {
                tempImageFiles = try ZipManager.fileManager.contentsOfDirectory(atPath: tempDirectoryUrl.path)
                if tempImageFiles.count == 0 {
                    ZipManager.remove(fileUrl: targetZipUrl)
                } else {
                    ZipManager.remove(fileUrl: targetZipUrl)
                    ZipManager.copy(atFileUrl: tempDirectoryUrl, toFileUrl: targetUrl)
                    ZipManager.create(targetUrl: targetUrl, toZipUrl: targetZipUrl)
                    ZipManager.remove(fileUrl: targetUrl)
                }
            } catch {
                print(error)
            }
        }
    }
    static func copyZip(atZipUrl: URL, toZipUrl: URL) {
        autoreleasepool {
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
    }
    static func renameZip(atZipUrl: URL, toZipUrl: URL) {
        autoreleasepool {
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
    }
    static func remove(directoryUrl: URL) {
        autoreleasepool {
            if fileManager.fileExists(atPath: directoryUrl.path) {
                do {
                    try fileManager.removeItem(atPath: directoryUrl.path)
                    print("Removed directory:\(directoryUrl.path)")
                } catch {
                    print("Remove of directory has failed with error:\(error)")
                }
            }
        }
    }
    static func remove(fileUrl: URL) {
        autoreleasepool {
            if fileManager.fileExists(atPath: fileUrl.path) {
                do {
                    try fileManager.removeItem(atPath: fileUrl.path)
                    print("Removed file:\(fileUrl.path)")
                } catch {
                    print("Remove of file has failed with error:\(error)")
                }
            }
        }
    }
    static func unzipDirectory(zipUrl: URL, directoryUrl: URL) {
        autoreleasepool {
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
    }
    static func create(directoryUrl: URL) {
        autoreleasepool {
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
    }
    static func create(targetUrl: URL, toZipUrl: URL) {
        autoreleasepool {
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
    }
    static func rename(atFileUrl: URL, toFileUrl: URL) {
        autoreleasepool {
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
    }
    static func copy(atFileUrl: URL, toFileUrl: URL) {
        autoreleasepool {
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
}
