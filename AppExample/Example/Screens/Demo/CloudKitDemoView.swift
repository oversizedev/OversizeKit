//
// Copyright © 2026 Alexander Romanov
// CloudKitDemoView.swift, created on 19.09.2026
//

import OversizeCloudKit
import OversizeCloudService
import OversizeUI
import SwiftUI

struct CloudKitDemoView: View {
    @State private var participants: [ShareParticipant] = ShareParticipant.demoParticipants
    @State private var selectedParticipant: ShareParticipant?

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                SectionView("Participants") {
                    CloudParticipantsListView(
                        participants: participants,
                        onTapParticipant: { selectedParticipant = $0 },
                        onAdd: {},
                        onRemove: { participant in
                            participants.removeAll { $0.id == participant.id }
                        }
                    )
                }

                SectionView("Sharing") {
                    Row(
                        "CloudSharingView",
                        subtitle: "Needs a real CKShare and CloudKit container, so it is not part of the demo"
                    ) {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                }
                .sectionContentCompactRowMargins()
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Cloud")
        .sheet(item: $selectedParticipant) { participant in
            NavigationStack {
                CloudParticipantPermissionView(
                    participant: participant,
                    onUpdatePermission: { permission in
                        updatePermission(permission, for: participant)
                    },
                    onRemove: {
                        participants.removeAll { $0.id == participant.id }
                    }
                )
            }
        }
    }

    private func updatePermission(_ permission: ShareParticipant.Permission, for participant: ShareParticipant) {
        guard let index = participants.firstIndex(where: { $0.id == participant.id }) else { return }
        let updated = ShareParticipant(
            id: participant.id,
            firstName: participant.firstName,
            lastName: participant.lastName,
            email: participant.email,
            acceptanceStatus: participant.acceptanceStatus,
            permission: permission,
            isOwner: participant.isOwner
        )
        participants[index] = updated
        selectedParticipant = updated
    }
}

private extension ShareParticipant {
    static let demoParticipants: [ShareParticipant] = [
        ShareParticipant(
            id: "owner",
            firstName: "Alexander",
            lastName: "Romanov",
            email: "hello@oversize.app",
            acceptanceStatus: .accepted,
            permission: .readWrite,
            isOwner: true
        ),
        ShareParticipant(
            id: "editor",
            firstName: "Kate",
            lastName: "Smith",
            email: "kate@oversize.app",
            acceptanceStatus: .accepted,
            permission: .readWrite,
            isOwner: false
        ),
        ShareParticipant(
            id: "viewer",
            firstName: nil,
            lastName: nil,
            email: "guest@oversize.app",
            acceptanceStatus: .pending,
            permission: .readOnly,
            isOwner: false
        ),
    ]
}

#Preview {
    NavigationStack {
        CloudKitDemoView()
    }
    .appEnvironment()
}
