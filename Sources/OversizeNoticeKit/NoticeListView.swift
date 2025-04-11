//
// Copyright © 2023 Alexander Romanov
// NoticeListView.swift
//

import OversizeKit
import OversizeNetwork
import OversizeServices
import OversizeUI
import StoreKit
import SwiftUI

public struct NoticeListView: View {
    @Environment(\.isPremium) var isPremium: Bool
    @StateObject private var viewModel = NoticeListViewModel()

    @State private var isBannerClosed = false
    @State private var isShowOfferSheet: Bool = false

    public init() {}

    public var body: some View {
        switch viewModel.state {
        case let .result(offer: offer, isShowRate: isShowRate) where (offer != nil || isShowRate) && !isBannerClosed && !isPremium:
            VStack(spacing: .small) {
                if isShowRate {
                    rateNoticeView
                }
                if let offer {
                    offerView(offer: offer)
                }
            }
        case .initial, .loading, .error, .result, .empty:
            EmptyView()
        }
    }

    @ViewBuilder
    private var rateNoticeView: some View {
        if let reviewUrl = Info.url.appStoreReview {
            NoticeView("How do you like the \(Info.app.name ?? "app"))?") {
                Link(destination: reviewUrl) {
                    Text("Good")
                }
                .buttonStyle(.primary(infinityWidth: true))
                .accent()
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.reviewService.estimate(goodRating: true)
                    withAnimation {
                        isBannerClosed = true
                    }
                })

                Button("Bad") {
                    viewModel.reviewService.estimate(goodRating: false)
                    withAnimation {
                        isBannerClosed = true
                    }
                }
                .buttonStyle(.tertiary(infinityWidth: true))

            } closeAction: {
                viewModel.reviewService.rewiewBunnerClosed()
                withAnimation {
                    isBannerClosed = true
                }
            }
            .animation(.default, value: isBannerClosed)
        }
    }

    @ViewBuilder
    private func offerView(offer: Components.Schemas.InAppPurchaseOffer) -> some View {
        if let imageUrl = offer.imageURL, let url = URL(string: imageUrl) {
            NoticeView(
                viewModel.textPrepere(offer.title),
                subtitle: viewModel.textPrepere(offer.description ?? ""),
                imageURL: url
            ) {
                Button {
                    isShowOfferSheet.toggle()
                } label: {
                    Text("Accept Offer")
                }
                .accent()

            } closeAction: {
                viewModel.lastClosedSpecialOffer = offer.id
                withAnimation {
                    isBannerClosed = true
                }
            }
            .sheet(isPresented: $isShowOfferSheet) {
                StoreSpecialOfferView(event: offer)
                    .systemServices()
            }
        }
    }
}

// struct NoticeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoticeListView()
//    }
// }
