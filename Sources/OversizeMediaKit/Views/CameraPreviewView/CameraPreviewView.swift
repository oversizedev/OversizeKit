//
// Copyright © 2022 Alexander Romanov
// CameraPreviewView.swift
//

import AVFoundation
import SwiftUI
#if os(iOS)
import UIKit

public struct CameraPreviewView: UIViewRepresentable {
    public init() {}

    public func makeUIView(context _: Context) -> CameraPreviewUIView {
        CameraPreviewUIView()
    }

    public func updateUIView(_: CameraPreviewUIView, context _: Context) {}

    public typealias UIViewType = CameraPreviewUIView
}

public class CameraPreviewUIView: UIView {
    private var captureSession: AVCaptureSession?

    public init() {
        super.init(frame: .zero)
        Task {
            guard await requestCameraAccess() else { return }
            await configureCaptureSession()
            await startSession()
        }
    }

    override public class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            Task { await stopSession() }
        } else if captureSession != nil {
            Task { await startSession() }
        }
    }

    private func requestCameraAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { allowedAccess in
                continuation.resume(returning: allowedAccess)
            }
        }
    }

    private func configureCaptureSession() async {
        let session = AVCaptureSession()
        session.beginConfiguration()

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput)
        else {
            return
        }

        session.addInput(videoDeviceInput)
        session.commitConfiguration()
        captureSession = session

        await MainActor.run {
            videoPreviewLayer.session = captureSession
            videoPreviewLayer.videoGravity = .resizeAspectFill
        }
    }

    private func startSession() async {
        guard let captureSession else { return }
        nonisolated(unsafe) let session = captureSession
        await Task.detached(priority: .userInitiated) {
            session.startRunning()
        }.value
    }

    private func stopSession() async {
        guard let captureSession else { return }
        nonisolated(unsafe) let session = captureSession
        await Task.detached(priority: .userInitiated) {
            session.stopRunning()
        }.value
    }
}

#Preview {
    CameraPreviewView()
        .ignoresSafeArea()
}

#endif
