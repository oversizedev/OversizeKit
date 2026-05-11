//
// Copyright © 2026 Alexander Romanov
// CloudSyncMonitor.swift
//

import CoreData
import Observation

@MainActor
@Observable
final class CloudSyncMonitor {
    enum Status: Equatable {
        case idle
        case syncing(String)
        case success
        case failed(String)
    }

    var status: Status = .idle

    @ObservationIgnored
    private nonisolated(unsafe) var observer: NSObjectProtocol?

    func start() {
        observer = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard
                let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event
            else { return }

            let label = switch event.type {
            case .setup: "Setting up iCloud sync"
            case .import: "Downloading from iCloud"
            case .export: "Uploading to iCloud"
            @unknown default: "Syncing"
            }

            let newStatus: Status = if event.endDate == nil {
                .syncing(label)
            } else if let error = event.error {
                .failed(error.localizedDescription)
            } else if event.succeeded {
                .success
            } else {
                .idle
            }

            MainActor.assumeIsolated {
                self?.status = newStatus
            }
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
