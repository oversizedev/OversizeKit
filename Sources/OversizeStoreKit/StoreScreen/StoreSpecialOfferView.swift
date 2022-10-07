//
// Copyright © 2022 Alexander Romanov
// StoreSpecialOfferView.swift
//

import OversizeComponents
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct StoreSpecialOfferView: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StoreViewModel
    @AppStorage("AppState.LastClosedSpecialOfferSheet") var lastClosedSpecialOffer: StoreSpecialOfferEventType = .oldUser

    @State private var isShowAllPlans = false
    @State private var offset: CGFloat = 0
    private let event: StoreSpecialOfferEventType
    
    @State var trialDaysPeriodText: String = ""

    public init(event: StoreSpecialOfferEventType = .newUser) {
        self.event = event
        _viewModel = StateObject(wrappedValue: StoreViewModel(specialOfferMode: true))
    }

    public var body: some View {
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
            BarButton(type: .closeAction(action: {
                lastClosedSpecialOffer = event
                dismiss()
            }))
        }
        .bottomToolbar(style: .none, ignoreSafeArea: false) {
            VStack(spacing: .zero) {
                StorePaymentButtonBar()
                    .environmentObject(viewModel)
                    .padding(.horizontal, 8)
            }
        }
    }

    var imageSize: CGFloat {
        if screenSize.height > 830 {
            return 144
        } else if screenSize.height > 800 {
            return 98
        } else {
            return 64
        }
    }

    @ViewBuilder
    private func content(data: StoreKitProducts) -> some View {
        ScrollViewReader { value in

            VStack(spacing: .medium) {
                VStack(spacing: .zero) {
                    if screenSize.height > 810 {
                        Spacer()
                    }

                    AsyncIllustrationView(event.specialOfferImageURL)
                        .frame(width: imageSize, height: imageSize)
                        .padding(.bottom, screenSize.height > 810 ? 38 : 8)

                    VStack(spacing: .xSmall) {
                        Text(event.specialOfferSubtitle.uppercased())
                            .footnote(.semibold)
                            .foregroundOnBackgroundMediumEmphasis()

                        Text(event.isNeedTrialDescription ? event.specialOfferTitle + " " + trialDaysPeriodText : event.specialOfferTitle)
                            .title(.bold)
                            .foregroundColor(.onSurfaceHighEmphasis)

                        Text(event.specialOfferDescription)
                            .foregroundColor(.onSurfaceMediumEmphasis)
                            .headline(.semibold)
                    }
                    .multilineTextAlignment(.center)

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
                    productsLust(data: data)
                }
                .frame(height: screenSize.safeAreaHeight - 235)
                .overlay {
                    ScrollArrow(width: 30, offset: -5 + (offset * 0.05))
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .foregroundColor(.onSurfaceHighEmphasis.opacity(0.3))
                        .frame(width: 30)
                        .offset(y: screenSize.safeAreaHeight - 370)
                        .opacity(1 - (offset * 0.01))
                }

                VStack(spacing: .zero) {
                    Text("Additional features in\nthe subscription")
                        .title()
                        .foregroundOnBackgroundHighEmphasis()
                        .multilineTextAlignment(.center)
                        .padding(.top, .large)

                    StoreFeaturesLargeView()
                }
                .paddingContent()
                .environmentObject(viewModel)
                .opacity(0 + (offset * 0.01))
                .id(10)

                SubscriptionPrivacyView(products: data)
            }
            .padding(.bottom, 180)

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
    }

    @ViewBuilder
    func productsLust(data: StoreKitProducts) -> some View {
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

struct StoreSpecialOfferView_Previews: PreviewProvider {
    static var previews: some View {
        StoreSpecialOfferView()
    }
}
