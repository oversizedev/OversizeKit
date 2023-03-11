//
// Copyright © 2023 Alexander Romanov
// NotificationSetScreen.swift
//

import EventKit
import OversizeUI
import UserNotifications

import SwiftUI

public struct LocalNotificationSetScreen: View {
    @Environment(\.dismiss) var dismiss
    // @Binding private var selection: [LocalNotificationAlertsTimes]
    // @State private var selectedAlerts: [LocalNotificationAlertsTimes] = []

    public init( /* selection: Binding<[LocalNotificationAlertsTimes]> */ ) {
        // _selection = selection
        // _selectedAlerts = State(wrappedValue: selection.wrappedValue)
    }

    public var body: some View {
        PageView("Alarm") {
            SectionView {
                VStack(spacing: .zero) {
                    Button("Schedule Notification") {}
                        .buttonStyle(.borderedProminent)
                }
            }
            .surfaceContentRowInsets()
        }
        .backgroundSecondary()
        .leadingBar {
            BarButton(.close)
        }
        // .trailingBar {
        //    if selectedAlerts.isEmpty {
        //        BarButton(.disabled("Done"))
        //    } else {
        //        BarButton(.accent("Done", action: {
        //            selection = selectedAlerts
        //            dismiss()
        //        }))
        //    }
        // }
    }

    func set2() {
        let content = UNMutableNotificationContent()
        content.title = "task.name"
        content.body = "Gentle reminder for your task!"

        // 3
        var trigger: UNNotificationTrigger?

        trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 4, repeats: false
        )

        // 4
        if let trigger {
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            // 5
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print(error)
                }
            }
        }
        //
    }

    func setAlert() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            print(success ? "Authorization success" : "Authorization failed")
            print(error?.localizedDescription ?? "")
        }

        let content = UNMutableNotificationContent()
        content.title = "Hey DevTechie!"
        content.subtitle = "Check out DevTechie.com"
        content.body = "We have video courses!!!"
        content.sound = UNNotificationSound.default
        let imageName = "DT"
        if let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") {
            let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)

            content.attachments = [attachment]
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "com.devtechie.notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print(error)
            }
        }
    }
}
