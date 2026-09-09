//
// Copyright © 2023 Alexander Romanov
// NoticeListView.swift
//

import FactoryKit
import OversizeKit
import OversizeNetwork
import OversizeServices
import OversizeUI
import StoreKit
import SwiftUI

public struct NoticeListView: View {
    @Environment(\.isPremium) var isPremium: Bool
    @StateObject private var viewModel = NoticeListViewModel()
    @State private var sheet: Sheet?

    public init() {}

    public var body: some View {
        Group {
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
        .sheet(item: $sheet) { sheet in
            sheetView(sheet)
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

    private var firstDayOfferView: some View {
        NoticeView(
            "Get \(viewModel.salePercent)% Off",
            subtitle: "On your first year of \(viewModel.subscriptionName)"
        ) {
            Button {
                sheet = .premiumInstructions(specialOfferMode: true)
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

    private func offerView(offer: Components.Schemas.InAppPurchaseOffer) -> some View {
        NoticeView(
            viewModel.textPrepere(offer.title),
            subtitle: viewModel.textPrepere(offer.description ?? ""),
            imageURL: offer.imageUrl?.url
        ) {
            Button {
                sheet = .offer(offer)
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

    @ViewBuilder
    private func sheetView(_ sheet: Sheet) -> some View {
        switch sheet {
        case let .offer(offer):
            NavigationStack {
                StoreSpecialOfferView(event: offer)
                    .coreServices()
            }
        case let .premiumInstructions(specialOfferMode):
            NavigationStack {
                StoreInstructionsView(specialOfferMode: specialOfferMode)
                    .coreServices()
            }
        }
    }
}

extension NoticeListView {
    enum Sheet: Identifiable {
        case offer(Components.Schemas.InAppPurchaseOffer)
        case premiumInstructions(specialOfferMode: Bool)

        var id: Int {
            switch self {
            case let .offer(offer): offer.id
            case .premiumInstructions: -1
            }
        }
    }
}

#Preview {
    NoticeListView()
}
