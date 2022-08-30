//
// Copyright © 2022 Alexander Romanov
// StoreView.swift
//

import OversizeLocalizable
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
                HStack {
                    ProgressView()
                        .task {
                            await viewModel.fetchData()
                            if case let .result(products) = self.viewModel.state {
                                await viewModel.updateState(products: products)
                            }
                        }
                }
            }
        case .loading:
            ProgressView()
        case let .result(data):
            content(data: data)
        case let .error(error):
            Text("Error")
            // ErrorView(error)
        }
    }

    @ViewBuilder
    private func content(data: StoreKitProducts) -> some View {
        PageView("") {
            VStack(spacing: .xxSmall) {
                Text("Upgrade to Pro")
                    .title()
                    .foregroundColor(.onSurfaceHighEmphasis)

                Text("Remove ads and unlock all features")
                    .headline()
                    .foregroundColor(.onSurfaceMediumEmphasis)
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

                SubscriptionPrivacyView(products: data)
                productsLust(data: data)
                    .padding(.top, .medium)
            }
            .paddingContent(.horizontal)
        }
        .trailingBar {
            BarButton(type: .close)
        }
        .bottomToolbar(style: .none, ignoreSafeArea: false) {
            VStack {
                Text(viewModel.selectedProductButtonDescription)
                    .subheadline(.semibold)
                    .foregroundColor(.onSurfaceMediumEmphasis)
                    .padding(.vertical, .small)

                Button {
                    if let selectedProduct = viewModel.selectedProduct {
                        Task {
                            await viewModel.buy(product: selectedProduct)
                        }
                    }
                } label: {
                    Text(viewModel.selectedProductButtonText)
                }
                .buttonStyle(.payment)
                .controlRadius(.medium)
                .padding(.horizontal, .xxSmall)
                .padding(.bottom, .xxSmall)
            }
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.05), lineWidth: 0.5)
                    }
            }
            .padding(.small)
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
