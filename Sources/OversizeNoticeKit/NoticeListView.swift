//
// Copyright © 2022 Alexander Romanov
// NoticeListView.swift
//

import OversizeServices
import OversizeStoreKit
import OversizeStoreService
import OversizeUI
import StoreKit
import SwiftUI

public struct NoticeListView: View {
    @Injected(Container.appStoreReviewService) var reviewService
    @Environment(\.isPremium) var isPremium: Bool

    @State private var isBannerClosed = false
    @State private var showRecommended = false

    private var specialOffer: StoreSpecialOfferEventType? {
        var specialOffer: StoreSpecialOfferEventType?
        for event in StoreSpecialOfferEventType.allCases where event.isNow {
            if lastClosedSpecialOffer != event {
                specialOffer = event
            }
        }
        return specialOffer
    }

    @State private var isShowOfferSheet: Bool = false
    @AppStorage("AppState.LastClosedSpecialOfferBanner") var lastClosedSpecialOffer: StoreSpecialOfferEventType = .oldUser

    private var isShowRate: Bool {
        !isBannerClosed && reviewService.isShowReviewBanner
    }

    private var isShowNoticeView: Bool {
        isShowRate && (specialOffer != nil && isPremium == false)
    }

    public init() {}

    public var body: some View {
        if isShowNoticeView {
            VStack(spacing: .small) {
                if isShowRate, let reviewUrl = AppInfo.url.appStoreReview {
                    NoticeView("How do you like the application?") {
                        Link(destination: reviewUrl) {
                            Text("Good")
                        }
                        .buttonStyle(.primary(infinityWidth: true))
                        .accent()
                        .simultaneousGesture(TapGesture().onEnded {
                            reviewService.estimate(goodRating: true)
                            isBannerClosed = true
                        })

                        Button("Bad") {
                            reviewService.estimate(goodRating: false)
                            isBannerClosed = true
                        }
                        .buttonStyle(.tertiary(infinityWidth: true))

                    } closeAction: {
                        reviewService.rewiewBunnerClosed()
                        isBannerClosed = true
                    }
                    .animation(.default, value: isBannerClosed)
                }

                if let event = specialOffer {
                    let url = URL(string: "https://cdn.oversize.design/assets/illustrations/\(event.specialOfferImageURL)")

                    NoticeView(event.specialOfferBannerTitle,
                               subtitle: event.specialOfferDescription,
                               imageURL: url) {
                        Button {
                            isShowOfferSheet.toggle()
                        } label: {
                            Text("Get Free Trial")
                        }
                        .accent()

                    } closeAction: {
                        lastClosedSpecialOffer = event
                    }
                    .sheet(isPresented: $isShowOfferSheet) {
                        StoreSpecialOfferView(event: event)
                            .systemServices()
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

// struct NoticeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoticeListView()
//    }
// }
