//
//  ConfigView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/30.
//

import SwiftUI

struct ConfigView: View {
    @Binding var showConfig: Bool
    @State var iPadMaxColumnsCategoryButton = 0
    @State var iPadMaxColumnsDetailsButton = 0
    @State var iPadMaxColumnsPhotos = 0
    @State var maxColumnsCategoryButton = 0
    @State var maxColumnsDetailsButton = 0
    @State var maxColumnsPhotos = 0
    @State var iPadMaxRowsCategoryButton = 0
    @State var iPadMaxRowsDetailsButton = 0
    @State var maxRowsCategoryButton = 0
    @State var maxRowsDetailsButton = 0
    @State var maxEntryOfCategorys = 0
    @State var maxEntryOfDetails = 0
    @State var maxEntryOfPhotos = 0
    @State var iPadCheckBoxMatrixColumnWidth = 0
    @State var checkBoxMatrixColumnWidth = 0
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                Button {
                    iPadMaxColumnsCategoryButton = ConfigManager.initialIPadMainColumnNumber
                    iPadMaxColumnsDetailsButton = ConfigManager.initialIPadSubColumnNumber
                    iPadMaxColumnsPhotos = ConfigManager.initialIPadImageColumnNumber
                    maxColumnsCategoryButton = ConfigManager.initialMainColumnNumber
                    maxColumnsDetailsButton = ConfigManager.initialSubColumnNumber
                    maxColumnsPhotos = ConfigManager.initialImageColumnNumber
                    iPadMaxRowsCategoryButton = ConfigManager.initialIPadMainRowNumber
                    iPadMaxRowsDetailsButton = ConfigManager.initialIPadSubRowNumber
                    maxRowsCategoryButton = ConfigManager.initialMainRowNumber
                    maxRowsDetailsButton = ConfigManager.initialSubRowNumber
                    maxEntryOfCategorys = ConfigManager.initialMaxNumberOfMainCategory
                    maxEntryOfDetails = ConfigManager.initialMaxNumberOfSubCategory
                    maxEntryOfPhotos = ConfigManager.initialMaxNumberOfImageFile
                    iPadCheckBoxMatrixColumnWidth = ConfigManager.initialIPadCheckBoxMatrixColumnWidth
                    checkBoxMatrixColumnWidth = ConfigManager.initialCheckBoxMatrixColumnWidth
                } label: {
                    Text("Reset")
                        .frame(width: 80, height: 30)
                        .background(.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.trailing)
                }
                Button {
                    let jsonUrl = documentDirectoryUrl.appendingPathComponent("config.json")
                    let config = Config(iPadMaxColCatBtn: iPadMaxColumnsCategoryButton, iPadMaxColDetBtn: iPadMaxColumnsDetailsButton, iPadMaxColPhoto: iPadMaxColumnsPhotos,maxColCatBtn: maxColumnsCategoryButton, maxColDetBtn: maxColumnsDetailsButton, maxColPhoto: maxColumnsPhotos, iPadMaxRowCatBtn: iPadMaxRowsCategoryButton, iPadMaxRowDetBtn: iPadMaxRowsDetailsButton, maxRowCatBtn: maxRowsCategoryButton, maxRowDetBtn: maxRowsDetailsButton, maxEntCat: maxEntryOfCategorys, maxEntDet: maxEntryOfDetails, maxEntPhoto: maxEntryOfPhotos, iPadChkBoxMtxColWidth: iPadCheckBoxMatrixColumnWidth, chkBoxMtxColWidth: checkBoxMatrixColumnWidth)
                    JsonManager.write(fileUrl: jsonUrl, config: config)
                    showConfig = false
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 30, height: 30)
                        .background(.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.trailing)
                }
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                VStack(alignment: .leading) {
                    Text("Max columns of : ") + Text("Category Button")
                    Picker(selection: $iPadMaxColumnsCategoryButton, label: Text("Config1")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                        Text("6").tag(6)
                        Text("7").tag(7)
                        Text("8").tag(8)
                        Text("9").tag(9)
                        Text("10").tag(10)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max columns of : ") + Text("Details Button")
                    Picker(selection: $iPadMaxColumnsDetailsButton, label: Text("Config2")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                        Text("6").tag(6)
                        Text("7").tag(7)
                        Text("8").tag(8)
                        Text("9").tag(9)
                        Text("10").tag(10)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max columns of : ") + Text("Photos")
                    Picker(selection: $iPadMaxColumnsPhotos, label: Text("Config3")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                        Text("6").tag(6)
                        Text("7").tag(7)
                        Text("8").tag(8)
                        Text("9").tag(9)
                        Text("10").tag(10)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max rows of : ") +  Text("Category Button")
                    Picker(selection: $iPadMaxRowsCategoryButton, label: Text("Config4")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                        Text("6").tag(6)
                        Text("7").tag(7)
                        Text("8").tag(8)
                        Text("9").tag(9)
                        Text("10").tag(10)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max rows of : ") + Text("Details Button")
                    Picker(selection: $iPadMaxRowsDetailsButton, label: Text("Config5")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                        Text("6").tag(6)
                        Text("7").tag(7)
                        Text("8").tag(8)
                        Text("9").tag(9)
                        Text("10").tag(10)
                    }
                    .pickerStyle(.segmented)
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Max columns of : ") + Text("Category Button")
                    Picker(selection: $maxColumnsCategoryButton, label: Text("Config1")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max columns of : ") + Text("Details Button")
                    Picker(selection: $maxColumnsDetailsButton, label: Text("Config2")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max columns of : ") + Text("Photos")
                    Picker(selection: $maxColumnsPhotos, label: Text("Config3")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max rows of : ") +  Text("Category Button")
                    Picker(selection: $maxRowsCategoryButton, label: Text("Config4")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max rows of : ") + Text("Details Button")
                    Picker(selection: $maxRowsDetailsButton, label: Text("Config5")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
            }
            VStack(alignment: .leading) {
                Text("Max entry of : ") + Text("Categorys per plist")
                Picker(selection: $maxEntryOfCategorys, label: Text("Config6")) {
                    Text("9").tag(9)
                    Text("99").tag(99)
                    Text("999").tag(999)
                }
                .pickerStyle(.segmented)
            }
            VStack(alignment: .leading) {
                Text("Max entry of : ") + Text("Details per category")
                Picker(selection: $maxEntryOfDetails, label: Text("Config7")) {
                    Text("9").tag(9)
                    Text("99").tag(99)
                    Text("999").tag(999)
                }
                .pickerStyle(.segmented)
            }
            VStack(alignment: .leading) {
                Text("Max entry of : ") + Text("Photos per details")
                Picker(selection: $maxEntryOfPhotos, label: Text("Config8")) {
                    Text("9").tag(9)
                    Text("99").tag(99)
                    Text("999").tag(999)
                }
                .pickerStyle(.segmented)
            }
            VStack(alignment: .leading) {
                Text("Column width of : ") + Text("CheckBox Matrix")
                Picker(selection: $iPadCheckBoxMatrixColumnWidth, label: Text("Config9")) {
                    Text("50").tag(50)
                    Text("90").tag(90)
                    Text("130").tag(130)
                    Text("170").tag(170)
                    Text("210").tag(210)
                }
                .pickerStyle(.segmented)
            }
            VStack(alignment: .leading) {
                Text("Column width of : ") + Text("CheckBox Matrix")
                Picker(selection: $checkBoxMatrixColumnWidth, label: Text("Config10")) {
                    Text("40").tag(40)
                    Text("60").tag(60)
                    Text("80").tag(77)
                    Text("100").tag(100)
                    Text("120").tag(120)
                }
                .pickerStyle(.segmented)
            }
            Spacer()
                .onAppear {
                    initialLoad()
                }
                .onChange(of: iPadMaxColumnsCategoryButton ) { newValue in
                    ConfigManager.iPadMainColumnNumber = iPadMaxColumnsCategoryButton
                }
                .onChange(of: iPadMaxColumnsDetailsButton ) { newValue in
                    ConfigManager.iPadSubColumnNumber = iPadMaxColumnsDetailsButton
                }
                .onChange(of: iPadMaxColumnsPhotos ) { newValue in
                    ConfigManager.iPadImageColumnNumber = iPadMaxColumnsPhotos
                }
                .onChange(of: maxColumnsCategoryButton ) { newValue in
                    ConfigManager.mainColumnNumber = maxColumnsCategoryButton
                }
                .onChange(of: maxColumnsDetailsButton ) { newValue in
                    ConfigManager.subColumnNumber = maxColumnsDetailsButton
                }
                .onChange(of: maxColumnsPhotos ) { newValue in
                    ConfigManager.imageColumnNumber = maxColumnsPhotos
                }
                .onChange(of: iPadMaxRowsCategoryButton ) { newValue in
                    ConfigManager.iPadMainRowNumber = iPadMaxRowsCategoryButton
                }
                .onChange(of: iPadMaxRowsDetailsButton ) { newValue in
                    ConfigManager.iPadSubRowNumber = iPadMaxRowsDetailsButton
                }
                .onChange(of: maxRowsCategoryButton ) { newValue in
                    ConfigManager.mainRowNumber = maxRowsCategoryButton
                }
                .onChange(of: maxRowsDetailsButton ) { newValue in
                    ConfigManager.subRowNumber = maxRowsDetailsButton
                }
                .onChange(of: maxEntryOfCategorys ) { newValue in
                    ConfigManager.maxNumberOfMainCategory = maxEntryOfCategorys
                }
                .onChange(of: maxEntryOfDetails ) { newValue in
                    ConfigManager.maxNumberOfSubCategory = maxEntryOfDetails
                }
                .onChange(of: maxEntryOfPhotos ) { newValue in
                    ConfigManager.maxNumberOfImageFile = maxEntryOfPhotos
                }
                .onChange(of: iPadCheckBoxMatrixColumnWidth ) { newValue in
                    ConfigManager.iPadCheckBoxMatrixColumnWidth = iPadCheckBoxMatrixColumnWidth
                }
                .onChange(of: checkBoxMatrixColumnWidth ) { newValue in
                    ConfigManager.checkBoxMatrixColumnWidth = checkBoxMatrixColumnWidth
                }
        }
    }
    private func initialLoad() {
        let jsonUrl = documentDirectoryUrl.appendingPathComponent("config.json")
        if FileManager.default.fileExists(atPath: jsonUrl.path) {
            let config = JsonManager.load(fileUrl: jsonUrl)
            iPadMaxColumnsCategoryButton = config.iPadMaxColCatBtn
            iPadMaxColumnsDetailsButton = config.iPadMaxColDetBtn
            iPadMaxColumnsPhotos = config.iPadMaxColPhoto
            maxColumnsCategoryButton = config.maxColCatBtn
            maxColumnsDetailsButton = config.maxColDetBtn
            maxColumnsPhotos = config.maxColPhoto
            iPadMaxRowsCategoryButton = config.iPadMaxRowCatBtn
            iPadMaxRowsDetailsButton = config.iPadMaxRowDetBtn
            maxRowsCategoryButton = config.maxRowCatBtn
            maxRowsDetailsButton = config.maxRowDetBtn
            maxEntryOfCategorys = config.maxEntCat
            maxEntryOfDetails = config.maxEntDet
            maxEntryOfPhotos = config.maxEntPhoto
            iPadCheckBoxMatrixColumnWidth = config.iPadChkBoxMtxColWidth
            checkBoxMatrixColumnWidth = config.chkBoxMtxColWidth
        } else {
            iPadMaxColumnsCategoryButton = ConfigManager.iPadMainColumnNumber
            iPadMaxColumnsDetailsButton = ConfigManager.iPadSubColumnNumber
            iPadMaxColumnsPhotos = ConfigManager.iPadImageColumnNumber
            maxColumnsCategoryButton = ConfigManager.mainColumnNumber
            maxColumnsDetailsButton = ConfigManager.subColumnNumber
            maxColumnsPhotos = ConfigManager.imageColumnNumber
            iPadMaxRowsCategoryButton = ConfigManager.iPadMainRowNumber
            iPadMaxRowsDetailsButton = ConfigManager.iPadSubRowNumber
            maxRowsCategoryButton = ConfigManager.mainRowNumber
            maxRowsDetailsButton = ConfigManager.subRowNumber
            maxEntryOfCategorys = ConfigManager.maxNumberOfMainCategory
            maxEntryOfDetails = ConfigManager.maxNumberOfSubCategory
            maxEntryOfPhotos = ConfigManager.maxNumberOfImageFile
            iPadCheckBoxMatrixColumnWidth = ConfigManager.iPadCheckBoxMatrixColumnWidth
            checkBoxMatrixColumnWidth = ConfigManager.checkBoxMatrixColumnWidth
        }
    }
}
struct Config: Encodable, Decodable {
    var iPadMaxColCatBtn: Int
    var iPadMaxColDetBtn: Int
    var iPadMaxColPhoto: Int
    var maxColCatBtn: Int
    var maxColDetBtn: Int
    var maxColPhoto: Int
    var iPadMaxRowCatBtn: Int
    var iPadMaxRowDetBtn: Int
    var maxRowCatBtn: Int
    var maxRowDetBtn: Int
    var maxEntCat: Int
    var maxEntDet: Int
    var maxEntPhoto: Int
    var iPadChkBoxMtxColWidth: Int
    var chkBoxMtxColWidth: Int
}
class JsonManager {
    static func write(fileUrl: URL, config: Config) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(config) else { return }
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            try? jsonData.write(to: fileUrl)
        } else {
            FileManager.default.createFile(atPath: fileUrl.path, contents: jsonData, attributes: nil)
        }
    }
    static func load(fileUrl: URL) -> Config {
        let decoder = JSONDecoder()
        do {
            let jsonData = try Data.init(contentsOf: fileUrl)
            let config = try decoder.decode(Config.self, from: jsonData)
            return config
        } catch {
            print(error)
            return Config(iPadMaxColCatBtn: 0, iPadMaxColDetBtn: 0, iPadMaxColPhoto: 0, maxColCatBtn: 0, maxColDetBtn: 0, maxColPhoto: 0, iPadMaxRowCatBtn: 0, iPadMaxRowDetBtn: 0, maxRowCatBtn: 0, maxRowDetBtn: 0, maxEntCat: 0, maxEntDet: 0, maxEntPhoto: 0, iPadChkBoxMtxColWidth: 0, chkBoxMtxColWidth: 0)
        }
    }
}
