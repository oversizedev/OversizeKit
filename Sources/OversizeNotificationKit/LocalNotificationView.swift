//
// Copyright © 2023 Alexander Romanov
// LocalNotificationView.swift
//

import OversizeKit
import OversizeNotificationService
import OversizeUI
import SwiftUI
import UserNotifications

public struct LocalNotificationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding private var selection: LocalNotificationTime
    @State private var isPendingNotification: Bool = false
    @StateObject var viewModel: LocalNotificationSetScreenViewModel
    private let saveAction: ((UUID?) -> Void)?

    public init(
        _ selection: Binding<LocalNotificationTime>,
        id: UUID,
        title: String,
        body: String,
        date: Date,
        userInfo: [AnyHashable: Any]? = nil,
        saveAction: ((UUID?) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: LocalNotificationSetScreenViewModel(
            id: id,
            date: date,
            title: title,
            body: body,
            userInfo: userInfo
        ))
        _selection = selection
        self.saveAction = saveAction
    }

    public var body: some View {
        switch viewModel.state {
        case .initial:
            contnent
                .task {
                    await viewModel.requestAccsess()
                }
        case .result:
            contnent
                .task {
                    let pendingStatus = await viewModel.fetchPandingNotification()
                    if pendingStatus {
                        isPendingNotification = true
                    }
                }
        case let .error(error):
            PageView("Notification") {
                ErrorView(error)
            }
            .leadingBar {
                BarButton(.close)
            }
        }
    }

    public var contnent: some View {
        // let notificationDate = viewModel.date.addingTimeInterval(selection.timeInterval)
        PageView("Notification") {
            VStack(spacing: .zero) {
                SectionView {
                    LazyVStack(spacing: .zero) {
                        ForEach(LocalNotificationTime.allCases) { notificationTime in
//                            let notificationDate = viewModel.date.addingTimeInterval(notificationTime.timeInterval)
//                            if notificationDate  viewModel.date {
                            Radio(notificationTime.title, isOn: selection.id == notificationTime.id) {
                                selection = notificationTime
                            }
                            //  }
                        }
                    }
                }
                .surfaceContentRowInsets()
                if isPendingNotification {
                    SectionView {
                        VStack(spacing: .zero) {
                            Row("Delete notification") {
                                viewModel.deleteNotification()
                                saveAction?(nil)
                                isPendingNotification = false
                                dismiss()
                            } trailing: {
                                IconDeprecated(.trash)
                                    .iconColor(Color.error)
                            }
                        }
                    }
                    .surfaceContentRowInsets()
                }
            }
        }
        .backgroundSecondary()
        .leadingBar {
            BarButton(.close)
        }
        .trailingBar {
            BarButton(.accent("Done", action: {
                Task {
                    await viewModel.setNotification(timeBefore: selection)
                    saveAction?(viewModel.id)
                    isPendingNotification = true
                    dismiss()
                }
            }))
        }
    }
}
