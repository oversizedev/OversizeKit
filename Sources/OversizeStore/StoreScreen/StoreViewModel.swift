//
// Copyright © 2022 Alexander Romanov
// StoreViewModel.swift
//

import OversizeServices
import OversizeStoreService
import StoreKit
import SwiftUI

@MainActor
class StoreViewModel: ObservableObject {
    @Injected(\.storeKitService) private var storeKitService: StoreKitService
    @Published var state = StoreViewModelState.initial

    public var updateListenerTask: Task<Void, Error>?

    @Published var currentSubscription: Product?
    @Published var status: Product.SubscriptionInfo.Status?

    @Published var selectedProduct: Product?

    @AppStorage("AppState.PremiumState") var isPremium: Bool = false

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
    var selectedProductButtonDescription: String {
        guard let selectedProduct = selectedProduct else { return "" }
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
        guard let selectedProduct = selectedProduct else { return "Select product" }
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
                    print("Transaction failed verification")
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
            print("Could not update subscription status \(error)")
        }
    }

    func buy(product: Product) async -> Bool {
        do {
            let result = try await storeKitService.purchase(product)
            switch result {
            case .success:

                isPremium = true
                return true
            case .failure:
                return false
            }

        } catch StoreError.failedVerification {
            state = .error(.custom(title: "Your purchase could not be verified by the App Store."))
            return false
        } catch {
            print("Failed purchase for \(product.id): \(error)")
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
            print("✅ Product preProducts")
            // print(preProducts)

            let result = await storeKitService.updateCustomerProductStatus(products: preProducts)
            switch result {
            case let .success(finalProducts):
                if let yarlyProduct = finalProducts.autoRenewable.first(where: { $0.subscription?.subscriptionPeriod.unit == .year }) {
                    selectedProduct = yarlyProduct
                }
                state = .result(finalProducts)
                print("✅ Product updateCustomerProductStatus")
            // print(finalProducts)
            case let .failure(error):
                state = .error(error)
                print("❌ Product not fetched (\(error.title))")
            }

        case let .failure(error):
            state = .error(error)
        }
        /*
         let result = await storeKitService.fetch()
         switch result {
         case let .success(data):
             #if DEBUG
             print("✅ Product fetched")
             #endif
             state = .result(data)
         case let .failure(error):
             #if DEBUG
             print("❌ Product not fetched (\(error.title))")
             #endif
             state = .error(error)
         }
         */
    }

    func save() async -> Result<Product, AppError> {
        /*
         let item = Product()
         let result = await storeKitService.save(item)
         switch result {
         case let .success(data):
             #if DEBUG
             print("✅ Product saved")
             #endif
             return .success(data)
         case let .failure(error):
             #if DEBUG
             print("❌ Product not saved (\(error.title))")
             #endif
             return .failure(error)
         }
         */
        .failure(.network(type: .unknown))
    }
}

enum StoreViewModelState {
    case initial
    case loading
    case result(StoreKitProducts)
    case error(AppError)
}
