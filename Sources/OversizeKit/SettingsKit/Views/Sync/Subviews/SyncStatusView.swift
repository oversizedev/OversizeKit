//
// Copyright © 2026 Alexander Romanov
// SyncStatusView.swift
//

import SwiftUI

struct SyncStatusView: View {
    let monitor: CloudSyncMonitor

    var body: some View {
        HStack(spacing: 8) {
            icon
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundStyle(tintColor)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tintColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .animation(.easeInOut, value: monitor.status)
    }

    private var title: String {
        switch monitor.status {
        case .idle:
            "iCloud is up to date"
        case let .syncing(message):
            message
        case .success:
            "Sync completed"
        case let .failed(message):
            "Sync failed: \(message)"
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch monitor.status {
        case .idle:
            Image(systemName: "icloud")
                .font(.system(size: 16, weight: .semibold))
        case .syncing:
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .symbolEffect(.rotate)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .semibold))
            }
        case .success:
            Image(systemName: "checkmark.icloud.fill")
                .font(.system(size: 16, weight: .semibold))
        case .failed:
            Image(systemName: "exclamationmark.icloud.fill")
                .font(.system(size: 16, weight: .semibold))
        }
    }

    private var tintColor: Color {
        switch monitor.status {
        case .idle:
            .secondary
        case .syncing:
            .blue
        case .success:
            .green
        case .failed:
            .red
        }
    }
}

#Preview {
    @Previewable @State var monitor = CloudSyncMonitor()
    SyncStatusView(monitor: monitor)
        .padding(.horizontal, 16)
}
