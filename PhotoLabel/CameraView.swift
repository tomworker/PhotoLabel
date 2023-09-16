//
//  CameraView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/09/15.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var caLayer: CALayer
    @State var photoCapture: PhotoCapture
    @State var viewController = UIViewController()
    @State var caLayer2: CALayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIViewController {
        caLayer.frame = viewController.view.bounds
        viewController.view.layer.addSublayer(caLayer)
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<CameraView>) {
        caLayer.frame = viewController.view.bounds
        if photoCapture.isFlipCameraDevice == true {
            viewController.view.layer.replaceSublayer((viewController.view.layer.sublayers?.first)!, with: photoCapture.videoPreviewLayer)
            viewController.view.layer.sublayers?.first?.frame = viewController.view.bounds
            photoCapture.isFlipCameraDevice = false
        }
    }
    func onPanGesture() -> Self {
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: photoCapture, action: #selector(photoCapture.onPanGesture(_:)))
        viewController.view.addGestureRecognizer(panGesture)
        return self
    }
    func onPinchGesture() -> Self {
        let pinchGesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: photoCapture, action: #selector(photoCapture.onPinchGesture(_:)))
        viewController.view.addGestureRecognizer(pinchGesture)
        return self
    }
    func onTapGesture() -> Self {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: photoCapture, action: #selector(photoCapture.onTapGesture(_:)))
        viewController.view.addGestureRecognizer(tapGesture)
        return self
    }
    func onLongPressGesture() -> Self {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: photoCapture, action: #selector(photoCapture.onLongPressGesture(_:)))
        viewController.view.addGestureRecognizer(longPressGesture)
        return self
    }
}
