//
// Copyright © 2022 Alexander Romanov
// AppLauncherViewModel.swift
//

import OversizeCore
import OversizeLockscreen
import OversizeSecurityService
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

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
    @Published public var authState: LockscreenViewState = .locked
    @Published var activeFullScreenSheet: FullScreenSheet?
    
    var isShowLockscreen: Bool {
        if FeatureFlags.secure.lookscreen ?? false {
            if settingsService.pinCodeEnabend || settingsService.biometricEnabled, authState != .unlocked {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    public init() {}
}

extension AppLauncherViewModel {
    enum FullScreenSheet: Identifiable, Equatable {
        case onboarding
        case payWall
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
            if let premiumStatus = status.0 {
                isPremium = premiumStatus
                log("\(premiumStatus ? "👑 Premium status" : "🆓 Free status")")
            }

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
                self.activeFullScreenSheet = nil
            } else {
                self.authState = .error
                self.pinCodeField = ""
            }
        }
    }
    
    func checkLockscreen() {
        if settingsService.pinCodeEnabend || settingsService.biometricEnabled,
           authState != .unlocked {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                //activeFullScreenSheet = .lockscreen
            }
        }
    }

    func appLockValidation() {
        Task {
            let reason = "Auth in app"
            let authenticate = await biometricService.authenticating(reason: reason)
            if authenticate {
                authState = .unlocked
                activeFullScreenSheet = nil
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

    func setPayWall() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            activeFullScreenSheet = nil
            activeFullScreenSheet = .payWall
        }
//        withoutAnimation {
//            activeFullScreenSheet = nil
//
//        }
    }
}
