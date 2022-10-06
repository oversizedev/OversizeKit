//
// Copyright © 2022 Alexander Romanov
// StoreProductView.swift
//

import OversizeServices
import OversizeStoreService
import OversizeUI
import StoreKit
import SwiftUI

public struct StoreProductView: View {
    public enum StoreProductViewType {
        case row, collumn
    }

    @Injected(\.storeKitService) private var store: StoreKitService
    @State var isPurchased: Bool = false

    @Binding var isSelected: Bool

    let product: Product
    let products: StoreKitProducts

    let action: () -> Void

    var type: StoreProductViewType = .row

    var isHaveIntroductoryOffer: Bool {
        if product.type == .autoRenewable, product.subscription?.introductoryOffer != nil {
            return true
        } else {
            return false
        }
    }

    var monthSubscriptionProduct: Product? {
        products.autoRenewable.first(where: { $0.subscription?.subscriptionPeriod.unit == .month })
    }

    var isHaveSale: Bool {
        if monthSubscriptionProduct != nil, product.subscription?.subscriptionPeriod.unit == .year {
            return true
        } else {
            return false
        }
    }

    // Percentage of decrease = |239.88 - 59.99|/239.88 = 179.89/239.88 = 0.74991662497916 = 74.991662497916%
    var saleProcent: String {
        if let monthSubscriptionProduct {
            let yearPriceMonthly = monthSubscriptionProduct.price * 12
            let procent = (yearPriceMonthly - product.price) / yearPriceMonthly
            return (procent * 100).rounded(0).toString
        } else {
            return ""
        }
    }

