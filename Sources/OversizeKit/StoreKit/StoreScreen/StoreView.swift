//
// Copyright © 2023 Alexander Romanov
// StoreView.swift
//

import OversizeComponents
import OversizeLocalizable
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
        Page {
            Group {
                switch viewModel.state {
                case .initial, .loading:
                    contentPlaceholder()
                case let .result(data):
                    content(data: data)
                        .if(platform == .macOS) { view in
                            view.padding(.top, 24)
                        }
                case let .error(error):
                    ErrorView(error)
                }
            }
            .paddingContent(.horizontal)
        }
        #if os(macOS)
        .backgroundSecondary()
        #endif
//            .backgroundLinerGradient(LinearGradient(colors: [.backgroundPrimary, .backgroundSecondary], startPoint: .top, endPoint: .center))
//            .titleLabel {
//                PremiumLabel(image: Resource.Store.zap, text: Info.store.subscriptionsName, size: .medium)
//            }
//            .leadingBar {
//                if !isPortrait, verticalSizeClass == .regular, isClosable {
//                    EmptyView()
//                } else {
//                    BarButton(.back)
//                }
//            }
//            .trailingBar {
//                if isClosable {
//                    BarButton(.close)
//                }
//            }
        .bottomToolbar(style: .none) {
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
            "Upgrade to \(Info.store.subscriptionsName)"
        }
    }

    var subtitleText: String {
        if viewModel.isPremium {
            "Thank you for use to \(Info.store.subscriptionsName).\nHere's what is now unlocked."
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

            if !viewModel.isPremium {
                HStack(spacing: .xSmall) {
                    ForEach(viewModel.availableSubscriptions /* data.autoRenewable */ ) { product in
                        if !product.isOffer {
                            StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                                viewModel.selectedProduct = product
                            }
                            .storeProductStyle(.collumn)
                        }
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
                if !product.isOffer {
                    StoreProductView(product: product, products: data, isSelected: .constant(viewModel.selectedProduct == product)) {
                        viewModel.selectedProduct = product
                    }
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
