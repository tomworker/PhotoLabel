//
//  CameraView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/09/15.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var photoCapture: PhotoCapture

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black

        let previewLayer = photoCapture.videoPreviewLayer!
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = viewController.view.bounds
        viewController.view.layer.addSublayer(previewLayer)

        context.coordinator.setupGestures(for: viewController.view)
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let layer = uiViewController.view.layer.sublayers?.first {
            layer.frame = uiViewController.view.bounds
        }
        if photoCapture.isFlipCameraDevice {
            uiViewController.view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

            let newLayer = photoCapture.videoPreviewLayer!
            newLayer.videoGravity = .resizeAspectFill
            newLayer.frame = uiViewController.view.bounds
            uiViewController.view.layer.addSublayer(newLayer)

            DispatchQueue.main.async {
                self.photoCapture.isFlipCameraDevice = false
            }
        }
    }
}
class Coordinator: NSObject {
    var parent: CameraView
    init(_ parent: CameraView) {
        self.parent = parent
    }
    func setupGestures(for view: UIView) {
        let pan = UIPanGestureRecognizer(target: parent.photoCapture, action: #selector(PhotoCapture.onPanGesture(_:)))
        let pinch = UIPinchGestureRecognizer(target: parent.photoCapture, action: #selector(PhotoCapture.onPinchGesture(_:)))
        let tap = UITapGestureRecognizer(target: parent.photoCapture, action: #selector(PhotoCapture.onTapGesture(_:)))
        let longPress = UILongPressGestureRecognizer(target: parent.photoCapture, action: #selector(PhotoCapture.onLongPressGesture(_:)))
        tap.require(toFail: longPress)
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(longPress)
    }
}
