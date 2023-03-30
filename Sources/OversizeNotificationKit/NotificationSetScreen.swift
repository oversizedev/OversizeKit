//
// Copyright © 2023 Alexander Romanov
// NotificationSetScreen.swift
//

/*
 import OversizeUI
 import UserNotifications
 import OversizeNotificationService
 import SwiftUI

 public struct LocalNotificationSetScreen: View {

     @Environment(\.dismiss) var dismiss
     @StateObject var viewModel: LocalNotificationSetScreenViewModel
     @Binding private var selection: [LocalNotificationAlertsTimes]
     @State private var selectedAlerts: [LocalNotificationAlertsTimes] = []
     private let notification: LocalNotification

     public init(selection: Binding<[LocalNotificationAlertsTimes]>, notification: LocalNotification) {
         _selection = selection
         _selectedAlerts = State(wrappedValue: selection.wrappedValue)
         _viewModel = StateObject(wrappedValue: LocalNotificationSetScreenViewModel())
         self.notification = notification
     }

     public var body: some View {
         PageView("Alarm") {
             SectionView {
                 VStack(spacing: .zero) {
                     ForEach(LocalNotificationAlertsTimes.allCases) { alert in
                         Checkbox(alert.title, isOn: .constant((selectedAlerts.first { $0.id == alert.id } != nil) ? true : false)) {
                             if !selectedAlerts.isEmpty, let index = selectedAlerts.firstIndex(where: { $0.id == alert.id }) {
                                 selectedAlerts.remove(at: index)
                             } else {
                                 selectedAlerts.append(alert)
                             }
                         }
                     }
                 }
             }
             .surfaceContentRowInsets()
         }
         .backgroundSecondary()
         .leadingBar {
             BarButton(.close)
         }
         .trailingBar {
             if selectedAlerts.isEmpty {
                 BarButton(.disabled("Done"))
             } else {
                 BarButton(.accent("Done", action: {
                     selection = selectedAlerts
                     dismiss()
                 }))
             }
          }
     }
 }
 */
