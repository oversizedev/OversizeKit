//
// Copyright © 2022 Alexander Romanov
// NoticeListView.swift
//

import OversizeServices
import OversizeStoreService
import OversizeUI
import StoreKit
import SwiftUI

public struct NoticeListView: View {
    @Injected(\.appStoreReviewService) var reviewService

    @State private var isBannerClosed = false
    @State private var showRecommended = false

    private var isShowRate: Bool {
        !isBannerClosed && reviewService.isShowReviewBanner
    }

    public init() {}

    public var body: some View {
        if isShowRate {
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

                //            NoticeView("Dress Weather") {
                //                Button {
                //                    showRecommended.toggle()
                //                } label: {
                //                    Text("Show")
                //                }
                //                .accent()
                //            }
                //            .appStoreOverlay(isPresented: $showRecommended) {
                //                SKOverlay.AppConfiguration(appIdentifier: "1552617598", position: .bottomRaised)
                //            }
            }
        }
    }
}

// struct NoticeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoticeListView()
//    }
// }
