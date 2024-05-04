//
//  AppVersionView.swift
//  PhotoLabel
//
//  Created by tomworker on 2024/05/04.
//

import SwiftUI

struct AppVersionView: View {
    @Binding var showAppVersion: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showAppVersion = false
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 30, height: 30)
                        .background(.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.trailing)
                }
            }
            HStack {
                Text(" ")
                VStack(alignment: .leading) {
                    if let currentAppVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                        Text("Current App Version: \(currentAppVersionString)")
                    }
                    Text("")
                    Text("Instruction:")
                    Text("- Create a new photo labels on the top screen.")
                    Text(" 1. Press 'New Photo Labels' button.")
                    Text(" 2. Input a category name.")
                    Text(" 3. Input a subcategory(detail) name.")
                    Text(" 4. Enter a file name.")
                    Text(" 5. Execute the save button")
                    Text(" 6. Select newly created list item(.plist).")
                }
            }
            Spacer()
        }
    }
}
