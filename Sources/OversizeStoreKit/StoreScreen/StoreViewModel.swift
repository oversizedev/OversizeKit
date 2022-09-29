//
// Copyright © 2022 Alexander Romanov
// StoreViewModel.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeServices
import OversizeStoreService
import StoreKit
import SwiftUI

@MainActor
class StoreViewModel: ObservableObject {
    enum State {
        case initial
        case loading
        case result(StoreKitProducts)
        case error(AppError)
    }

    @Injected(\.storeKitService) private var storeKitService: StoreKitService
    @Published var state = State.initial

    public var updateListenerTask: Task<Void, Error>?

    @Published var currentSubscription: Product?
    @Published var status: Product.SubscriptionInfo.Status?

    @Published var selectedProduct: Product?

    @AppStorage("AppState.PremiumState") var isPremium: Bool = false
    @AppStorage("AppState.PremiumActivated") var isPremiumActivated: Bool = false
    @AppStorage("AppState.PremiumRenewalState") var currentSubscriptionStatus: RenewalState = .revoked

    var availableSubscriptions: [Product] {
        if case let .result(products) = state {
            return products.autoRenewable.filter { $0.id != currentSubscription?.id }
        } else {
            return []
        }
    }

    public init() {
        // Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }
}

// MARK: - Descriptions

extension StoreViewModel {
    var subsribtionStatusText: String {
        guard case let .result(products) = state else { return "" }
        if !products.purchasedNonConsumable.isEmpty {
            return "Lifetime"
        }
        guard let subscriptionStatus = products.subscriptionGroupStatus else { return "" }
        switch subscriptionStatus {
        case .subscribed: return L10n.Store.active
        case .revoked:
            if #available(iOS 15.4, *) {
                return subscriptionStatus.localizedDescription
            } else {
                return "Revoked"
            }
        case .expired:
            if #available(iOS 15.4, *) {
                return subscriptionStatus.localizedDescription
            } else {
                return "Expired"
            }
        case .inBillingRetryPeriod:
            if #available(iOS 15.4, *) {
                return subscriptionStatus.localizedDescription
            } else {
                return "Billing retry"
            }
        case .inGracePeriod:
            if #available(iOS 15.4, *) {
                return subscriptionStatus.localizedDescription
            } else {
                return "Grace period"
            }
        default:
            if #available(iOS 15.4, *) {
                return subscriptionStatus.localizedDescription
            } else {
                return ""
            }
        }
    }

    var subsribtionStatusColor: Color {
        guard case let .result(products) = state else { return .yellow }
        if !products.purchasedNonConsumable.isEmpty { return .green }
        guard let subscriptionStatus = products.subscriptionGroupStatus else { return .red }
        switch subscriptionStatus {
        case .subscribed: return .green
        case .revoked: return .red
        case .expired: return .red
        case .inBillingRetryPeriod: return .yellow
        case .inGracePeriod: return .yellow
        default: return .gray
        }
    }

    var monthSubscriptionProduct: Product? {
        guard case let .result(products) = state else { return nil }
        return products.autoRenewable.first(where: { $0.subscription?.subscriptionPeriod.unit == .month })
    }

    var yearSubscriptionProduct: Product? {
        guard case let .result(products) = state else { return nil }
        return products.autoRenewable.first(where: { $0.subscription?.subscriptionPeriod.unit == .year })
    }

    var isHaveSale: Bool {
        if monthSubscriptionProduct != nil, yearSubscriptionProduct != nil {
            return true
        } else {
            return false
        }
    }

    // Percentage of decrease = |239.88 - 59.99|/239.88 = 179.89/239.88 = 0.74991662497916 = 74.991662497916%
    var saleProcent: String {
        guard let yearSubscriptionProduct else { return "" }
        if let monthSubscriptionProduct {
            let yearPriceMonthly = monthSubscriptionProduct.price * 12
            let procent = (yearPriceMonthly - yearSubscriptionProduct.price) / yearPriceMonthly
            return (procent * 100).rounded(0).toString
        } else {
            return ""
        }
    }

    var selectedProductButtonDescription: String {
        guard let selectedProduct else { return "" }
        switch selectedProduct.type {
        case .autoRenewable:
            var priceText: String = selectedProduct.displayPrice + " per year"

            if let offer = selectedProduct.subscription?.introductoryOffer {
                priceText = storeKitService.daysLabel(offer.period.value, unit: offer.period.unit) + " " + storeKitService.paymentTypeLabel(paymentMode: offer.paymentMode) + ", then " + priceText
            }
            return priceText
        case .nonConsumable:
            return selectedProduct.displayPrice + " " + selectedProduct.description.lowercased()
        default:
            return selectedProduct.description
        }
    }

    var selectedProductButtonText: String {
        guard let selectedProduct else { return "Select product" }
        switch selectedProduct.type {
        case .autoRenewable:
            if selectedProduct.subscription?.introductoryOffer != nil {
                return "Try free and subscribe"
            } else {
                return "Subscribe"
            }
        case .nonConsumable:
            return "Continue"
        default:
            return "Continue"
        }
    }
}

