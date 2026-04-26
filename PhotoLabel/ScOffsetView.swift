//
//  ScOffsetView.swift
//  PhotoLabel
//
//  Created by tomworker on 2026/04/17.
//

import SwiftUI

struct ScOffsetView<Content: View>: UIViewControllerRepresentable {
    // MARK: - Dependencies
    private let sharedScOffset: ScOffset
    private let content: () -> Content
    
    init(sharedScOffset: ScOffset, @ViewBuilder _ content: @escaping () -> Content) {
        self.sharedScOffset = sharedScOffset
        self.content = content
    }
    
    // MARK: - Coordinator
    @MainActor
    class Coordinator: NSObject {
        var sharedScOffset: ScOffset

        init(sharedScOffset: ScOffset) {
            self.sharedScOffset = sharedScOffset
        }

        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
             sharedScOffset.onPanGesture(sender)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sharedScOffset: sharedScOffset)
    }
    
    // MARK: - Representable Methods
    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let viewController = UIHostingController(rootView: content())
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        viewController.view.addGestureRecognizer(panGesture)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        // Update references in case ScOffset has been swapped
        context.coordinator.sharedScOffset = sharedScOffset
        uiViewController.rootView = content()
    }
}

/// An observable controller that manages inertial scrolling, visibility ranges, and gesture handling.
@MainActor
class ScOffset: NSObject, ObservableObject {
    // MARK: - Configuration (Immutable)
    private let rowCount: Int
    private let columnCount: Int
    private let cellSize: CGSize
    private let freezeSize: CGSize
    
    // MARK: - Constants
    private let decelerationRate: CGFloat = 0.91 // Friction factor for inertia scrolling
    private let velocityThreshold: CGFloat = 5 // Minimum speed to maintain inertia
    
    // MARK: - Published State (UI Synchronization)
    @Published var contentOffset: CGPoint = .zero
    @Published var visibleRowRange: ClosedRange<Int> = 0...0
    @Published var visibleColRange: ClosedRange<Int> = 0...0
    @Published var isInitialized: Bool = false
    
    @Published var viewSize: CGSize = UIScreen.main.bounds.size {
        didSet { recalculateVisibleRange() }
    }
    
    // MARK: - Scroll Position Management
    @Published var deltaPosition: CGPoint = .zero
    
    // MARK: - Boundary Constraints
    @Published var minValue: CGPoint = .zero
    @Published var maxValue: CGPoint = .zero { didSet { checkInitialization() } }
    
    // MARK: - Gesture Interaction Data
    var initialValue: CGPoint = .zero
    var changedValue: CGPoint = .zero
    var endedValue: CGPoint = .zero
    var axesMode = ""
    
    // MARK: - Internal Private Logic State
    private var velocity: CGPoint = .zero
    private var deltaInertiaPosition: CGPoint = .zero
    private var lastUpdatePosition: CGPoint = .zero
    private var displayLink: CADisplayLink?
    
