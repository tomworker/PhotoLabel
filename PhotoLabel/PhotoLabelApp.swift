//
//  PhotoLabelApp.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

@main
struct PhotoLabelApp: App {
    @StateObject private var alertCenter = AlertCenter()

    var body: some Scene {
        WindowGroup {
            ContentView(workSpace: [], showCategorySelector: [], isRemove: [])
                .environmentObject(alertCenter)
        }
    }
}
