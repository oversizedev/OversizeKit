//
// Copyright © 2023 Alexander Romanov
// NoticeListView.swift
//

import FactoryKit
import NavigatorUI
import OversizeKit
import OversizeNetwork
import OversizeServices
import OversizeUI
import StoreKit
import SwiftUI

public struct NoticeListView: View {
    @Environment(\.navigator) var navigator
    @Environment(\.isPremium) var isPremium: Bool
    @StateObject private var viewModel = NoticeListViewModel()

    public init() {}

    public var body: some View {
        if viewModel.isBannerClosed == false {
            switch viewModel.noticeType {
            case let .offer(inAppPurchaseOffer):
                if !isPremium {
                    offerView(offer: inAppPurchaseOffer)
                }
            case .rate:
                rateNoticeView
            case .firstDay:
                if !isPremium {
                    firstDayOfferView
                }
            case .none:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var rateNoticeView: some View {
        if let reviewUrl = Info.App.appStoreReviewUrl {
            NoticeView("How do you like the \(Info.App.name ?? "app"))?") {
                Link(destination: reviewUrl) {
                    Text("Good")
                }
                .buttonStyle(.primary(infinityWidth: true))
                .accent()
                .simultaneousGesture(TapGesture().onEnded {
                    Task {
                        await viewModel.reviewService.estimate(goodRating: true)
                        withAnimation {
                            viewModel.isBannerClosed = true
                        }
                    }
                })

                Button("Bad") {
                    Task {
                        await viewModel.reviewService.estimate(goodRating: false)
                        withAnimation {
                            viewModel.isBannerClosed = true
                        }
                    }
                }
                .buttonStyle(.tertiary(infinityWidth: true))

            } closeAction: {
                Task {
                    await viewModel.reviewService.reviewBannerClosed()
                    withAnimation {
                        viewModel.isBannerClosed = true
                    }
                }
            }
            .animation(.default, value: viewModel.isBannerClosed)
        }
    }

    @ViewBuilder
    private var firstDayOfferView: some View {
        NoticeView(
            "Get \(viewModel.salePercent)% Off",
            subtitle: "On your first year of \(viewModel.subscriptionName)"
        ) {
            Button {
                navigator.navigate(
                    to: SettingsDestinations.premiumInstructions(
                        specialOfferMode: true
                    ),
                    method: .managedSheet
                )
            } label: {
                Text("Claim Offer")
            }
            .accent()
        } closeAction: {
            withAnimation {
                viewModel.isBannerClosed = true
            }
        }
    }

    @ViewBuilder
    private func offerView(offer: Components.Schemas.InAppPurchaseOffer) -> some View {
        NoticeView(
            viewModel.textPrepere(offer.title),
            subtitle: viewModel.textPrepere(offer.description ?? ""),
            imageURL: offer.imageUrl?.url
        ) {
            Button {
                navigator.navigate(
                    to: SettingsDestinations.offer(event: offer),
                    method: .managedSheet
                )
            } label: {
                Text("Accept Offer")
            }
            .accent()

        } closeAction: {
            viewModel.lastClosedSpecialOffer = offer.id
            withAnimation {
                viewModel.isBannerClosed = true
            }
        }
    }
}

// struct NoticeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoticeListView()
//    }
// }