    init(rowCount: Int, columnCount: Int, cellSize: CGSize, freezeSize: CGSize, initialScroll: CGPoint = .zero) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.cellSize = cellSize
        self.freezeSize = freezeSize
        self.deltaPosition = initialScroll
        self.endedValue = initialScroll
            super.init()
    }
    
    @objc func onPanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            stopInertia()
            // Determine the primary scroll direction (Horizontal vs Vertical)
            if abs(sender.velocity(in:sender.view).x) > abs(sender.velocity(in:sender.view).y) {
                axesMode = "H"
                initialValue.x = -sender.location(in: sender.view).x - deltaInertiaPosition.x
            } else {
                axesMode = "V"
                initialValue.y = -sender.location(in: sender.view).y - deltaInertiaPosition.y
            }
        case .changed:
            if axesMode == "H" {
                changedValue.x = -sender.location(in: sender.view).x
                deltaPosition.x = (changedValue.x - initialValue.x + endedValue.x)
            } else {
                changedValue.y = -sender.location(in: sender.view).y
                deltaPosition.y = (changedValue.y - initialValue.y + endedValue.y)
            }
        case .ended, .cancelled:
            if axesMode == "H" {
                velocity = CGPoint(x: -sender.velocity(in: sender.view).x * 0.064, y: .zero)
            } else {
                velocity = CGPoint(x: .zero, y: -sender.velocity(in: sender.view).y * 0.064)
            }
            startInertiaScrolling(senderView: sender.view!)
            endedValue = deltaPosition
        default:
            break
        }
        
        // MARK: - Boundary Constraints
        // Ensure the scroll offset stays within the content bounds.
        if deltaPosition.x < 0 {
            deltaPosition.x = 0
        } else if maxValue.x != 0 {
            let limitX = (maxValue.x > viewSize.width) ? maxValue.x - minValue.x + freezeSize.width - viewSize.width : 0
            if deltaPosition.x > limitX { deltaPosition.x = limitX }
        }
        if deltaPosition.y < 0 {
            deltaPosition.y = 0
        } else if maxValue.y != 0 {
            let limitY = (maxValue.y > viewSize.height) ? maxValue.y - minValue.y + freezeSize.height - viewSize.height : 0
            if deltaPosition.y > limitY { deltaPosition.y = limitY }
        }
        
        updatePosition()
    }
    
    private func startInertiaScrolling(senderView: UIView) {
        deltaInertiaPosition = .zero
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateInertia))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Handles the frame-by-frame updates for inertia scrolling.
    @objc private func updateInertia() {
        // Apply friction to the current velocity
        velocity.x *= decelerationRate
        velocity.y *= decelerationRate
        
        let nextX = deltaPosition.x + velocity.x
        if nextX < 0 {
            deltaPosition.x = 0
        } else if isInitialized {
            let limitX = (maxValue.x > viewSize.width) ? maxValue.x - minValue.x + freezeSize.width - viewSize.width : 0
            if nextX > limitX {
                deltaPosition.x = limitX
                velocity.x = 0
            } else {
                deltaPosition.x = nextX
                deltaInertiaPosition.x += velocity.x
            }
        } else {
            deltaPosition.x = nextX
            deltaInertiaPosition.x += velocity.x
        }
        
        let nextY = deltaPosition.y + velocity.y
        if nextY < 0 {
            deltaPosition.y = 0
        } else if isInitialized {
            let limitY = (maxValue.y > viewSize.height) ? maxValue.y - minValue.y + freezeSize.height - viewSize.height : 0
            if nextY > limitY {
                deltaPosition.y = limitY
                velocity.y = 0
            } else {
                deltaPosition.y = nextY
                deltaInertiaPosition.y += velocity.y
            }
        } else {
            deltaPosition.y = nextY
            deltaInertiaPosition.y += velocity.y
        }
        
        updatePosition()
        
        // Stop the loop if the movement becomes negligible
        if abs(velocity.x) < velocityThreshold && abs(velocity.y) < velocityThreshold {
            stopInertia()
        }
    }
    
    private func stopInertia() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// Updates the published contentOffset and triggers range recalculation.
    private func updatePosition() {
        // Adjust coordinate system: offset (0,0) corresponds to the freeze corner.
        let newX = freezeSize.width - deltaPosition.x
        if contentOffset.x != newX { contentOffset.x = newX }
        
        let newY = freezeSize.height - deltaPosition.y
        if contentOffset.y != newY { contentOffset.y = newY }
        
        // Throttling: Only recalculate the visible range if the scroll distance exceeds the threshold.
        let threshold: CGFloat = 20
        if abs(lastUpdatePosition.x - deltaPosition.x) > threshold || abs(lastUpdatePosition.y - deltaPosition.y) > threshold || visibleRowRange == 0...0 {
            lastUpdatePosition = CGPoint(x: deltaPosition.x, y: deltaPosition.y)
            recalculateVisibleRange()
        }
    }
    
    /// Updates the visible row and column ranges based on the current scroll position.
    /// This is a critical optimization for rendering only visible elements.
    private func recalculateVisibleRange() {
        let screenWidth = viewSize.width
        let screenHeight = viewSize.height

        // Calculate the first visible indices based on offset
        let startRow = max(0, Int(deltaPosition.y / cellSize.height))
        let startCol = max(0, Int(deltaPosition.x / cellSize.width))

        // Calculate number of items fitting the screen with padding for smooth scrolling
        let rowsInView = Int(ceil(screenHeight / cellSize.height)) + 2
        let colsInView = Int(ceil(screenWidth / cellSize.width)) + 2

        let endRow = min(rowCount - 1, startRow + rowsInView)
        let endCol = min(columnCount - 1, startCol + colsInView)

        visibleRowRange = startRow...endRow
        visibleColRange = startCol...endCol
    }
    
    private func checkInitialization() {
        if maxValue.x != .zero && maxValue.y != .zero && !isInitialized {
            isInitialized = true
            updatePosition()
        }
    }
}
