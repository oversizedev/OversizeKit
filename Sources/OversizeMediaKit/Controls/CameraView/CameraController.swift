//
// Copyright © 2022 Alexander Romanov
// CameraController.swift
//

import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
@MainActor
class CameraController: NSObject {
    private var captureSession: AVCaptureSession?
    private var frontCamera: AVCaptureDevice?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            captureSession = AVCaptureSession()
        }

        func configureCaptureDevices() throws {
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                throw CameraControllerError.noCamerasAvailable
            }
            frontCamera = camera
            try camera.lockForConfiguration()
            camera.unlockForConfiguration()
        }

        func configureDeviceInputs() throws {
            guard let captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            guard let frontCamera else {
                throw CameraControllerError.noCamerasAvailable
            }

            frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(frontCameraInput!) {
                captureSession.addInput(frontCameraInput!)
            } else {
                throw CameraControllerError.inputsAreInvalid
            }

            captureSession.startRunning()
        }

        Task {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }

    @MainActor
    func displayPreview(on view: UIView) throws {
        guard let captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait

        view.layer.insertSublayer(previewLayer!, at: 0)
        previewLayer?.frame = view.bounds
    }
}

enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}
#endif
