//
// Copyright © 2023 Alexander Romanov
// NoticeListViewModel.swift, created on 25.12.2023
//

import FactoryKit
import Foundation
import OversizeCore
import OversizeNetwork
import OversizeServices
import OversizeStoreService
import StoreKit
import SwiftUI

@MainActor
public final class NoticeListViewModel: ObservableObject {
    @Injected(\.appStoreReviewService) var reviewService
    @Injected(\.networkService) var networkService
    @Injected(\.storeKitService) var storeKitService: StoreKitService
    @Injected(\.appStateService) var appStateService: AppStateService

    @AppStorage("AppState.LastClosedSpecialOfferBanner") var lastClosedSpecialOffer: Int = .init()

    @Published var noticeType: NoticeType?
    @Published var isBannerClosed = false

    public var trialDaysPeriodText: String = ""
    public var subscriptionName: String = ""
    public var salePercent: Decimal = 0
    private var hasFirstDayOffer = false

    public init() {
        Task {
            await fetchData()
        }
    }

    public func fetchData() async {
        await fetchStoreKitProudcts()
        await fetchAndSetSpecialOffer()
    }

    private func fetchStoreKitProudcts() async {
        guard let appStoreID = Info.App.appStoreId else {
            return
        }
        let inAppPurchases = await networkService.fetchInAppPurchases(appId: appStoreID)

        let result = await storeKitService.requestProducts(productIds: inAppPurchases.successResult?.productIds ?? [])
        switch result {
        case let .success(products):
            if let product = products.autoRenewable.first(where: { $0.isOffer }), let offer = product.subscription?.introductoryOffer {
                trialDaysPeriodText = storeKitService.daysLabel(offer.period.value, unit: offer.period.unit)
                salePercent = storeKitService.salePercent(product: product, products: products)
                subscriptionName = inAppPurchases.successResult?.banner.badge ?? ""
                hasFirstDayOffer = true
            }
        case .failure:
            break
        }
    }

    private func fetchAndSetSpecialOffer() async {
        let result = await networkService.fetchSpecialOffers()
        switch result {
        case let .success(offers):
            let isShowReviewBanner = await reviewService.isShowReviewBanner
            let isFirstDayAfterRun = Date().hours(from: appStateService.firstRunDate) < 24
            if isFirstDayAfterRun, hasFirstDayOffer {
                noticeType = .firstDay
            } else if let offer = offers.first(where: { $0.id != lastClosedSpecialOffer && checkDateInSelectedPeriod(startDate: $0.startDate, endDate: $0.endDate) }) {
                noticeType = .offer(offer)
            } else if isShowReviewBanner {
                noticeType = .rate
            }
        case .failure:
            break
        }
    }

    private func checkDateInSelectedPeriod(startDate: Date, endDate: Date) -> Bool {
        if startDate < endDate {
            (startDate ... endDate).contains(Date())
        } else {
            false
        }
    }

    func textPrepere(_ text: String) -> String {
        text
            .replacingOccurrences(of: "<salePercent>", with: salePercent.toString)
            .replacingOccurrences(of: "<freeDays>", with: trialDaysPeriodText)
            .replacingOccurrences(of: "<subscriptionName>", with: subscriptionName)
    }
}

extension NoticeListViewModel {
    enum NoticeType {
        case offer(Components.Schemas.InAppPurchaseOffer)
        case rate
        case firstDay
    }
}
