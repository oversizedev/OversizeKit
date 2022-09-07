//
// Copyright © 2022 Alexander Romanov
// StoreViewInstuctins.swift
//

import SwiftUI

import OversizeComponents
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct StoreViewInstuctins: View {
    @StateObject var viewModel: StoreViewModel
    @Environment(\.screenSize) var screenSize
    @State var isShowAllPlans = false
    @State var offset: CGFloat = 0

    public init() {
        _viewModel = StateObject(wrappedValue: StoreViewModel())
    }

    public var body: some View {
        ScrollViewReader { value in
           
            PageView { offset = $0 } content: {
                Group {
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
                VStack(spacing: .zero) {
                    StorePaymentButtonBar {
                        isShowAllPlans = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                value.scrollTo(10, anchor: .top)
                            }
                        }
                    }
                    .environmentObject(viewModel)
                }

            }
        }
        
        

    }

    @ViewBuilder
    private func content(data: StoreKitProducts) -> some View {
        
                VStack(spacing: .medium) {
                    VStack {
                        VStack(spacing: .xSmall) {
                            Text("How your free trial works")
                                .largeTitle()
                                .foregroundColor(.onSurfaceHighEmphasis)

                            if viewModel.isHaveSale {
                                Group {
                                    Text("Begin your path towards feeling better with a ")
                                        .foregroundColor(.onSurfaceMediumEmphasis)

                                        + Text("\(viewModel.saleProcent)% discount")
                                        .foregroundColor(.accent)
                                }
                                .body(.semibold)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.top, .small)

                        Spacer()

                        stepsView
                            .padding(.bottom, .medium)

                        Spacer()
                    }
                    .frame(height: screenSize.safeAreaHeight - 265)
                    .overlay {
                        ScrollArrow(width: 30, offset: -5 + (offset * 0.05))
                            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .foregroundColor(.onSurfaceHighEmphasis.opacity(0.3))
                            .frame(width: 30)
                            .offset(y: screenSize.safeAreaHeight - 300)
                            .opacity(1 - (offset * 0.01))
                    }

                    StoreFeaturesLargeView()
                        .environmentObject(viewModel)
                        .opacity(0 + (offset * 0.01))

                    if isShowAllPlans {
                        productsLust(data: data)
                            .id(10)
                    }

                    SubscriptionPrivacyView(products: data)
                }
                .padding(.bottom, 220)
                .paddingContent(.horizontal)
            
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
    var stepsView: some View {
        VStack(alignment: .leading, spacing: .xxxSmall) {
            HStack(alignment: .top, spacing: .small) {
                Resource.Store.zap
                    .renderingMode(.template)
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .padding(.small)
                    .background {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(
                                    colors: [Color(hex: "EAAB44"),
                                             Color(hex: "D24A44"),
                                             Color(hex: "9C5BA2"),
                                             Color(hex: "4B5B94")]),
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                    }

                TextBox(title: "Today: Get welcome offer",
                        subtitle: "Unlock all access to functions",
                        spacing: .xxxSmall)
                    .textBoxSize(.small)
                    .padding(.top, 6)
            }

            HStack {
                Capsule()
                    .fill(LinearGradient(gradient: Gradient(
                            colors: [Color(hex: "EAAB44"),
                                     Color(hex: "D24A44"),
                                     Color(hex: "9C5BA2")]),
                        startPoint: .topLeading, endPoint: .trailing))
                    .frame(width: 4, height: 15)
                    .padding(.vertical, .xxxSmall)
                    .padding(.leading, .medium)
            }

            HStack(alignment: .top, spacing: .small) {
                Icon.Solid.UserInterface.bell
                    .renderingMode(.template)
                    .foregroundColor(Color.onSurfaceDisabled)
                    .padding(14)
                    .background {
                        Circle()
                            .fill(Color.surfacePrimary)
                            .shadowElevaton(.z2)
                    }

                TextBox(title: "Day 5",
                        subtitle: "Get a reminder about when your trial",
                        spacing: .xxxSmall)
                    .textBoxSize(.small)
                    .padding(.top, 6)
            }

            HStack {
                Capsule()
                    .fill(Color.surfaceTertiary)
                    .frame(width: 4, height: 15)
                    .padding(.vertical, .xxxSmall)
                    .padding(.leading, .medium)
            }

            HStack(alignment: .top, spacing: .small) {
                Icon.Solid.UserInterface.star
                    .renderingMode(.template)
                    .foregroundColor(Color.onSurfaceDisabled)
                    .padding(14)
                    .background {
                        Circle()
                            .fill(Color.surfacePrimary)
                            .shadowElevaton(.z2)
                    }

                TextBox(title: "Day 7",
                        subtitle: "Tou will be charged on this day, cancel anytime beforel",
                        spacing: .xxxSmall)
                    .textBoxSize(.small)
                    .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func productsLust(data: StoreKitProducts) -> some View {
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

            ForEach(viewModel.availableSubscriptions) { product in
                StoreProductView(product: product, products: data, isSelected: .constant(false)) {
                    Task {
                        await viewModel.buy(product: product)
                    }
                }
            }
            ForEach(data.nonConsumable) { product in
                StoreProductView(product: product, products: data, isSelected: .constant(false)) {
                    Task {
                        await viewModel.buy(product: product)
                    }
                }
            }
        }
    }
}

struct StoreViewInstuctins_Previews: PreviewProvider {
    static var previews: some View {
        StoreViewInstuctins()
    }
}
