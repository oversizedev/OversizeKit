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
                    ErrorView(error)
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
                    text: Info.store.subscriptionsName,
                    size: .medium
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.isPremium {
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
    }

    var titleText: String {
        if viewModel.isPremium {
            "You are all set!"
        } else {
            "Upgrade to \(viewModel.productsState.result?.banner.badge ?? "")"
        }
    }

    var subtitleText: String {
        if viewModel.isPremium {
            "Thank you for use to \(viewModel.productsState.result?.banner.badge ?? "").\nHere's what is now unlocked."
        } else {
            "Remove ads and unlock all features"
        }
    }

    @ViewBuilder
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

    @ViewBuilder
    private func content(data: StoreKitProducts) -> some View {
        LazyVStack(spacing: .medium) {
            titleView

            #if DEBUG
            if let currentSubscription = viewModel.currentSubscription {
                LeadingVStack(spacing: .small) {
                    Text("My Subscription")
                        .headline()
                        .onSurfacePrimaryForeground()

                    StoreProductView(product: currentSubscription, products: data) {}

                    if let status = viewModel.status {
                        Text("Status: \(status.state.localizedDescription)")
                            .caption()
                            .onSurfacePrimaryForeground()
                    }
                }
            } else {
                Surface {
                    Text("No subscription")
                        .onSurfacePrimaryForeground()
                        .body()
                        .frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )
                }
            }
            #endif

            if !viewModel.isPremium {
                productsCollum(data: data)
            }

            StoreFeaturesView()
                .environmentObject(viewModel)

            SubscriptionPrivacyView(
                subscriptionsName: viewModel.productsState.result?.banner.badge ?? "",
                products: data
            )

            if !viewModel.isPremium {
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

    @ViewBuilder
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

    @ViewBuilder
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
        let control = self
        return control
    }
}
#endif
