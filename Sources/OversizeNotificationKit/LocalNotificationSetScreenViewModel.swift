//
// Copyright © 2023 Alexander Romanov
// LocalNotificationSetScreenViewModel.swift
//

import OversizeCore
import OversizeNotificationService
import OversizeServices
import SwiftUI

@MainActor
class LocalNotificationSetScreenViewModel: ObservableObject {
    @Injected(Container.localNotificationService) var localNotificationService: LocalNotificationServiceProtocol
    @Published var state = State.initial

    public let id: UUID
    private let date: Date
    private let title: String
    private let body: String
    private let userInfo: [AnyHashable: Any]?

    init(
        id: UUID,
        date: Date,
        title: String,
        body: String,
        userInfo: [AnyHashable: Any]? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.body = body
        self.userInfo = userInfo
    }

    func setNotification(timeBefore: LocalNotificationTime) async {
        let notificationTime = date.addingTimeInterval(timeBefore.timeInterval)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
        await localNotificationService.schedule(localNotification: .init(
            id: id,
            title: title,
            body: body,
            dateComponents: dateComponents,
            repeats: false,
            userInfo: userInfo
        ))
    }

    func fetchPandingNotification() async -> Bool {
        let ids = await localNotificationService.fetchPendingIds()
        return ids.contains(id.uuidString)
    }

    func deleteNotification() {
        localNotificationService.removeRequest(withIdentifier: id.uuidString)
    }

    func requestAccsess() async {
        let result = await localNotificationService.requestAccess()
        switch result {
        case .success:
            state = .result
        case let .failure(error):
            state = .error(error)
        }
    }
}

extension LocalNotificationSetScreenViewModel {
    enum State {
        case initial
        case result
        case error(AppError)
    }
}
