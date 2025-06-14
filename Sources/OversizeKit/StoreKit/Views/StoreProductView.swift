//
// Copyright © 2023 Alexander Romanov
// StoreProductView.swift
//

import FactoryKit
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
    @Environment(\.platform) private var platform
    @State var isPurchased: Bool = false

    @Binding var isSelected: Bool

    let product: Product
    let products: StoreKitProducts

    let action: () -> Void

    var type: StoreProductViewType = .row

    var isHaveIntroductoryOffer: Bool {
        if product.type == .autoRenewable, product.subscription?.introductoryOffer != nil {
            true
        } else {
            false
        }
    }

    var monthSubscriptionProduct: Product? {
        products.autoRenewable.first(where: { $0.subscription?.subscriptionPeriod.unit == .month })
    }

    var isHaveSale: Bool {
        if monthSubscriptionProduct != nil, product.subscription?.subscriptionPeriod.unit == .year {
            true
        } else {
            false
        }
    }

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
                isPurchased = await (try? store.isPurchased(product, prducts: products)) ?? false
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
                .padding(.leading, platform == .macOS ? 14 : 20)
                .padding(.top, platform == .macOS ? .xxSmall : .xSmall)
                .padding(.bottom, platform == .macOS ? 6 : 10)

            Spacer()

            if isSelected {
                Circle()
                    .fill(Color.onPrimary)
                    .frame(width: 20, height: 20)
                    .overlay {
                        IconDeprecated(.checkMini, color: topLabelbackgroundColor)
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
                .padding(.vertical, platform == .macOS ? .xxSmall : .small)
                .padding(.horizontal, platform == .macOS ? 12 : 18)
            case .collumn:
                VStack(spacing: .zero) {
                    Text(product.displayMonthsCount)
                        .title2()
                        .foregroundColor(.onSurfacePrimary)

                    Text(product.displayMonthsCountDescription)
                        .footnote(.bold)
                        .foregroundColor(.onSurfacePrimary)

                    HStack(spacing: .zero) {
                        Text(product.displayPrice)
                            .subheadline(.semibold)
                            .foregroundColor(.onSurfacePrimary)
                            .padding(.top, .xxxSmall)

                        Text(product.displayPeriod)
                            .caption2()
                            .foregroundColor(.onSurfaceSecondary)
                            .padding(.top, .xxxSmall)
                    }

                    .padding(.top, platform == .macOS ? .zero : .xxxSmall)

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
                                    IconDeprecated(.checkMini, color: Color.onPrimary)
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
            VStack(alignment: .leading, spacing: platform == .macOS ? .xxxSmall : .xxSmall) {
                HStack {
                    Text(product.displayName)
                        .headline()
                        .foregroundColor(.onSurfacePrimary)

                    if isHaveSale, !isPurchased {
                        Text("Save " + saleProcent + "%")
                            .caption2(.bold)
                            .foregroundColor(.onPrimary)
                            .padding(.horizontal, .xxSmall)
                            .padding(.vertical, platform == .macOS ? 1 : 4)
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
                    .padding(.top, platform == .macOS ? .zero : .xxxSmall)

                Text(product.displayMonthPricePeriod)
                    .caption2()
                    .padding(.top, platform == .macOS ? .zero : .xxxSmall)
            }
            .foregroundColor(.onSurfaceTertiary)
            .padding(.vertical, platform == .macOS ? .zero : .xxSmall)
            .frame(maxHeight: .infinity)

            #if os(iOS) || os(macOS)
            if isHaveSale, !isPurchased {
                Text("Save " + saleProcent + "%")
                    .caption2(.bold)
                    .foregroundColor(.onPrimary)
                    .padding(.vertical, .xxxSmall)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(Color.success)
                            .cornerRadius(platform == .macOS ? 4 : 8, corners: [.bottomLeft, .bottomRight])
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 2)
            }
            #endif
        }
    }

    var trailingLabel: some View {
        HStack {
            Spacer()

            VStack(alignment: .trailing, spacing: .xxSmall) {
                Text(product.displayPriceWithPeriod)
                    .headline(.semibold)
                    .foregroundColor(.onSurfaceSecondary)

                if let subscriptionUnit = product.subscription?.subscriptionPeriod.unit, subscriptionUnit == .year {
                    HStack(spacing: 2) {
                        if isHaveSale, let monthSubscriptionProduct, !isPurchased {
                            Text(monthSubscriptionProduct.displayPrice)
                                .strikethrough()
                                .subheadline()
                                .foregroundColor(.onSurfaceTertiary)
                        }

                        Text(product.displayMonthPrice + product.displayMonthPricePeriod)
                            .subheadline()
                            .foregroundColor(.onSurfaceSecondary)
                    }
                }
            }
        }
    }

    var labelBackground: some View {
        Group {
            #if os(iOS) || os(macOS)
            if isHaveIntroductoryOffer, type == .row {
                RoundedRectangle(cornerRadius: platform == .macOS ? 2 : 4, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .cornerRadius(platform == .macOS ? 5 : 10, corners: [.bottomLeft, .bottomRight])
            } else {
                RoundedRectangle(cornerRadius: platform == .macOS ? 5 : 10, style: .continuous)
                    .fill(Color.surfacePrimary)
                    .overlay {
                        if type == .collumn, !isSelected {
                            RoundedRectangle(cornerRadius: platform == .macOS ? 6 : 12, style: .continuous)
                                .strokeBorder(Color.backgroundTertiary, lineWidth: platform == .macOS ? 1 : 2)
                                .padding(-2)
                        }
                    }
            }
            #else
            EmptyView()
            #endif
        }
    }

    var background: some View {
        RoundedRectangle(cornerRadius: platform == .macOS ? 6 : 12, style: .continuous)
            .fill(topLabelbackgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: platform == .macOS ? 6 : 12, style: .continuous)
                    .strokeBorder(
                        backgroundStrokeBorderColor,
                        lineWidth: platform == .macOS ? 1 : 2
                    )
            }
    }

    var backgroundStrokeBorderColor: Color {
        if isPurchased {
            .success
        } else if isSelected {
            Palette.blue.color
        } else {
            switch type {
            case .row:
                .backgroundTertiary
            case .collumn:
                .surfaceSecondary
            }
        }
    }

    var topLabelbackgroundColor: Color {
        if isPurchased {
            .success
        } else if isSelected {
            Palette.blue.color
        } else {
            .surfaceSecondary
        }
    }

    var topLabelForegroundColor: Color {
        if isPurchased || isSelected {
            .onPrimary
        } else {
            Palette.violet.color
        }
    }

    var descriptionForegroundColor: Color {
        if isPurchased || product.type != .autoRenewable {
            .onSurfaceSecondary
        } else {
            .warning
        }
    }

    var descriptionFontWeight: Font.Weight {
        if isPurchased || product.type != .autoRenewable {
            .regular
        } else {
            .semibold
        }
    }

    public func storeProductStyle(_ type: StoreProductViewType = .collumn) -> StoreProductView {
        var control = self
        control.type = type
        return control
    }
}