// MARK: - StoreKit service

extension StoreViewModel {
    public func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.storeKitService.checkVerified(result)

                    // Deliver products to the user.
                    if case let .result(products) = await self.state {
                        let result = await self.storeKitService.updateCustomerProductStatus(products: products)
                        switch result {
                        case let .success(newProducts):
                            await self.updateState(products: newProducts)
                        case .failure:
                            break
                        }
                    }

                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    log("Transaction failed verification")
                }
            }
        }
    }

    public func updateState(products: StoreKitProducts) async {
        state = .result(products)
    }

    @MainActor
    func updateSubscriptionStatus(products: StoreKitProducts) async {
        do {
            // This app has only one subscription group, so products in the subscriptions
            // array all belong to the same group. The statuses that
            // `product.subscription.status` returns apply to the entire subscription group.
            guard let product = products.autoRenewable.first,
                  let statuses = try await product.subscription?.status
            else {
                return
            }

            var highestStatus: Product.SubscriptionInfo.Status?
            var highestProduct: Product?

            // Iterate through `statuses` for this subscription group and find
            // the `Status` with the highest level of service that isn't
            // in an expired or revoked state. For example, a customer may be subscribed to the
            // same product with different levels of service through Family Sharing.
            for status in statuses {
                switch status.state {
                case .expired, .revoked:
                    continue
                default:
                    let renewalInfo = try storeKitService.checkVerified(status.renewalInfo)

                    // Find the first subscription product that matches the subscription status renewal info by comparing the product IDs.
                    guard let newSubscription = products.autoRenewable.first(where: { $0.id == renewalInfo.currentProductID }) else {
                        continue
                    }

                    guard let currentProduct = highestProduct else {
                        highestStatus = status
                        highestProduct = newSubscription
                        continue
                    }

                    let highestTier = storeKitService.tier(for: currentProduct.id)
                    let newTier = storeKitService.tier(for: renewalInfo.currentProductID)

                    if newTier > highestTier {
                        highestStatus = status
                        highestProduct = newSubscription
                    }
                }
            }

            status = highestStatus
            currentSubscription = highestProduct
        } catch {
            log("Could not update subscription status \(error)")
        }
    }

    func buy(product: Product) async -> Bool {
        do {
            let result = try await storeKitService.purchase(product)
            switch result {
            case .success:
                isPremium = true
                isPremiumActivated = true
                return true
            case .failure:
                return false
            }
        } catch StoreError.failedVerification {
            state = .error(.custom(title: "Your purchase could not be verified by the App Store."))
            return false
        } catch {
            log("Failed purchase for \(product.id): \(error)")
            return false
        }
    }
}

