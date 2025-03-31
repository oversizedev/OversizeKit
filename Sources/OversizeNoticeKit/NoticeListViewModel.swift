//
// Copyright © 2023 Alexander Romanov
// NoticeListViewModel.swift, created on 25.12.2023
//

import Factory
import OversizeModels
import OversizeNetwork
import OversizeServices
import OversizeStoreService
import StoreKit
import SwiftUI

@MainActor
public final class NoticeListViewModel: ObservableObject {
    enum State {
        case initial
        case loading
        case result(offer: Components.Schemas.SaleOffer?, isShowRate: Bool)
        case empty
        case error(AppError)
    }

    @Injected(\.appStoreReviewService) var reviewService
    @Injected(\.networkService) var networkService
    @Injected(\.storeKitService) var storeKitService: StoreKitService

    var isShowReviewBanner: Bool {
        reviewService.isShowReviewBanner
    }

    @AppStorage("AppState.LastClosedSpecialOfferBanner") var lastClosedSpecialOffer: Int = .init()

    private let expectedFormat = Date.ISO8601FormatStyle()

    @Published var state = State.initial
    @Published public var trialDaysPeriodText: String = ""
    @Published public var salePercent: Decimal = 0

    public init() {
        Task {
            await fetchData()
        }
    }

    public func fetchData() async {
        state = .loading
        await fetchStoreKitProudcts()
        await fetchAndSetSpecialOffer()
    }

    public func fetchStoreKitProudcts() async {
        guard let appStoreID = Info.app.appStoreID else {
            return
        }
        let productIds = await networkService.fetchAppStoreProductIds(appId: appStoreID).successResult ?? []

        let result = await storeKitService.requestProducts(productIds: productIds)
        switch result {
        case let .success(products):
            if let product = products.autoRenewable.first(where: { $0.isOffer }), let offer = product.subscription?.introductoryOffer {
                trialDaysPeriodText = storeKitService.daysLabel(offer.period.value, unit: offer.period.unit)
                salePercent = storeKitService.salePercent(product: product, products: products)
            }
        case .failure:
            break
        }
    }

    public func fetchAndSetSpecialOffer() async {
        let result = await networkService.fetchSpecialOffers()
        switch result {
        case let .success(offers):
            if let offer = offers.first(where: { checkDateInSelectedPeriod(startDate: $0.startDate, endDate: $0.endDate) }) {
                if offer.id != lastClosedSpecialOffer {
                    withAnimation {
                        state = .result(
                            offer: offer,
                            isShowRate: isShowReviewBanner
                        )
                    }
                } else if isShowReviewBanner {
                    withAnimation {
                        state = .result(
                            offer: nil,
                            isShowRate: isShowReviewBanner
                        )
                    }
                } else {
                    state = .empty
                }
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
            .replacingOccurrences(of: "<subscriptionName>", with: Info.store.subscriptionsName)
    }
}
