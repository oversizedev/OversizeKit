// Copyright © 2026 Alexander Romanov
// CloudSharingView.swift

#if os(iOS)
import CloudKit
import SwiftUI

public struct CloudSharingView: UIViewControllerRepresentable {
    public let share: CKShare
    public let container: CKContainer
    public let onDismiss: (CKShare?) -> Void

    public init(share: CKShare, container: CKContainer, onDismiss: @escaping (CKShare?) -> Void) {
        self.share = share
        self.container = container
        self.onDismiss = onDismiss
    }

    public func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
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
        let onDismiss: (CKShare?) -> Void

        init(onDismiss: @escaping (CKShare?) -> Void) {
            self.onDismiss = onDismiss
        }

        public func itemTitle(for _: UICloudSharingController) -> String? {
            nil
        }

        public func cloudSharingControllerDidSaveShare(_ controller: UICloudSharingController) {
            DispatchQueue.main.async { self.onDismiss(controller.share) }
        }

        public func cloudSharingControllerDidStopSharing(_: UICloudSharingController) {
            DispatchQueue.main.async { self.onDismiss(nil) }
        }

        public func cloudSharingController(_: UICloudSharingController, failedToSaveShareWithError _: Error) {
            DispatchQueue.main.async { self.onDismiss(nil) }
        }
    }
}
#endif