extension StoreViewModel {
    func fetchData() async {
        state = .loading
        // During store initialization, request products from the App Store.
        let products = await storeKitService.requestProducts()

        switch products {
        case let .success(preProducts):
            let result = await storeKitService.updateCustomerProductStatus(products: preProducts)
            switch result {
            case let .success(finalProducts):
                if let yarlyProduct = finalProducts.autoRenewable.first(where: { $0.subscription?.subscriptionPeriod.unit == .year }) {
                    selectedProduct = yarlyProduct
                }
                if let status = finalProducts.subscriptionGroupStatus {
                    currentSubscriptionStatus = status
                }
                state = .result(finalProducts)
                log("✅ StoeKit fetched")
            // log(finalProducts)
            case let .failure(error):
                state = .error(error)
                log("❌ Product not fetched (\(error.title))")
            }

        case let .failure(error):
            state = .error(error)
        }
    }
}

extension Date {
    func formattedDate() -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
}

/*
 // MARK: - StoreKit status
 extension StoreViewModel {
     var statusDescription: String {

         guard case .verified(let renewalInfo) = status?.renewalInfo,
               case .verified(let transaction) = status?.transaction else {
             return "The App Store could not verify your subscription status."
         }

         guard let status = status else { return "" }

         guard let product = currentSubscription else { return "" }
         var description = ""

         switch status.state {
         case .subscribed:
             description = subscribedDescription(product: product)
         case .expired:
             if let expirationDate = transaction.expirationDate,
                let expirationReason = renewalInfo.expirationReason {
                 description = expirationDescription(expirationReason, expirationDate: expirationDate, product: product)
             }
         case .revoked:
             if let revokedDate = transaction.revocationDate {
                 description = "The App Store refunded your subscription to \(product.displayName) on \(revokedDate.formattedDate())."
             }
         case .inGracePeriod:
             description = gracePeriodDescription(renewalInfo, product: product)
         case .inBillingRetryPeriod:
             description = billingRetryDescription(product: product)
         default:
             break
         }

         if let expirationDate = transaction.expirationDate {
             description += renewalDescription(renewalInfo, expirationDate, product: product)
         }
         return description
     }

     fileprivate func subscribedDescription(product: Product) -> String {
         return "You are currently subscribed to \(product.displayName)."
     }

     //Build a string description of the `expirationReason` to display to the user.
     fileprivate func expirationDescription(_ expirationReason: RenewalInfo.ExpirationReason, expirationDate: Date, product: Product) -> String {
         var description = ""

         switch expirationReason {
         case .autoRenewDisabled:
             if expirationDate > Date() {
                 description += "Your subscription to \(product.displayName) will expire on \(expirationDate.formattedDate())."
             } else {
                 description += "Your subscription to \(product.displayName) expired on \(expirationDate.formattedDate())."
             }
         case .billingError:
             description = "Your subscription to \(product.displayName) was not renewed due to a billing error."
         case .didNotConsentToPriceIncrease:
             description = "Your subscription to \(product.displayName) was not renewed due to a price increase that you disapproved."
         case .productUnavailable:
             description = "Your subscription to \(product.displayName) was not renewed because the product is no longer available."
         default:
             description = "Your subscription to \(product.displayName) was not renewed."
         }

         return description
     }

     fileprivate func renewalDescription(_ renewalInfo: RenewalInfo, _ expirationDate: Date, product: Product) -> String {
         guard case let .result(products) = state else { return "" }

         var description = ""

         if let newProductID = renewalInfo.autoRenewPreference {
             if let newProduct = products.autoRenewable.first(where: { $0.id == newProductID }) {
                 description += "\nYour subscription to \(newProduct.displayName)"
                 description += " will begin when your current subscription expires on \(expirationDate.formattedDate())."
             }
         } else if renewalInfo.willAutoRenew {
             description += "\nNext billing date: \(expirationDate.formattedDate())."
         }

         return description
     }

     fileprivate func gracePeriodDescription(_ renewalInfo: RenewalInfo, product: Product) -> String {
         var description = "The App Store could not confirm your billing information for \(product.displayName)."
         if let untilDate = renewalInfo.gracePeriodExpirationDate {
             description += " Please verify your billing information to continue service after \(untilDate.formattedDate())"
         }

         return description
     }

     fileprivate func billingRetryDescription(product: Product) -> String {
         var description = "The App Store could not confirm your billing information for \(product.displayName)."
         description += " Please verify your billing information to resume service."
         return description
     }

 }
 */
