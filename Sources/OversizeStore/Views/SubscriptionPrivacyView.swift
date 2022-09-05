//
// Copyright © 2022 Alexander Romanov
// SubscriptionPrivacyView.swift
//

import OversizeServices
import OversizeSettingsService
import OversizeStoreService
import OversizeUI
import StoreKit
import SwiftUI

struct SubscriptionPrivacyView: View {
    let products: StoreKitProducts

    var body: some View {
        Surface {
            VStack(spacing: .xxSmall) {
                Text("About \(AppInfo.store.subscriptionsName) subscription")
                    .subheadline(.bold)
                    .foregroundColor(Color.onSurfaceDisabled)

                Text("\(AppInfo.store.subscriptionsName) subscription is required to get access to all functions. Regardless whether the subscription has free trial period or not it automatically renews with the price and duration given above unless it is canceled at least 24 hours before the end of the current period. Payment will be charged to your Apple ID account at the confirmation of purchase. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.")
                    .caption()
                    .foregroundColor(Color.onSurfaceMediumEmphasis)

                HStack(spacing: .xxSmall) {
                    Button("Restore") {
                        Task {
                            // This call displays a system prompt that asks users to authenticate with their App Store credentials.
                            // Call this function only in response to an explicit user action, such as tapping a button.
                            try? await AppStore.sync()
                        }
                    }

                    Text("•")

                    if let privacyUrl = AppInfo.url.appPrivacyPolicyUrl {
                        Link(destination: privacyUrl) {
                            Text("Privacy")
                        }
                    }

                    Text("•")

                    if let termsOfUde = AppInfo.url.appTermsOfUseUrl {
                        Link(destination: termsOfUde) {
                            Text("Terms")
                        }
                    }
                }
                .subheadline(.bold)
                .foregroundColor(Color.onSurfaceDisabled)
                .padding(.top, .xxxSmall)
            }
            .multilineTextAlignment(.center)
        }
        .surfaceBorderColor(Color.surfaceSecondary, width: 2)
    }
}

// struct SubscriptionPrivacyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionPrivacyView()
//    }
// }
