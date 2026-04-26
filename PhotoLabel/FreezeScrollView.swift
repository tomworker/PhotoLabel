//
//  FreezeScrollView.swift
//  FreezeView
//
//  Created by tomworker on 2026/04/17.
//

import SwiftUI

/// A custom scroll view that supports frozen headers (rows and columns) and high-performance grid rendering.
///
/// Use this view to display large datasets in a spreadsheet-like format where top and left headers remain fixed.
struct FreezeScrollView<Anchor: View, Col: View, Row: View, Cell: View>: View {
    let rowCount: Int
    let columnCount: Int
    let cellSize: CGSize
    let freezeSize: CGSize
    let initialScroll: CGPoint
    
    /// ViewBuilder closures for custom subview injection.
    /// - col/row: Receives the current visible range and the specific index.
    /// - cell: Receives visible row/column ranges and the specific cell indices.
    let anchor: (ClosedRange<Int>) -> Anchor
    let col: (ClosedRange<Int>, Int) -> Col
    let row: (ClosedRange<Int>, Int) -> Row
    let cell: (ClosedRange<Int>, ClosedRange<Int>, Int, Int) -> Cell
    
    /// The state object managing scroll offsets and synchronization across components.
    @StateObject private var sharedScOffset: ScOffset
    
    /// Initializes a new FreezeScrollView with specific dimensions and view providers.
    init(
        rowCount: Int,
        columnCount: Int,
        cellSize: CGSize,
        freezeSize: CGSize,
        initialScroll: CGPoint,
        @ViewBuilder anchor: @escaping (ClosedRange<Int>) -> Anchor,
        @ViewBuilder col: @escaping (ClosedRange<Int>, Int) -> Col,
        @ViewBuilder row: @escaping (ClosedRange<Int>, Int) -> Row,
        @ViewBuilder cell: @escaping (ClosedRange<Int>, ClosedRange<Int>, Int, Int) -> Cell
    ) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.cellSize = cellSize
        self.freezeSize = freezeSize
        self.initialScroll = initialScroll
        self.anchor = anchor
        self.col = col
        self.row = row
        self.cell = cell
        _sharedScOffset = StateObject(wrappedValue: ScOffset(
            rowCount: rowCount,
            columnCount: columnCount,
            cellSize: cellSize,
            freezeSize: freezeSize,
            initialScroll: initialScroll
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Layout Initialization
                // Calculate content boundaries using hidden placeholder views before main rendering.
                if sharedScOffset.minValue.x == .zero  && sharedScOffset.maxValue.x == .zero && sharedScOffset.minValue.y == .zero && sharedScOffset.maxValue.y == .zero  {
                    InitializingXView(sharedScOffset: sharedScOffset, columnCount: columnCount, cellSize: cellSize)
                    InitializingYView(sharedScOffset: sharedScOffset, rowCount: rowCount, cellSize: cellSize)
                }
                
                // MARK: - Main Grid Layer
                // Render only the visible cells to maintain high frame rates even with large datasets.
                ScOffsetView(sharedScOffset: sharedScOffset) {
                    ZStack(alignment: .topLeading) {
                        let vRowRng = sharedScOffset.visibleRowRange
                        let vColRng = sharedScOffset.visibleColRange

                        ForEach(vRowRng, id: \.self) { idx1 in
                            ForEach(vColRng, id: \.self) { idx2 in
                                cell(sharedScOffset.visibleRowRange, sharedScOffset.visibleColRange, idx1, idx2)
                                    .frame(width: cellSize.width, height: cellSize.height)
                                    .position(
                                        x: CGFloat(idx2) * cellSize.width + (cellSize.width / 2),
                                        y: CGFloat(idx1) * cellSize.height + (cellSize.height / 2)
                                    )
                            }
                        }
                        .offset(
                            x: sharedScOffset.contentOffset.x,
                            y: sharedScOffset.contentOffset.y
                        )
                    }
                }
                
                // Fixed Top Column Headers
                VStack(spacing: 0) {
                    ScOffsetView(sharedScOffset: sharedScOffset) {
                        ZStack(alignment: .topLeading) {
                            ForEach(sharedScOffset.visibleColRange, id: \.self) { idx in
                                col(sharedScOffset.visibleColRange, idx)
                                    .frame(width: cellSize.width, height: freezeSize.height)
                                    .position(x: CGFloat(idx) * cellSize.width + (cellSize.width / 2), y: freezeSize.height / 2)
                            }
                        }
                        .offset(x: sharedScOffset.contentOffset.x)
                    }
                    .frame(height: freezeSize.height)
                    Spacer()
                }
                
                // Fixed Left Row Headers
                HStack(spacing: 0) {
                    ScOffsetView(sharedScOffset: sharedScOffset) {
                        ZStack(alignment: .topLeading) {
                            ForEach(sharedScOffset.visibleRowRange, id: \.self) { idx in
                                row(sharedScOffset.visibleRowRange, idx)
                                    .frame(width: freezeSize.width, height: cellSize.height)
                                    .position(x: freezeSize.width / 2, y: CGFloat(idx) * cellSize.height + (cellSize.height / 2))
                            }
                        }
                        .frame(width: freezeSize.width)
                        .offset(y: sharedScOffset.contentOffset.y)
                    }
                    .frame(width: freezeSize.width)
                    Spacer()
                }
                
                // Static Top-Left Anchor Point
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        anchor(sharedScOffset.visibleRowRange)
                            .frame(width: freezeSize.width, height: freezeSize.height)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onAppear {
                // Initial view size assignment to calculate the initial visible range.
                sharedScOffset.viewSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                sharedScOffset.viewSize = newSize
            }
        }
    }
    
    private struct InitializingXView: View {
        @ObservedObject var sharedScOffset: ScOffset
        let columnCount: Int
        let cellSize: CGSize
        
        var body: some View {
            HStack(spacing: 0) {
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minX")
                ForEach(Array(0..<columnCount).indices, id: \.self) { idx in
                    VStack(spacing: 0) {}
                        .frame(width: cellSize.width, height: 0)
                }
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxX")
            }
        }
    }
    
    private struct InitializingYView: View {
        @ObservedObject var sharedScOffset: ScOffset
        let rowCount: Int
        let cellSize: CGSize
        
        var body: some View {
            VStack(spacing: 0) {
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "minY")
                ForEach(Array(0..<rowCount).indices, id: \.self) { idx in
                    VStack(spacing: 0) {}
                        .frame(width: 0, height: cellSize.height)
                }
                SharedScOffsetInitializingView(sharedScOffset: sharedScOffset, boundingBox: "maxY")
            }
        }
    }
    
    private struct SharedScOffsetInitializingView: View {
        @ObservedObject var sharedScOffset: ScOffset
        var boundingBox: String
        
        var body: some View {
            VStack(spacing: 0) {}
                .background(GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        switch boundingBox {
                        case "minX":
                            if sharedScOffset.minValue.x == .zero { sharedScOffset.minValue.x = proxy.frame(in: .named("")).origin.x }
                        case "maxX":
                            if sharedScOffset.maxValue.x == .zero { sharedScOffset.maxValue.x = proxy.frame(in: .named("")).origin.x }
                        case "minY":
                            if sharedScOffset.minValue.y == .zero { sharedScOffset.minValue.y = proxy.frame(in: .named("")).origin.y }
                        case "maxY":
                            if sharedScOffset.maxValue.y == .zero { sharedScOffset.maxValue.y = proxy.frame(in: .named("")).origin.y }
                        default:
                            print("error")
                        }
                    }
                    return Color.clear
                })
        }
    }
}
