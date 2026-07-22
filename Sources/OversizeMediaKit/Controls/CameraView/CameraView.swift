//
// Copyright © 2022 Alexander Romanov
// CameraView.swift
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
final class CameraView: UIViewController {
    let cameraController: CameraController = .init()
    var previewView: UIView!

    override func viewDidLoad() {
        previewView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(previewView)

        cameraController.prepare { error in
            if let error {
                print(error)
            }

            try? self.cameraController.displayPreview(on: self.previewView)
        }
    }
}

extension CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraView

    func makeUIViewController(context _: UIViewControllerRepresentableContext<CameraView>) -> CameraView {
        CameraView()
    }

    func updateUIViewController(_: CameraView, context _: UIViewControllerRepresentableContext<CameraView>) {}
}
#endif
