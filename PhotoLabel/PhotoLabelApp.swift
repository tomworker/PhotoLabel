//
//  PhotoLabelApp.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

@main
struct PhotoLabelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var alertCenter = AlertCenter()
    var body: some Scene {
        WindowGroup {
            ContentView(workSpace: [], showPlistEditor: [], showCategorySelector: [], isRemove: [])
                .environmentObject(alertCenter)
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
