//
// Copyright © 2022 Alexander Romanov
// AppLauncherViewModel.swift
//

#if os(iOS)
    import LocalAuthentication
#endif
import OversizeCore
import OversizePINCode
import OversizeSecurityService
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

@MainActor
public final class AppLauncherViewModel: ObservableObject {
    @Injected(\.biometricService) var biometricService
    @Injected(\.appStateService) var appStateService
    @Injected(\.settingsService) var settingsService
    @Injected(\.appStoreReviewService) var reviewService
    @Injected(\.storeKitService) private var storeKitService: StoreKitService

    @AppStorage("AppState.PremiumState") var isPremium: Bool = false
    @AppStorage("AppState.SubscriptionsState") var subscriptionsState: RenewalState = .expired
    @Published public var pinCodeField: String = ""
    @Published public var authState: PINCodeViewState = .locked
    @Published var activeFullScreenSheet: FullScreenSheet?

    public init() {}
}

extension AppLauncherViewModel {
    enum FullScreenSheet: Identifiable, Equatable {
        case onboarding
        public var id: Int {
            hashValue
        }
    }
}

// Lockscreen
public extension AppLauncherViewModel {
    func checkPremium() {
        Task {
            let status = await storeKitService.fetchPremiumAndSubscriptionsStatus()
            isPremium = status.0
            log("\(status.0 ? "👑 Premium status" : "🆓 Free status")")
            if let subscriptionStatus = status.1 {
                if #available(iOS 15.4, *) {
                    log("📝 Subscription: \(subscriptionStatus.localizedDescription)")
                }
                subscriptionsState = subscriptionStatus
            }
        }
    }

    func checkPassword() {
        authState = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.pinCodeField == self.settingsService.getPINCode() {
                self.authState = .unlocked
            } else {
                self.authState = .error
                self.pinCodeField = ""
            }
        }
    }

    func appLockValidation() {
        Task {
            let reason = "Auth in app"
            let authenticate = await biometricService.authenticating(reason: reason)
            if authenticate {
                authState = .unlocked
            } else {
                authState = .error
            }
        }
    }

    func checkOnboarding() {
        if !appStateService.isCompletedOnbarding {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                activeFullScreenSheet = .onboarding
            }
        }
    }
}