    public init(product: Product, products: StoreKitProducts, isSelected: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
        self.product = product
        self.products = products
        _isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                Group {
                    switch type {
                    case .row:
                        if product.type == .autoRenewable, let offer = product.subscription?.introductoryOffer {
                            topLabelRow(offer: offer)
                        }
                    case .collumn:
                        topLabelCollumn
                    }
                }
                label
            }
            .background { background }
        }
        .buttonStyle(.plain)
        .onAppear {
            Task {
                isPurchased = (try? await store.isPurchased(product, prducts: products)) ?? false
            }
        }
    }

    var rowProduct: some View {
        Group {
            if product.type == .autoRenewable, let offer = product.subscription?.introductoryOffer {
                topLabelRow(offer: offer)
            }
            label
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
        }
    }

    var collumnProduct: some View {
        Group {
            HStack {
                Spacer()
                Text(product.description)
                    .caption2(.heavy)
                    .foregroundColor(topLabelForegroundColor)
                    .padding(.leading, 20)
                    .padding(.top, .xSmall)
                    .padding(.bottom, 10)
                Spacer()
            }

            label
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
        }
    }

    var topLabelCollumn: some View {
        HStack {
            Spacer()
            Text(product.description)
                .caption2(.semibold)
                .foregroundColor(topLabelForegroundColor)
                .padding(.top, 6)
                .padding(.bottom, 5)
            Spacer()
        }
    }

    func topLabelRow(offer: Product.SubscriptionOffer) -> some View {
        HStack {
            let trialLabel = store.daysLabel(offer.period.value, unit: offer.period.unit) + " " + store.paymentTypeLabel(paymentMode: offer.paymentMode)

            Text(trialLabel.uppercased())
                .caption2(.heavy)
                .foregroundColor(topLabelForegroundColor)
                .padding(.leading, 20)
                .padding(.top, .xSmall)
                .padding(.bottom, 10)

            Spacer()

            if isSelected {
                Circle()
                    .fill(Color.onPrimaryHighEmphasis)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Icon(.checkMini, color: topLabelbackgroundColor)
                    }
                    .padding(.trailing, .xxSmall)
            }
        }
    }

    @ViewBuilder
    var label: some View {
        Group {
            switch type {
            case .row:
                ZStack {
                    leadingLabel
                    trailingLabel
                }
                .padding(.vertical, .small)
                .padding(.horizontal, 18)
            case .collumn:

                VStack(spacing: .zero) {
                    Text(product.displayMonthsCount)
                        .title2()
                        .foregroundColor(.onSurfaceHighEmphasis)

                    Text(product.displayMonthsCountDescription)
                        .footnote(.bold)
                        .foregroundColor(.onSurfaceHighEmphasis)

                    HStack(spacing: .zero) {
                        Text(product.displayPrice)
                            .subheadline(.semibold)
                            .foregroundColor(.onSurfaceHighEmphasis)
                            .padding(.top, .xxxSmall)

                        Text(product.displayPeriod)
                            .caption2()
                            .foregroundColor(.onSurfaceMediumEmphasis)
                            .padding(.top, .xxxSmall)
                    }
                    .padding(.top, .xxxSmall)

                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.backgroundTertiary)
                        .frame(height: 2)
                        .padding(.horizontal, .small)
                        .padding(.top, .xSmall)

                    bottomLabel
                }
                .padding(.top, .small)
                .overlay(alignment: .topTrailing) {
                    Group {
                        if isSelected {
                            Circle()
                                .fill(topLabelbackgroundColor)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Icon(.checkMini, color: Color.onPrimaryHighEmphasis)
                                }
                                .padding(.top, .xxxSmall)
                                .padding(.trailing, .xxxSmall)
                        }
                    }
                }
            }
        }

        .background { labelBackground }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
    }

    var leadingLabel: some View {
        HStack {
            VStack(alignment: .leading, spacing: .xxSmall) {
                HStack {
                    Text(product.displayName)
                        .headline()
                        .foregroundColor(.onSurfaceHighEmphasis)

                    if isHaveSale, !isPurchased {
                        Text("Save " + saleProcent + "%")
                            .caption2(.bold)
                            .foregroundColor(.onPrimaryHighEmphasis)
                            .padding(.horizontal, .xxSmall)
                            .padding(.vertical, .xxxSmall)
                            .background {
                                Capsule()
                                    .fill(Color.success)
                            }
                    }
                }

                Text(product.description)
                    .subheadline(descriptionFontWeight)
                    .foregroundColor(descriptionForegroundColor)
            }

            Spacer()
        }
    }

    var bottomLabel: some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                let currency = product.subscription != nil ? product.displayCurrency + " " : ""

                Text(currency + product.displayMonthPrice)
                    .subheadline(.semibold)
                    .padding(.top, .xxxSmall)

                Text(product.displayMonthPricePeriod)
                    .caption2()
                    .padding(.top, .xxxSmall)
            }
            .foregroundColor(.onSurfaceDisabled)
            .padding(.vertical, .xxSmall)

            if isHaveSale, !isPurchased {
                Text("Save " + saleProcent + "%")
                    .caption2(.bold)
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .padding(.vertical, .xxxSmall)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(Color.success)
                            .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 2)
            }
        }
        .frame(maxHeight: .infinity)
    }

    var trailingLabel: some View {
        HStack {
            Spacer()

            VStack(alignment: .trailing, spacing: .xxSmall) {
                Text(product.displayPriceWithPeriod)
                    .headline(.semibold)
                    .foregroundColor(.onSurfaceMediumEmphasis)

                if let subscriptionUnit = product.subscription?.subscriptionPeriod.unit, subscriptionUnit == .year {
                    HStack(spacing: 2) {
                        if isHaveSale, let monthSubscriptionProduct, !isPurchased {
                            Text(monthSubscriptionProduct.displayPrice)
                                .strikethrough()
                                .subheadline()
                                .foregroundColor(.onSurfaceDisabled)
                        }

                        Text(product.displayMonthPrice + product.displayMonthPricePeriod)
                            .subheadline()
                            .foregroundColor(.onSurfaceMediumEmphasis)
                    }
                }
            }
        }
    }

    var labelBackground: some View {
        Group {
            if isHaveIntroductoryOffer, type == .row {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .overlay {
                        if type == .collumn, !isSelected {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.backgroundTertiary, lineWidth: 2)
                                .padding(-2)
                        }
                    }
            }
        }
    }

    var background: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(topLabelbackgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(backgroundStrokeBorderColor, lineWidth: 2)
            }
    }

    var backgroundStrokeBorderColor: Color {
        if isPurchased {
            return .success
        } else if isSelected {
            return Palette.blue.color
        } else {
            switch type {
            case .row:
                return .backgroundTertiary
            case .collumn:
                return .surfaceSecondary
            }
        }
    }

    var topLabelbackgroundColor: Color {
        if isPurchased {
            return .success
        } else if isSelected {
            return Palette.blue.color
        } else {
            return .surfaceSecondary
        }
    }

    var topLabelForegroundColor: Color {
        if isPurchased || isSelected {
            return .onPrimaryHighEmphasis
        } else {
            return Palette.violet.color
        }
    }

    var descriptionForegroundColor: Color {
        if isPurchased || product.type != .autoRenewable {
            return .onSurfaceMediumEmphasis
        } else {
            return .warning
        }
    }

    var descriptionFontWeight: Font.Weight {
        if isPurchased || product.type != .autoRenewable {
            return .regular
        } else {
            return .semibold
        }
    }

    public func storeProductStyle(_ type: StoreProductViewType = .collumn) -> StoreProductView {
        var control = self
        control.type = type
        return control
    }
}
