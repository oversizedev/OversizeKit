//
// Copyright © 2023 Alexander Romanov
// StoreView.swift
//

import OversizeComponents
import OversizeCore
import OversizeLocalizable
import OversizeNavigation
import OversizeResources
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

#if os(iOS) || os(macOS)
public struct StoreView: View {
    @StateObject private var viewModel: StoreViewModel
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.platform) private var platform
    @Environment(\.isPortrait) private var isPortrait
    private var isClosable = true
    @State var isShowFireworks = false
    @State var isPresentedManageSubscription = false

    public init() {
        _viewModel = StateObject(wrappedValue: StoreViewModel())
    }

    public var body: some View {
        NavigationLayoutView {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    contentPlaceholder()
                case let .result(data):
                    content(data: data)
                case let .error(error):
                    ErrorView(error: error)
                }
            }
            .paddingContent(.horizontal)
        } background: {
            LinearGradient(
                colors: [
                    .backgroundPrimary,
                    .backgroundSecondary,
                ],
                startPoint: .top,
                endPoint: .center
            )
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                PremiumLabel(
                    image: Resource.Store.zap,
                    text: viewModel.productsState.result?.banner.badge ?? "",
                    size: .medium
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.isPremium || isCancelledSubscription {
                StorePaymentButtonBar()
                    .environmentObject(viewModel)
            }
        }
        .overlay {
            if isShowFireworks {
                Fireworks()
            }
        }
        .task {
            await viewModel.fetchData()
        }
        .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
        .onChange(of: isPresentedManageSubscription) { _, isPresented in
            if isPresented == false {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
    }

    var isCancelledSubscription: Bool {
        guard let statusInfo = viewModel.status,
              case let .verified(renewalInfo) = statusInfo.renewalInfo
        else { return false }
        return !renewalInfo.willAutoRenew && viewModel.isPremium
    }

    var titleText: String {
        if isCancelledSubscription {
            "Subscription Cancelling"
        } else if viewModel.isPremium {
            "You are all set!"
        } else {
            "Upgrade to \(viewModel.productsState.result?.banner.badge ?? "")"
        }
    }

    var subtitleText: String {
        if isCancelledSubscription {
            "Your subscription \(viewModel.subscriptionStatusText.lowercased()). Resubscribe to keep your benefits."
        } else if viewModel.isPremium {
            "Thank you for use to \(viewModel.productsState.result?.banner.badge ?? "").\nHere's what is now unlocked."
        } else {
            "Remove ads and unlock all features"
        }
    }

    private func contentPlaceholder() -> some View {
        VStack(spacing: .medium) {
            VStack(spacing: .xxSmall) {
                Text(titleText)
                    .title()
                    .foregroundColor(.onSurfacePrimary)

                Text(subtitleText)
                    .headline()
                    .foregroundColor(.onSurfaceSecondary)
            }
            .multilineTextAlignment(.center)

            HStack(spacing: .xSmall) {
                ForEach(0 ..< 3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: .small)
                        .fillSurfaceSecondary()
                        .frame(height: 180)
                }
            }

            StoreFeaturesView()
                .environmentObject(viewModel)
        }
    }

    private func content(data: StoreKitProducts) -> some View {
        LazyVStack(spacing: .medium) {
            titleView

            if !viewModel.isPremium || isCancelledSubscription {
                productsCollum(data: data)
            }

            StoreFeaturesView()
                .environmentObject(viewModel)

            if viewModel.isPremium {
                Surface {
                    isPresentedManageSubscription = true

                } label: {
                    Text("Manage Subscription")
                        .body(.semibold)
                        .onSurfaceSecondary()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .surfaceBorderColor(Color.surfaceSecondary)
                .surfaceBorderWidth(platform == .macOS ? 1 : 2)
            }

            SubscriptionPrivacyView(
                subscriptionsName: viewModel.productsState.result?.banner.badge ?? "",
                products: data
            )

            #if DEBUG
            if let currentSubscription = viewModel.currentSubscription {
                LeadingVStack(spacing: .small) {
                    Text("My Subscription")
                        .headline()
                        .onSurfacePrimary()

                    StoreProductView(product: currentSubscription, products: data) {}

                    if let status = viewModel.status {
                        Text("Status: \(status.state.localizedDescription)")
                            .caption()
                            .onSurfacePrimary()
                    }
                }
            } else {
                Surface {
                    Text("No subscription")
                        .body(.semibold)
                        .onSurfaceSecondary()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .surfaceBorderColor(Color.surfaceSecondary)
                .surfaceBorderWidth(platform == .macOS ? 1 : 2)
            }
            #endif

            if !viewModel.isPremium || isCancelledSubscription {
                productsList(data: data)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 12)
        .onAppear {
            Task {
                // When this view appears, get the latest subscription status.
                await viewModel.updateSubscriptionStatus(products: data)
            }
        }
        .onChange(of: data.purchasedAutoRenewable) { _, _ in
            Task {
                // When `purchasedSubscriptions` changes, get the latest subscription status.
                await viewModel.updateSubscriptionStatus(products: data)
            }
        }
        .onChange(of: viewModel.isPremium) { _, status in
            isShowFireworks = status
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                isShowFireworks = false
            }
        }
    }

    private var titleView: some View {
        VStack(spacing: .xxSmall) {
            Text(titleText)
                .title()
                .foregroundColor(.onSurfacePrimary)

            Text(subtitleText)
                .headline()
                .foregroundColor(.onSurfaceSecondary)
        }
        .multilineTextAlignment(.center)
    }

    private func productsCollum(data: StoreKitProducts) -> some View {
        HStack(spacing: .xSmall) {
            ForEach(viewModel.availableSubscriptions /* data.autoRenewable */ ) { product in
                if !product.isOffer {
                    StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                        viewModel.selectedProduct = product
                    }
                    .storeProductStyle(.column)
                }
            }
            ForEach(data.nonConsumable) { product in
                StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                    viewModel.selectedProduct = product
                }
                .storeProductStyle(.column)
            }
        }
    }

    private func productsList(data: StoreKitProducts) -> some View {
        VStack(spacing: .small) {
            ForEach(viewModel.availableSubscriptions /* data.autoRenewable */ ) { product in
                if !product.isOffer {
                    StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                        viewModel.selectedProduct = product
                    }
                }
            }
            ForEach(data.nonConsumable) { product in
                StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                    viewModel.selectedProduct = product
                }
            }
        }
    }

    public func closable(_ isClosable: Bool = true) -> StoreView {
        var control = self
        control.isClosable = isClosable
        return control
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
#else
public struct StoreView: View {
    public init() {}

    public var body: some View {
        Text("Store")
    }

    public func closable(_: Bool = true) -> StoreView {
        self
    }
}
#endif
