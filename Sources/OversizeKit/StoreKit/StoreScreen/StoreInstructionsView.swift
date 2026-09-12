//
// Copyright © 2023 Alexander Romanov
// StoreInstructionsView.swift
//

import FactoryKit
import OversizeComponents
import OversizeLocalizable
import OversizeNavigation
import OversizeResources
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct StoreInstructionsView: View {
    @StateObject var viewModel: StoreViewModel
    @Environment(\.screenSize) var screenSize
    @Environment(\.safeAreaInsets) var safeAreaInsets
    @Environment(\.isPremium) var isPremium
    @Environment(\.dismiss) var dismiss

    @State var isShowAllPlans = false
    @State var offset: CGFloat = 0
    private var safeAreaHeight: CGFloat {
        screenSize.height - safeAreaInsets.top - safeAreaInsets.bottom
    }

    public init(specialOfferMode: Bool = false) {
        _viewModel = StateObject(wrappedValue: StoreViewModel(specialOfferMode: specialOfferMode))
    }

    public var body: some View {
        ScrollViewReader { value in
            #if os(iOS) || os(macOS)
            NavigationLayoutView(onScroll: handleOffset) {
                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        contentPlaceholder()
                    case let .result(data):
                        content(data: data)
                    case let .error(error):
                        StoreInstructionsErrorView(
                            error: error,
                            retryAction: {
                                await viewModel.fetchData()
                            },
                            continueAction: {
                                dismiss()
                            }
                        )
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
            .toolbar { toolbarContent }
            .safeAreaBarBottom {
                if case .result = viewModel.state, viewModel.selectedProduct != nil {
                    VStack(spacing: .zero) {
                        StorePaymentButtonBar(
                            trialNotification: true,
                            showDescription: true,
                            action: viewModel.specialOfferMode ? nil : {
                                isShowAllPlans = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        value.scrollTo(10, anchor: .top)
                                    }
                                }
                            }
                        )
                        .environmentObject(viewModel)
                    }
                }
            }
            .onChange(of: isPremium) { _, isPremium in
                if isPremium {
                    dismiss()
                }
            }
            .task {
                await viewModel.fetchData()
            }
            #else
            EmptyView()
            #endif
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
            .controlSize(.large)
        }
        #elseif !os(watchOS)
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .principal) {
                PremiumLabel(
                    image: Resource.Store.zap,
                    text: viewModel.productsState.result?.banner.badge ?? "Pro",
                    size: .medium
                )
                .redacted(reason: viewModel.productsState.result?.banner.badge == nil ? .placeholder : .init())
            }
        }
        #else
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") { dismiss() }
        }
        #endif
    }

    func handleOffset(_ scrollOffset: CGPoint, visibleHeaderRatio _: CGFloat) {
        offset = -scrollOffset.y
    }

    private func contentPlaceholder() -> some View {
        StoreInstructionsPlaceholderView(offset: offset)
    }

    private func content(data: StoreKitProducts) -> some View {
        VStack(spacing: .medium) {
            VStack {
                VStack(spacing: .zero) {
                    Text(viewModel.specialOfferMode ? "Limited Time" : "Free Trial")
                        .textCase(.uppercase)
                        .footnote(.bold)
                        .onBackgroundSecondary()
                        .padding(.bottom, .xxSmall)

                    Text("How your free trial works")
                        .largeTitle()
                        .foregroundColor(.onSurfacePrimary)
                        .padding(.bottom, .xSmall)

                    if viewModel.isHaveSale {
                        Group {
                            Text("Save ")
                                .foregroundColor(.onSurfaceSecondary)
                                + Text("\(viewModel.salePercent)%")
                                .foregroundColor(.accent)
                                + Text(" on subscription")
                                .foregroundColor(.onSurfaceSecondary)
                        }
                        .body(.semibold)
                    }
                }
                .multilineTextAlignment(.center)

                Spacer()

                stepsView
                    .padding(.bottom, .medium)

                Spacer()
            }
            .frame(height: safeAreaHeight - 230)
            .overlay {
                ScrollArrow(width: 30, offset: -5 + (offset * 0.05))
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .foregroundColor(.onSurfacePrimary.opacity(0.3))
                    .frame(width: 30)
                    .offset(y: safeAreaHeight - 300)
                    .opacity(1 - (offset * 0.01))
            }

            StoreFeaturesLargeView()
                .paddingContent(.horizontal)
                .environmentObject(viewModel)
                .opacity(0 + (offset * 0.01))

            if isShowAllPlans {
                productsLust(data: data)
                    .id(10)
            }

            SubscriptionPrivacyView(
                subscriptionsName: viewModel.productsState.result?.banner.badge ?? "",
                products: data
            )
        }
        .padding(.bottom, .medium)
        .onAppear {
            Task {
                await viewModel.updateSubscriptionStatus(products: data)
            }
        }
        .onChange(of: data.purchasedAutoRenewable) { _, _ in
            Task {
                await viewModel.updateSubscriptionStatus(products: data)
            }
        }
    }

    var stepsView: some View {
        VStack(alignment: .leading, spacing: .xxxSmall) {
            HStack(alignment: .top, spacing: .small) {
                Resource.Store.zap
                    .renderingMode(.template)
                    .foregroundColor(.onPrimary)
                    .padding(.small)
                    .background {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(
                                    colors: [Color(hex: "EAAB44"),
                                             Color(hex: "D24A44"),
                                             Color(hex: "9C5BA2"),
                                             Color(hex: "4B5B94")]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }

                TextBox(
                    title: "Today: Get welcome offer",
                    subtitle: "Unlock full access to all premium features",
                    spacing: .xxxSmall
                )
                .textBoxSize(.small)
                .padding(.top, 6)
                .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Capsule()
                    .fill(LinearGradient(
                        gradient: Gradient(
                            colors: [Color(hex: "EAAB44"),
                                     Color(hex: "D24A44"),
                                     Color(hex: "9C5BA2")]
                        ),
                        startPoint: .topLeading,
                        endPoint: .trailing
                    ))
                    .frame(width: 4, height: 15)
                    .padding(.vertical, .xxxSmall)
                    .padding(.leading, .medium)
            }

            HStack(alignment: .top, spacing: .small) {
                Image.Base.Notification.fill
                    .renderingMode(.template)
                    .foregroundColor(Color.onSurfaceTertiary)
                    .padding(14)
                    .background {
                        Circle()
                            .fill(Color.surfacePrimary)
                            .shadowElevation(.z2)
                    }

                TextBox(
                    title: "Day 5",
                    subtitle: "Reminder before your trial ends",
                    spacing: .xxxSmall
                )
                .textBoxSize(.small)
                .padding(.top, 6)
                .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Capsule()
                    .fill(Color.surfaceTertiary)
                    .frame(width: 4, height: 15)
                    .padding(.vertical, .xxxSmall)
                    .padding(.leading, .medium)
            }

            HStack(alignment: .top, spacing: .small) {
                Image.Base.Star.fill
                    .renderingMode(.template)
                    .foregroundColor(Color.onSurfaceTertiary)
                    .padding(14)
                    .background {
                        Circle()
                            .fill(Color.surfacePrimary)
                            .shadowElevation(.z2)
                    }

                TextBox(
                    title: "Day 7",
                    subtitle: "First payment. Cancel anytime in Settings",
                    spacing: .xxxSmall
                )
                .textBoxSize(.small)
                .padding(.top, 6)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    func productsLust(data: StoreKitProducts) -> some View {
        VStack(spacing: .small) {
            ForEach(viewModel.availableSubscriptions) { product in
                if viewModel.specialOfferMode, product.isOffer {
                    StoreProductView(product: product, products: data, isSelected: .constant(false)) {
                        Task {
                            await viewModel.buy(product: product)
                        }
                    }
                }

                if !product.isOffer {
                    StoreProductView(product: product, products: data, isSelected: .constant(false)) {
                        Task {
                            await viewModel.buy(product: product)
                        }
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

#Preview {
    StoreInstructionsView()
}
