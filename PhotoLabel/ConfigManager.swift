//
//  ConfigManager.swift
//  PhotoLabel
//
//  Created by tomworker on 2026/04/18.
//

import SwiftUI

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var iPadMainColumnNumber = 6
    @Published var iPadSubColumnNumber = 4
    @Published var iPadImageColumnNumber = 5
    @Published var mainColumnNumber = 3
    @Published var subColumnNumber = 2
    @Published var imageColumnNumber = 2
    @Published var iPadMainRowNumber = 5
    @Published var iPadSubRowNumber = 5
    @Published var mainRowNumber = 3
    @Published var subRowNumber = 3
    @Published var maxNumberOfMainCategory = 99
    @Published var maxNumberOfSubCategory = 999
    @Published var maxNumberOfImageFile = 999
    @Published var iPadCheckBoxMatrixColumnWidth = 90
    @Published var checkBoxMatrixColumnWidth = 60
    @Published var maxColumnsCheckBoxMatrix: Int = 5
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
    static let initialMaxColumnsCheckBoxMatrix = 5
    
    func loadFromLocalConfig() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("config.json")
        if FileManager.default.fileExists(atPath: url.path) {
            let config = JsonManager.load(fileUrl: url)
            iPadMainColumnNumber = config.iPadMaxColCatBtn
            iPadSubColumnNumber = config.iPadMaxColDetBtn
            iPadImageColumnNumber = config.iPadMaxColPhoto
            mainColumnNumber = config.maxColCatBtn
            subColumnNumber = config.maxColDetBtn
            imageColumnNumber = config.maxColPhoto
            iPadMainRowNumber = config.iPadMaxRowCatBtn
            iPadSubRowNumber = config.iPadMaxRowDetBtn
            mainRowNumber = config.maxRowCatBtn
            subRowNumber = config.maxRowDetBtn
            maxNumberOfMainCategory = config.maxEntCat
            maxNumberOfSubCategory = config.maxEntDet
            maxNumberOfImageFile = config.maxEntPhoto
            iPadCheckBoxMatrixColumnWidth = config.iPadChkBoxMtxColWidth
            checkBoxMatrixColumnWidth = config.chkBoxMtxColWidth
            maxColumnsCheckBoxMatrix = config.maxColChkBoxMtx
        }
    }
}
