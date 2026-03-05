//
// Copyright © 2022 Alexander Romanov
// DebugInfoViewModel.swift
//

import OversizeCore
import OversizeNetwork
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif
import FactoryKit

@MainActor
public final class DebugInfoViewModel: ObservableObject {
    @Injected(\.appStateService) var appStateService: AppStateService
    @Injected(\.settingsService) var settingsService: SettingsServiceProtocol
    @Injected(\.appStoreReviewService) var reviewService: AppStoreReviewService

    @Published var eventCount: Int = 0
    @Published var reviewBannerClosedDate: Date = .init()
    @Published var reviewEstimateDate: Date = .init()
    @Published var launchReviewCount: [Int] = []
    @Published var eventReviewCount: [Int] = []

    public init() {}

    func loadReviewData() async {
        eventCount = await reviewService.appStoreReviewReceivedActionsCount
        reviewBannerClosedDate = await reviewService.appReviewBannerClosedDate
        reviewEstimateDate = await reviewService.appReviewEstimateDate
        launchReviewCount = await reviewService.launchReviewCount
        eventReviewCount = await reviewService.rewiewAfterEventCount
    }

    var nextEventReviewCount: Int {
        eventReviewCount.first { $0 > eventCount } ?? eventReviewCount.last ?? 0
    }

    var nextLaunchReviewCount: Int {
        let currentCount = appStateService.appRunCount
        return launchReviewCount.first { $0 > currentCount } ?? launchReviewCount.last ?? 0
    }

    func onTapAddEvent() {
        Task {
            await reviewService.actionEvent()
        }
    }
}
