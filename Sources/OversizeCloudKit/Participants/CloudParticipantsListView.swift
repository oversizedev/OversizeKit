// Copyright © 2026 Alexander Romanov
// CloudParticipantsListView.swift

import OversizeCloudService
import OversizeResources
import OversizeUI
import SwiftUI

public struct CloudParticipantsListView: View {
    public let participants: [ShareParticipant]
    public let onTapParticipant: (ShareParticipant) -> Void
    public let onAdd: () -> Void
    public let onRemove: (ShareParticipant) -> Void

    @State private var participantPendingRemoval: ShareParticipant?

    public init(
        participants: [ShareParticipant],
        onTapParticipant: @escaping (ShareParticipant) -> Void,
        onAdd: @escaping () -> Void,
        onRemove: @escaping (ShareParticipant) -> Void
    ) {
        self.participants = participants
        self.onTapParticipant = onTapParticipant
        self.onAdd = onAdd
        self.onRemove = onRemove
    }

    public var body: some View {
        ListLayoutView("Participants") {
            ForEach(participants) { participant in
                ListRow(
                    participant.displayName,
                    subtitle: participant.permission.title,
                    leading: {
                        participantAvatar(participant)
                    },
                    trailing: {
                        statusBadge(participant)
                    },
                    action: {
                        onTapParticipant(participant)
                    }
                )
                .rowContentMargins(
                    .init(
                        top: .xSmall,
                        leading: .small,
                        bottom: .xSmall,
                        trailing: .small
                    )
                )
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        participantPendingRemoval = participant
                    } label: {
                        Label {
                            Text("Remove")
                        } icon: {
                            Image.Editor.Trash.fill
                        }
                    }
                    .tint(.error)
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") {
                    onAdd()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarPrimary)
                .keyboardShortcut(.defaultAction)
            }
        }
        .confirmationDialog(
            "Remove Access",
            isPresented: removeConfirmationBinding,
            titleVisibility: .visible
        ) {
            if let participantPendingRemoval {
                Button("Remove Access", role: .destructive) {
                    onRemove(participantPendingRemoval)
                    self.participantPendingRemoval = nil
                }
            }
            Button("Cancel", role: .cancel) {
                participantPendingRemoval = nil
            }
        } message: {
            Text("This participant will lose access to the shared content.")
        }
        .toolbarTitleDisplayMode(.inline)
    }

    private var removeConfirmationBinding: Binding<Bool> {
        Binding(
            get: { participantPendingRemoval != nil },
            set: { isPresented in
                if !isPresented { participantPendingRemoval = nil }
            }
        )
    }

    private func participantAvatar(_ participant: ShareParticipant) -> some View {
        Avatar(firstName: participant.avatarFirstName, lastName: participant.lastName)
            .controlSize(.regular)
            .overlay(alignment: .bottomTrailing) {
                if participant.acceptanceStatus != .accepted {
                    Circle()
                        .fill(participant.badgeColor)
                        .frame(width: 16, height: 16)
                        .background {
                            Circle()
                                .stroke(lineWidth: 4)
                                .fillBackgroundPrimary()
                        }
                    Image(systemName: participant.badgeSymbolName)
                        .onPrimary()
                        .font(.system(size: 9, weight: .black))
                }
            }
    }

    @ViewBuilder
    private func statusBadge(_ participant: ShareParticipant) -> some View {
        if participant.acceptanceStatus != .accepted {
            Badge(color: participant.badgeColor) {
                Text(participant.acceptanceStatus.title)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CloudParticipantsListView(
            participants: [
                ShareParticipant(
                    id: "1",
                    firstName: "Alice",
                    lastName: "Smith",
                    email: "alice@example.com",
                    acceptanceStatus: .accepted,
                    permission: .readWrite,
                    isOwner: false
                ),
                ShareParticipant(
                    id: "2",
                    firstName: "Bob",
                    lastName: "Jones",
                    email: "bob@example.com",
                    acceptanceStatus: .pending,
                    permission: .readOnly,
                    isOwner: false
                ),
                ShareParticipant(
                    id: "3",
                    firstName: "Chris",
                    lastName: "Stone",
                    email: nil,
                    acceptanceStatus: .removed,
                    permission: .readOnly,
                    isOwner: false
                ),
            ],
            onTapParticipant: { _ in },
            onAdd: {},
            onRemove: { _ in }
        )
    }
}
