//
// Copyright © 2026 Alexander Romanov
// NotificationKitDemoView.swift, created on 19.09.2026
//

import OversizeNotificationKit
import OversizeUI
import SwiftUI

struct NotificationKitDemoView: View {
    @State private var time: LocalNotificationTime = .oneHourBefore
    @State private var isShowNotification = false
    @State private var scheduledID: UUID?

    private let notificationID = UUID()
    private let date = Date().addingTimeInterval(86400)

    var body: some View {
        ScrollView {
            SectionView("Screens") {
                VStack(spacing: .zero) {
                    Row("Local notification", subtitle: time.title) {
                        isShowNotification = true
                    } leading: {
                        Image(systemName: "bell.badge")
                    }
                    .navigatable()
                    .buttonStyle(.row)

                    if let scheduledID {
                        Row("Scheduled", subtitle: scheduledID.uuidString)
                    }
                }
            }
            .sectionContentCompactRowMargins()
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Notification")
        .sheet(isPresented: $isShowNotification) {
            NavigationStack {
                LocalNotificationView(
                    $time,
                    id: notificationID,
                    title: "Example",
                    body: "Local notification scheduled by OversizeNotificationKit",
                    date: date
                ) { id in
                    scheduledID = id
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationKitDemoView()
    }
    .appEnvironment()
}
