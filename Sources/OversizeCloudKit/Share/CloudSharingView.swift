// Copyright © 2026 Alexander Romanov
// CloudSharingView.swift

#if os(iOS)
import CloudKit
import SwiftUI

public struct CloudSharingView: UIViewControllerRepresentable {
    public let share: CKShare
    public let container: CKContainer
    public let onDismiss: () -> Void

    public init(share: CKShare, container: CKContainer, onDismiss: @escaping () -> Void) {
        self.share = share
        self.container = container
        self.onDismiss = onDismiss
    }

    public func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(
            share: share,
            container: container
        )
        controller.delegate = context.coordinator
        controller.availablePermissions = [.allowPrivate, .allowReadOnly, .allowReadWrite]
        return controller
    }

    public func updateUIViewController(_: UICloudSharingController, context _: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    // MARK: - Coordinator

    public final class Coordinator: NSObject, UICloudSharingControllerDelegate {
        let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        public func itemTitle(for _: UICloudSharingController) -> String? {
            ""
        }

        public func cloudSharingControllerDidSaveShare(_: UICloudSharingController) {
            DispatchQueue.main.async { self.onDismiss() }
        }

        public func cloudSharingControllerDidStopSharing(_: UICloudSharingController) {
            DispatchQueue.main.async { self.onDismiss() }
        }

        public func cloudSharingController(_: UICloudSharingController, failedToSaveShareWithError _: Error) {
            DispatchQueue.main.async { self.onDismiss() }
        }
    }
}
#endif
