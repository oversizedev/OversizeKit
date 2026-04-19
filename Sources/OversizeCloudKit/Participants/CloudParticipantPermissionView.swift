// Copyright © 2026 Alexander Romanov
// CloudParticipantPermissionView.swift

import OversizeCloudService
import OversizeResources
import OversizeUI
import SwiftUI

public struct CloudParticipantPermissionView: View {
    public let participant: ShareParticipant
    public let onUpdatePermission: (ShareParticipant.Permission) -> Void
    public let onRemove: () -> Void

    @State private var isShowingRemoveConfirmation = false
    @Environment(\.dismiss) private var dismiss

    public init(
        participant: ShareParticipant,
        onUpdatePermission: @escaping (ShareParticipant.Permission) -> Void,
        onRemove: @escaping () -> Void
    ) {
        self.participant = participant
        self.onUpdatePermission = onUpdatePermission
        self.onRemove = onRemove
    }

    public var body: some View {
        ListLayoutView {
            ListSection("Permission") {
                ForEach(ShareParticipant.Permission.allCases, id: \.self) { permission in
                    ListRow(
                        permission.title,
                        trailing: {
                            if participant.permission == permission {
                                Image.Base.check
                                    .foregroundStyle(Color.accent)
                            }
                        }
                    ) {
                        if participant.permission != permission {
                            onUpdatePermission(permission)
                        }
                    }
                }
            }

            ListSection {
                if let email = participant.email {
                    ListRow("Email", trailing: {
                        valueText(email)
                    })
                }

                ListRow("Role", trailing: {
                    valueText(participant.roleTitle)
                })

                ListRow("Status", trailing: {
                    valueText(participant.acceptanceStatus.title)
                })
            }

            ListSection {
                ListRow(
                    "Remove Access",
                    leading: {
                        Icon(Image.Editor.TrashWithLines.fill)
                            .iconColor(Color.error)
                    }
                ) {
                    isShowingRemoveConfirmation = true
                }
                .rowTextColor(Color.error)
            }
        }
        .listLayoutStyle(.insetGrouped)
        .safeAreaBarTop {
            avatarView
        }
        .confirmationDialog(
            "Remove Access",
            isPresented: $isShowingRemoveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove Access", role: .destructive) {
                onRemove()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This participant will lose access to the shared content.")
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
                #if !os(tvOS) && !os(watchOS)
                    .keyboardShortcut(.cancelAction)
                #endif
            }
        }
    }

    private var avatarView: some View {
        VStack(spacing: .medium) {
            participantAvatar

            VStack(spacing: .xSmall) {
                Text(participant.displayName)
                    .headline()
                    .onBackgroundPrimary()

                if participant.acceptanceStatus != .accepted {
                    Badge(color: participant.badgeColor) {
                        Text(participant.acceptanceStatus.title)
                    }
                }
            }
        }
        .padding(.bottom, .small)
    }

    private var participantAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
            Avatar(firstName: participant.avatarFirstName, lastName: participant.lastName)
                .controlSize(.extraLarge)

            ZStack {
                Circle()
                    .fill(participant.badgeColor)
                    .frame(width: 24, height: 24)
                    .background {
                        Circle()
                            .stroke(lineWidth: 4)
                            .fillBackgroundPrimary()
                    }
                Image(systemName: participant.badgeSymbolName)
                    .onPrimary()
                    .font(.system(size: 14, weight: .black))
            }
            .offset(.init(width: -2, height: -2))
        }
    }

    private func valueText(_ value: String) -> some View {
        Text(value)
            .subheadline()
            .foregroundStyle(Color.onSurfaceSecondary)
            .multilineTextAlignment(.trailing)
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                CloudParticipantPermissionView(
                    participant: ShareParticipant(
                        id: "_1234567890abcdef1234567890abcdef",
                        firstName: "John",
                        lastName: "Doe",
                        email: "john@example.com",
                        acceptanceStatus: .pending,
                        permission: .readOnly,
                        isOwner: false
                    ),
                    onUpdatePermission: { _ in },
                    onRemove: {}
                )
            }
        }
}
