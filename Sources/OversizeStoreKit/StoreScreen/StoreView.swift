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
    @StateObject private var viewModel: StoreViewModel
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.isPortrait) private var isPortrait
    private var isClosable = true
    @State var isShowFireworks = false

    public init() {
        _viewModel = StateObject(wrappedValue: StoreViewModel())
    }

    public var body: some View {
        PageView {
            Group {
                switch viewModel.state {
                case .initial:
                    contentPlaceholder()
                        .task {
                            await viewModel.fetchData()
                            if case let .result(products) = self.viewModel.state {
                                await viewModel.updateState(products: products)
                            }
                        }

                case .loading:
                    contentPlaceholder()
                case let .result(data):
                    content(data: data)
                case let .error(error):
                    ErrorView(error)
                }
            }
            .paddingContent(.horizontal)
        }
        .backgroundLinerGradient(LinearGradient(colors: [.backgroundPrimary, .backgroundSecondary], startPoint: .top, endPoint: .center))
        .titleLabel {
            PremiumLabel(image: Resource.Store.zap, text: AppInfo.store.subscriptionsName, size: .medium)
        }
        .leadingBar {
            if !isPortrait, verticalSizeClass == .regular, isClosable {
                EmptyView()
            } else {
                BarButton(type: .back)
            }
        }
        .trailingBar {
            if isClosable {
                BarButton(type: .close)
            }
        }

        .bottomToolbar(style: .none, ignoreSafeArea: false) {
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
    }

    var titleText: String {
        if viewModel.isPremium {
            return "You are all set!"
        } else {
            return "Upgrade to \(AppInfo.store.subscriptionsName)"
        }
    }

    var subtitleText: String {
        if viewModel.isPremium {
            return "Thank you for use to \(AppInfo.store.subscriptionsName).\nHere's what is now unlocked."
        } else {
            return "Remove ads and unlock all features"
        }
    }

    @ViewBuilder
    private func contentPlaceholder() -> some View {
        VStack(spacing: .medium) {
            VStack(spacing: .xxSmall) {
                Text(titleText)
                    .title()
                    .foregroundColor(.onSurfaceHighEmphasis)

                Text(subtitleText)
                    .headline()
                    .foregroundColor(.onSurfaceMediumEmphasis)
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
        VStack(spacing: .medium) {
            VStack(spacing: .xxSmall) {
                Text(titleText)
                    .title()
                    .foregroundColor(.onSurfaceHighEmphasis)

                Text(subtitleText)
                    .headline()
                    .foregroundColor(.onSurfaceMediumEmphasis)
            }
            .multilineTextAlignment(.center)

            if !viewModel.isPremium {
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
            }

            StoreFeaturesView()
                .environmentObject(viewModel)

            SubscriptionPrivacyView(products: data)

            if !viewModel.isPremium {
                productsLust(data: data)
                    .padding(.bottom, 170)
            }
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
        .onChange(of: viewModel.isPremium) { newValue in
            isShowFireworks = newValue
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                isShowFireworks = false
            }
        }
    }

    @ViewBuilder
    private func productsLust(data: StoreKitProducts) -> some View {
        VStack(spacing: .small) {
//            VStack {
//                if let currentSubscription = viewModel.currentSubscription {
//                    VStack {
//                        Text("My Subscription")
//
//                        StoreProductView(product: currentSubscription, products: data) {}
//
//                        if let status = viewModel.status {
//                            StatusInfoView(product: currentSubscription, status: status, products: data)
//                        }
//                    }
//                    .listStyle(GroupedListStyle())
//                }
//            }

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
