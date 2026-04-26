//
//  ConfigView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/30.
//

import SwiftUI

struct ConfigView: View {
    @Binding var showConfig: Bool
    @ObservedObject var configManager = ConfigManager.shared
    let tempDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp", isDirectory: true)
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                Button {
                    configManager.iPadMainColumnNumber = ConfigManager.initialIPadMainColumnNumber
                    configManager.iPadSubColumnNumber = ConfigManager.initialIPadSubColumnNumber
                    configManager.iPadImageColumnNumber = ConfigManager.initialIPadImageColumnNumber
                    configManager.mainColumnNumber = ConfigManager.initialMainColumnNumber
                    configManager.subColumnNumber = ConfigManager.initialSubColumnNumber
                    configManager.imageColumnNumber = ConfigManager.initialImageColumnNumber
                    configManager.iPadMainRowNumber = ConfigManager.initialIPadMainRowNumber
                    configManager.iPadSubRowNumber = ConfigManager.initialIPadSubRowNumber
                    configManager.mainRowNumber = ConfigManager.initialMainRowNumber
                    configManager.subRowNumber = ConfigManager.initialSubRowNumber
                    configManager.maxNumberOfMainCategory = ConfigManager.initialMaxNumberOfMainCategory
                    configManager.maxNumberOfSubCategory = ConfigManager.initialMaxNumberOfSubCategory
                    configManager.maxNumberOfImageFile = ConfigManager.initialMaxNumberOfImageFile
                    configManager.iPadCheckBoxMatrixColumnWidth = ConfigManager.initialIPadCheckBoxMatrixColumnWidth
                    configManager.checkBoxMatrixColumnWidth = ConfigManager.initialCheckBoxMatrixColumnWidth
                    configManager.maxColumnsCheckBoxMatrix = ConfigManager.initialMaxColumnsCheckBoxMatrix
                } label: {
                    Text("Reset")
                        .frame(width: 80, height: 30)
                        .background(.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.trailing)
                }
                Button {
                    saveToFile()
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
                    Text("Max columns of : Category Button")
                    Picker(selection: $configManager.iPadMainColumnNumber, label: Text("Config1")) {
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
                    Text("Max columns of : Details Button")
                    Picker(selection: $configManager.iPadSubColumnNumber, label: Text("Config2")) {
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
                    Text("Max columns of : Photos")
                    Picker(selection: $configManager.iPadImageColumnNumber, label: Text("Config3")) {
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
                    Text("Max rows of : Category Button")
                    Picker(selection: $configManager.iPadMainRowNumber, label: Text("Config4")) {
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
                    Text("Max rows of : Details Button")
                    Picker(selection: $configManager.iPadSubRowNumber, label: Text("Config5")) {
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
                    Text("Column width of : CheckSheet")
                    Picker(selection: $configManager.iPadCheckBoxMatrixColumnWidth, label: Text("Config9")) {
                        Text("50").tag(50)
                        Text("90").tag(90)
                        Text("130").tag(130)
                        Text("170").tag(170)
                        Text("210").tag(210)
                    }
                    .pickerStyle(.segmented)
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Max columns of : Category Button")
                    Picker(selection: $configManager.mainColumnNumber, label: Text("Config1")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max columns of : Details Button")
                    Picker(selection: $configManager.subColumnNumber, label: Text("Config2")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max columns of : Photos")
                    Picker(selection: $configManager.imageColumnNumber, label: Text("Config3")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max rows of : Category Button")
                    Picker(selection: $configManager.mainRowNumber, label: Text("Config4")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Max rows of : Details Button")
                    Picker(selection: $configManager.subRowNumber, label: Text("Config5")) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                        Text("5").tag(5)
                    }
                    .pickerStyle(.segmented)
                }
                VStack(alignment: .leading) {
                    Text("Column width of : CheckSheet")
                    Picker(selection: $configManager.checkBoxMatrixColumnWidth, label: Text("Config10")) {
                        Text("40").tag(40)
                        Text("60").tag(60)
                        Text("80").tag(77)
                        Text("100").tag(100)
                        Text("120").tag(120)
                    }
                    .pickerStyle(.segmented)
                }
            }
            VStack(alignment: .leading) {
                Text("Max entry of : Categorys per plist")
                Picker(selection: $configManager.maxNumberOfMainCategory, label: Text("Config6")) {
                    Text("9").tag(9)
                    Text("99").tag(99)
                    Text("999").tag(999)
                }
                .pickerStyle(.segmented)
            }
            VStack(alignment: .leading) {
                Text("Max entry of : Details per category")
                Picker(selection: $configManager.maxNumberOfSubCategory, label: Text("Config7")) {
                    Text("9").tag(9)
                    Text("99").tag(99)
                    Text("999").tag(999)
                }
                .pickerStyle(.segmented)
            }
            VStack(alignment: .leading) {
                Text("Max entry of : Photos per details")
                Picker(selection: $configManager.maxNumberOfImageFile, label: Text("Config8")) {
                    Text("9").tag(9)
                    Text("99").tag(99)
                    Text("999").tag(999)
                }
                .pickerStyle(.segmented)
            }
            VStack(alignment: .leading) {
                Text("Max columns of : CheckSheet")
                Picker(selection: $configManager.maxColumnsCheckBoxMatrix, label: Text("Config11")) {
                    Text("5").tag(5)
                    Text("10").tag(10)
                    Text("100").tag(100)
                }
                .pickerStyle(.segmented)
            }
            Spacer()
        }
        .onAppear {
            initialLoad()
        }
    }
    private func initialLoad() {
        let jsonUrl = documentDirectoryUrl.appendingPathComponent("config.json")
        if FileManager.default.fileExists(atPath: jsonUrl.path) {
            let config = JsonManager.load(fileUrl: jsonUrl)
            configManager.iPadMainColumnNumber = config.iPadMaxColCatBtn
            configManager.iPadSubColumnNumber = config.iPadMaxColDetBtn
            configManager.iPadImageColumnNumber = config.iPadMaxColPhoto
            configManager.mainColumnNumber = config.maxColCatBtn
            configManager.subColumnNumber = config.maxColDetBtn
            configManager.imageColumnNumber = config.maxColPhoto
            configManager.iPadMainRowNumber = config.iPadMaxRowCatBtn
            configManager.iPadSubRowNumber = config.iPadMaxRowDetBtn
            configManager.mainRowNumber = config.maxRowCatBtn
            configManager.subRowNumber = config.maxRowDetBtn
            configManager.maxNumberOfMainCategory = config.maxEntCat
            configManager.maxNumberOfSubCategory = config.maxEntDet
            configManager.maxNumberOfImageFile = config.maxEntPhoto
            configManager.iPadCheckBoxMatrixColumnWidth = config.iPadChkBoxMtxColWidth
            configManager.checkBoxMatrixColumnWidth = config.chkBoxMtxColWidth
            configManager.maxColumnsCheckBoxMatrix = config.maxColChkBoxMtx
        }
    }
    private func saveToFile() {
        let jsonUrl = documentDirectoryUrl.appendingPathComponent("config.json")
        let config = Config(
            iPadMaxColCatBtn: configManager.iPadMainColumnNumber,
            iPadMaxColDetBtn: configManager.iPadSubColumnNumber,
            iPadMaxColPhoto: configManager.iPadImageColumnNumber,
            maxColCatBtn: configManager.mainColumnNumber,
            maxColDetBtn: configManager.subColumnNumber,
            maxColPhoto: configManager.imageColumnNumber,
            iPadMaxRowCatBtn: configManager.iPadMainRowNumber,
            iPadMaxRowDetBtn: configManager.iPadSubRowNumber,
            maxRowCatBtn: configManager.mainRowNumber,
            maxRowDetBtn: configManager.subRowNumber,
            maxEntCat: configManager.maxNumberOfMainCategory,
            maxEntDet: configManager.maxNumberOfSubCategory,
            maxEntPhoto: configManager.maxNumberOfImageFile,
            iPadChkBoxMtxColWidth: configManager.iPadCheckBoxMatrixColumnWidth,
            chkBoxMtxColWidth: configManager.checkBoxMatrixColumnWidth,
            maxColChkBoxMtx: configManager.maxColumnsCheckBoxMatrix
        )
        JsonManager.write(fileUrl: jsonUrl, config: config)
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
    var maxColChkBoxMtx: Int
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
            return Config(iPadMaxColCatBtn: 0, iPadMaxColDetBtn: 0, iPadMaxColPhoto: 0, maxColCatBtn: 0, maxColDetBtn: 0, maxColPhoto: 0, iPadMaxRowCatBtn: 0, iPadMaxRowDetBtn: 0, maxRowCatBtn: 0, maxRowDetBtn: 0, maxEntCat: 0, maxEntDet: 0, maxEntPhoto: 0, iPadChkBoxMtxColWidth: 0, chkBoxMtxColWidth: 0, maxColChkBoxMtx: 0)
        }
    }
}
