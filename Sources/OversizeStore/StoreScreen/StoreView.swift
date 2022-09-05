//
// Copyright © 2022 Alexander Romanov
// StoreView.swift
//

import OversizeComponents
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct StoreView: View {
    @StateObject var viewModel: StoreViewModel
    @Environment(\.presentationMode) var presentationMode

    public init() {
        _viewModel = StateObject(wrappedValue: StoreViewModel())
    }

    public var body: some View {
        switch viewModel.state {
        case .initial:
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                        .task {
                            await viewModel.fetchData()
                            if case let .result(products) = self.viewModel.state {
                                await viewModel.updateState(products: products)
                            }
                        }
                    Spacer()
                }
                Spacer()
            }
        case .loading:
            ProgressView()
        case let .result(data):
            content(data: data)
        case let .error(error):
            ErrorView(error)
        }
    }

    @ViewBuilder
    private func content(data: StoreKitProducts) -> some View {
        PageView("") {
            VStack(spacing: .medium) {
                VStack(spacing: .xxSmall) {
                    Text("Upgrade to \(AppInfo.store.subscriptionsName)")
                        .title()
                        .foregroundColor(.onSurfaceHighEmphasis)

                    Text("Remove ads and unlock all features")
                        .headline()
                        .foregroundColor(.onSurfaceMediumEmphasis)
                }

                HStack(spacing: .xSmall) {
                    ForEach(viewModel.availableSubscriptions /* data.autoRenewable */ ) { product in
                        StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                            viewModel.selectedProduct = product
                        }
                        .storeProductStyle(.collumn)
                    }
                    ForEach(data.nonConsumable) { product in
                        StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                            viewModel.selectedProduct = product
                        }
                        .storeProductStyle(.collumn)
                    }
                }

                StoreFeaturesView()
                    .environmentObject(viewModel)

                SubscriptionPrivacyView(products: data)

                productsLust(data: data)
                    .padding(.bottom, 170)
            }
            .paddingContent(.horizontal)
        }
        .backgroundLinerGradient(LinearGradient(colors: [.backgroundPrimary, .backgroundSecondary], startPoint: .top, endPoint: .center))
        .titleLabel {
            PremiumLabel(image: Resource.Store.zap, text: AppInfo.store.subscriptionsName, size: .medium)
        }
        .trailingBar {
            BarButton(type: .close)
        }
        .bottomToolbar(style: .none, ignoreSafeArea: false) {
            StorePaymentButtonBar()
                .environmentObject(viewModel)
        }
        .onAppear {
            Task {
                // When this view appears, get the latest subscription status.
                await viewModel.updateSubscriptionStatus(products: data)
            }
        }
        .onChange(of: data.purchasedAutoRenewable) { _ in
            Task {
                // When `purchasedSubscriptions` changes, get the latest subscription status.
                await viewModel.updateSubscriptionStatus(products: data)
            }
        }
    }

    @ViewBuilder
    private func productsLust(data: StoreKitProducts) -> some View {
        VStack(spacing: .small) {
            VStack {
                if let currentSubscription = viewModel.currentSubscription {
                    VStack {
                        Text("My Subscription")

                        StoreProductView(product: currentSubscription, products: data) {}

                        if let status = viewModel.status {
                            StatusInfoView(product: currentSubscription, status: status, products: data)
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
            }

            ForEach(viewModel.availableSubscriptions /* data.autoRenewable */ ) { product in
                StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                    viewModel.selectedProduct = product
//                    Task {
//                       await viewModel.buy(product: product)
//                    }
                }
            }
            ForEach(data.nonConsumable) { product in
                StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                    viewModel.selectedProduct = product
//                    Task {
//                        await viewModel.buy(product: product)
//                    }
                }
            }
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
