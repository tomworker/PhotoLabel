//
//  plistEditorSubView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct PlistEditorSubView: View {
    @Binding var sCats: [SCatId]
    @ObservedObject var configManager = ConfigManager.shared
    @State private var selectedIndex: [Int] = [-1, -1]
    private var isAnySelected: Bool {
        selectedIndex[0] != -1 || selectedIndex[1] != -1
    }

    var body: some View {
        VStack {
            if isAnySelected {
                HStack {
                    if selectedIndex[0] != -1 && selectedIndex[1] != -1 {
                        ActionButton(title: "Change Places", action: changePlacePlist)
                    } else {
                        ActionButton(title: "Insert Blank", action: insertBlankPlist)
                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
            List {
                Section(header: Text("Input Photo Label ") + Text("Detail").font(.title)) {
                    ForEach($sCats) { $sCat in
                        let i = sCats.firstIndex(where: { $0.id == sCat.id }) ?? 0
                        HStack {
                            SelectionIndicator(item: i, selectedIndex: $selectedIndex)
                            Text(String(i + 1))
                                .frame(width: 32)
                            TextField("Detail", text: $sCat.subCategory)
                                .frame(maxWidth: .infinity)
                                .keyboardType(.default)
                            TextField("0", value: $sCat.countStoredImages, format: .number)
                                .frame(width: 25)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            .listStyle(.grouped)
        }
    }
    struct ActionButton: View {
        let title: String
        var width: CGFloat = 150
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                Text(title)
                    .frame(width: width, height: 30)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.leading)
            }
        }
    }
    private func insertBlankPlist() {
        let pos = selectedIndex[0] != -1 ? selectedIndex[0] : selectedIndex[1]
        guard pos != -1 else { return }
        if sCats.count < configManager.maxNumberOfSubCategory {
            let newSub = SCatId(subCategory: "", countStoredImages: 0, images: [])
            sCats.insert(newSub, at: pos)
        }
    }
    private func changePlacePlist() {
        let p1 = selectedIndex[0]
        let p2 = selectedIndex[1]
        guard p1 != -1 && p2 != -1 else { return }
        sCats.swapAt(p1, p2)
    }
}
struct SelectionIndicator: View {
    let item: Int
    @Binding var selectedIndex: [Int]
    private var isSelected: Bool { selectedIndex.contains(item) }
    private var color: Color {
        if selectedIndex[0] != -1 && selectedIndex[1] != -1 {
            return isSelected ? .blue : .gray
        }
        return .blue
    }

    var body: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .frame(width: 25)
            .foregroundColor(color)
            .onTapGesture { updateSelection() }
    }
    private func updateSelection() {
        if let idx = selectedIndex.firstIndex(of: item) {
            selectedIndex[idx] = -1
            if idx == 0 && selectedIndex[1] != -1 {
                selectedIndex[0] = selectedIndex[1]
                selectedIndex[1] = -1
            }
        } else {
            if selectedIndex[0] == -1 { selectedIndex[0] = item }
            else if selectedIndex[1] == -1 { selectedIndex[1] = item }
        }
    }
}
