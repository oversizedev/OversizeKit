//
// Copyright © 2023 Alexander Romanov
// StoreSpecialOfferView.swift
//

import CachedAsyncImage
import OversizeComponents
import OversizeCore
import OversizeLocalizable
import OversizeNetwork
import OversizeResources
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct StoreSpecialOfferView: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.dismiss) private var dismiss
    @Environment(\.platform) private var platform
    @Environment(\.isPremium) private var isPremium
    @StateObject private var viewModel: StoreViewModel
    @AppStorage("AppState.LastClosedSpecialOfferSheet") private var lastClosedSpecialOffer: Int = .init()

    @State private var isShowAllPlans = false
    @State private var offset: CGFloat = 0
    private let event: Components.Schemas.InAppPurchaseOffer

    @State var trialDaysPeriodText: String = ""
    @State var salePercent: Decimal = 0

    public init(event: Components.Schemas.InAppPurchaseOffer) {
        self.event = event
        _viewModel = StateObject(wrappedValue: StoreViewModel(specialOfferMode: true))
    }

    public var body: some View {
        #if os(iOS) || os(macOS)
        Group {
            if #available(iOS 16.0, macOS 13.0, *) {
                newPage
            } else {
                oldPage
            }
        }

        .onChange(of: isPremium) { _, status in
            if status {
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

    @available(iOS 16.0, macOS 13.0, *)
    var newPage: some View {
        NavigationStack {
            Page(badgeText, onScroll: handleOffset) {
                Group {
                    switch viewModel.state {
                    case .idle:
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            Spacer()
                        }
                    case .loading:
                        ProgressView()
                    case let .result(data):
                        content(data: data)
                            .background {
                                effectsView
                            }
                    case let .error(error):
                        ErrorView(error)
                    }
                }
            }
            .backgroundLinerGradient(LinearGradient(colors: [.backgroundPrimary, .backgroundSecondary], startPoint: .top, endPoint: .center))
            .bottomToolbar(style: .gradient) {
                VStack(spacing: .small) {
                    productsLust
                        .padding(.horizontal, .medium)
                    #if os(macOS)
                        .padding(.bottom, .medium)
                    #endif

                    #if os(iOS)
                    StorePaymentButtonBar(showDescription: false)
                        .environmentObject(viewModel)
                        .padding(.horizontal, .small)

                    #endif
                }
            }
            .toolbar(content: toolbarContent)
        }
    }

    @ToolbarContentBuilder private func toolbarContent() -> some ToolbarContent {
        #if !os(macOS)
        ToolbarItemGroup(placement: .cancellationAction) {
            Button {
                lastClosedSpecialOffer = event.id
                dismiss()
            } label: {
                Image.Base.close.icon()
            }
        }

        #else
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") {
                lastClosedSpecialOffer = event.id
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
            .controlSize(.large)
        }

        ToolbarItem(placement: .primaryAction) {
            StorePaymentToolbarButton()
                .keyboardShortcut(.defaultAction)
                .controlSize(.large)
                .environmentObject(viewModel)
        }

        #endif
    }

    @ViewBuilder
    var effectsView: some View {
        switch event.effect {
        case .snow:
            EmptyView()
        default:
            EmptyView()
        }
    }

    var oldPage: some View {
        PageView { offset = $0 } content: {
            Group {
                switch viewModel.state {
                case .idle:
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
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
            PremiumLabel(image: Resource.Store.zap, text: Info.store.subscriptionsName, size: .medium)
        }
        .trailingBar {
            BarButton(.closeAction {
                lastClosedSpecialOffer = event.id
                dismiss()
            })
        }
        .bottomToolbar(style: .none) {
            VStack(spacing: .zero) {
                productsLust
                StorePaymentButtonBar()
                    .environmentObject(viewModel)
                    .padding(.horizontal, 8)
            }
        }
    }

    func handleOffset(_ scrollOffset: CGPoint, visibleHeaderRatio _: CGFloat) {
        offset = -scrollOffset.y
        // visibleRatio = visibleHeaderRatio
    }

    var imageSize: CGFloat {
        #if os(macOS)
        return 160
        #else
        if screenSize.height > 830 {
            200
        } else if screenSize.height > 700 {
            160
        } else {
            64
        }
        #endif
    }

    @ViewBuilder
    private func content(data: StoreKitProducts) -> some View {
        ScrollViewReader { value in
            VStack(spacing: .medium) {
                VStack(spacing: .zero) {
                    PremiumLabel(image: Resource.Store.zap, text: Info.store.subscriptionsName, size: platform == .macOS ? .small : .medium)
                    #if os(macOS)
                        .padding(.vertical, .medium)
                    #else
                        .offset(y: -32)
                    #endif

                    if platform == .macOS || screenSize.height > 850 {
                        Spacer()
                    }

                    if let imageURLString = event.imageURL, let imageURL = URL(string: imageURLString) {
                        CachedAsyncImage(url: imageURL, urlCache: .imageCache) { image in
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                        } placeholder: {
                            Circle()
                                .fill(Color.surfaceTertiary)
                                .frame(width: imageSize, height: imageSize)
                        }
                        .padding(.bottom, .small)
                        .zIndex(999_999_999)
                    }
                    titleTexts

                    Button {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                value.scrollTo(10, anchor: .top)
                            }
                        }
                    } label: {
                        Text("What gives a subscription?")
                    }
                    .buttonStyle(.quaternary)
                    .accent(true)
                    .padding(.bottom, screenSize.height > 810 ? .small : .zero)

                    Spacer()
                }
                #if os(iOS)
                .frame(height: screenSize.safeAreaHeight - 235)
                #endif
                .overlay {
                    ScrollArrow(width: 30, offset: -5 + (offset * 0.05))
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .foregroundColor(.onSurfacePrimary.opacity(0.3))
                        .frame(width: 30)
                        .offset(y: screenSize.safeAreaHeight - (platform == .macOS ? 200 : 280))
                        .opacity(1 - (offset * 0.01))
                }

                VStack(spacing: .zero) {
                    Text("Additional features in\nthe subscription")
                        .title()
                        .onBackgroundPrimaryForeground()
                        .multilineTextAlignment(.center)
                        .fixedSize()
                        .padding(.top, .large)

                    StoreFeaturesLargeView()
                }
                .paddingContent()
                .environmentObject(viewModel)
                .opacity(0 + (offset * 0.01))
                .id(10)

                SubscriptionPrivacyView(products: data)
                    .padding(.horizontal, .medium)
                    .padding(.bottom, .large)
            }
            .padding(.bottom, 180)
            .task {
                await viewModel.updateSubscriptionStatus(products: data)
            }
            .onChange(of: data.purchasedAutoRenewable) { _, _ in
                Task {
                    await viewModel.updateSubscriptionStatus(products: data)
                }
            }
        }
    }

    var titleTexts: some View {
        VStack(spacing: .zero) {
            Text(badgeText.uppercased())
                .footnote(.semibold)
                .onBackgroundSecondaryForeground()
                .padding(.bottom, .xxxSmall)

            Text(headline)
                .title(.bold)
                .foregroundColor(.onSurfacePrimary)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(event.title)
                .largeTitle(.heavy)
                .foregroundColor(titleColor)

            Text(description)
                .foregroundColor(.onSurfaceSecondary)
                .headline(.regular)
                .padding(.top, .xSmall)
        }
        .multilineTextAlignment(.center)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(
                    stops: [
                        .init(color: Color.surfaceSecondary, location: 0),
                        .init(color: Color.surfaceSecondary.opacity(0), location: 0.7),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.surfaceTertiary, location: 0),
                                    .init(color: Color.surfaceSecondary.opacity(0), location: 0.7),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                )
                .padding(.top, -54)
                .padding(.bottom, -100)
        }
        .padding(.horizontal, .small)
    }

    var badgeText: String {
        if let badge = event.badge {
            textPrepere(badge)
        } else {
            ""
        }
    }

    var headline: String {
        if let headline = event.headline {
            textPrepere(headline)
        } else {
            ""
        }
    }

    var titleColor: Color {
        if let accentColor = event.accentColor {
            Color(hex: accentColor)
        } else {
            Color.onBackgroundPrimary
        }
    }

    var description: String {
        if let description = event.description {
            textPrepere(description)
        } else {
            ""
        }
    }

    func textPrepere(_ text: String) -> String {
        text
            .replacingOccurrences(of: "<salePercent>", with: salePercent.toString)
            .replacingOccurrences(of: "<freeDays>", with: trialDaysPeriodText)
            .replacingOccurrences(of: "<subscriptionName>", with: Info.store.subscriptionsName)
    }

    @ViewBuilder
    var productsLust: some View {
        if case let .result(data) = viewModel.state {
            VStack(spacing: .small) {
                ForEach(viewModel.availableSubscriptions) { product in
                    if product.isOffer {
                        StoreProductView(product: product, products: data, isSelected: .constant(false)) {
                            Task {
                                await viewModel.buy(product: product)
                            }
                        }
                        .onAppear {
                            if product.type == .autoRenewable, let offer = product.subscription?.introductoryOffer {
                                trialDaysPeriodText = viewModel.storeKitService.daysLabel(offer.period.value, unit: offer.period.unit)
                                salePercent = viewModel.storeKitService.salePercent(product: product, products: data)
                            }
                        }
                    }
                }
                ForEach(data.nonConsumable) { product in
                    if product.isOffer {
                        StoreProductView(product: product, products: data, isSelected: .constant(false)) {
                            Task {
                                await viewModel.buy(product: product)
                            }
                        }
                    }
                }
            }
        }
    }
}

// struct StoreSpecialOfferView_Previews: PreviewProvider {
//    static var previews: some View {
//        StoreSpecialOfferView()
//    }
// }
