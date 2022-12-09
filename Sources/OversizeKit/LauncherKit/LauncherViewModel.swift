//
// Copyright © 2022 Alexander Romanov
// LauncherViewModel.swift
//

import OversizeCore
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI
#if canImport(LocalAuthentication)
    import LocalAuthentication
#endif

@MainActor
public final class LauncherViewModel: ObservableObject {
    @Injected(Container.biometricService) var biometricService
    @Injected(Container.appStateService) var appStateService: AppStateService
    @Injected(Container.settingsService) var settingsService
    @Injected(Container.appStoreReviewService) var reviewService: AppStoreReviewServiceProtocol
    @Injected(Container.storeKitService) private var storeKitService: StoreKitService

    @AppStorage("AppState.PremiumState") var isPremium: Bool = false
    @AppStorage("AppState.SubscriptionsState") var subscriptionsState: RenewalState = .expired
    @AppStorage("AppState.LastClosedSpecialOfferSheet") var lastClosedSpecialOffer: StoreSpecialOfferEventType = .oldUser
    @Published public var pinCodeField: String = ""
    @Published public var authState: LockscreenViewState = .locked
    @Published var activeFullScreenSheet: FullScreenSheet?
    @Published var isShowSplashScreen: Bool = true

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

extension LauncherViewModel {
    enum FullScreenSheet: Identifiable, Equatable {
        case onboarding
        case payWall
        case rate
        case specialOffer(event: StoreSpecialOfferEventType)
        public var id: Int {
            switch self {
            case .onboarding: return 0
            case .payWall: return 1
            case .rate: return 2
            case .specialOffer: return 3
            }
        }
    }
}

// Lockscreen
public extension LauncherViewModel {
    func launcherSheetsChek() {
        checkOnboarding()
        checkAppRate()
        checkSpecialOffer()
    }

    func checkPremium() async {
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
            activeFullScreenSheet = .onboarding
        }
    }

    func setPayWall() {
        activeFullScreenSheet = nil
        delay(time: 0.2) {
            self.activeFullScreenSheet = .payWall
        }
    }

    func checkAppRate() {
        if reviewService.isShowReviewSheet, activeFullScreenSheet == nil {
            activeFullScreenSheet = .rate
        }
    }

    func checkSpecialOffer() {
        if !isPremium {
            for event in StoreSpecialOfferEventType.allCases where event.isNow {
                if activeFullScreenSheet == nil, lastClosedSpecialOffer != event {
                    activeFullScreenSheet = .specialOffer(event: event)
                }
            }
        }
    }
}
