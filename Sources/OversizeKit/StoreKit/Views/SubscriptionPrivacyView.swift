//
// Copyright © 2022 Alexander Romanov
// SubscriptionPrivacyView.swift
//

import OversizeComponents
import OversizeServices
import OversizeStoreService
import OversizeUI
import StoreKit
import SwiftUI

struct SubscriptionPrivacyView: View {
    let products: StoreKitProducts
    @Environment(\.platform) private var platform

    @State var isShowPrivacy = false
    @State var isShowTerms = false

    var body: some View {
        Surface {
            VStack(spacing: .xxSmall) {
                Text("About \(Info.store.subscriptionsName) subscription")
                    .subheadline(.bold)
                    .foregroundColor(Color.onSurfaceTertiary)

                Text("\(Info.store.subscriptionsName) subscription is required to get access to all functions. Regardless whether the subscription has free trial period or not it automatically renews with the price and duration given above unless it is canceled at least 24 hours before the end of the current period. Payment will be charged to your Apple ID account at the confirmation of purchase. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.")
                    .caption()
                    .foregroundColor(Color.onSurfaceSecondary)

                #if os(iOS) || os(macOS)
                HStack(spacing: .xxSmall) {
                    Button("Restore") {
                        Task {
                            try? await AppStore.sync()
                        }
                    }
                    #if os(macOS)
                    .buttonStyle(.plain)
                    #endif

                    Text("•")

                    if let privacyUrl = Info.url.appPrivacyPolicyUrl {
                        Button {
                            isShowPrivacy.toggle()
                        } label: {
                            Text("Privacy")
                        }
                        .sheet(isPresented: $isShowPrivacy) {
                            #if os(macOS)
                            VStack {
                                WebView(url: privacyUrl)
                                    .frame(width: 500, height: 600)
                            }
                            .frame(width: 500, height: 600, alignment: .center)
                            #else
                            WebView(url: privacyUrl)

                            #endif
                        }
                        #if os(macOS)
                        .buttonStyle(.plain)
                        #endif
                    }

                    Text("•")

                    if let termsOfUde = Info.url.appTermsOfUseUrl {
                        Button {
                            isShowTerms.toggle()
                        } label: {
                            Text("Terms")
                        }
                        .sheet(isPresented: $isShowTerms) {
                            #if os(macOS)
                            VStack {
                                WebView(url: termsOfUde)
                                    .frame(width: 500, height: 600)
                            }
                            .frame(width: 500, height: 600, alignment: .center)
                            #else
                            WebView(url: termsOfUde)

                            #endif
                        }
                        #if os(macOS)
                        .buttonStyle(.plain)
                        #endif
                    }
                }
                .subheadline(.bold)
                .foregroundColor(Color.onSurfaceTertiary)
                .padding(.top, .xxxSmall)
                #endif
            }
            .multilineTextAlignment(.center)
        }
        .surfaceBorderColor(Color.surfaceSecondary)
        .surfaceBorderWidth(platform == .macOS ? 1 : 2)
    }
}

// struct SubscriptionPrivacyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionPrivacyView()
//    }
// }
