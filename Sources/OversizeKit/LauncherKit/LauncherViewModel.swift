//
// Copyright © 2022 Alexander Romanov
// LauncherViewModel.swift
//

import OversizeCore
import OversizeNetwork
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif
import FactoryKit

@MainActor
public final class LauncherViewModel: ObservableObject {
    @Injected(\.biometricService) var biometricService: BiometricServiceProtocol
    @Injected(\.appStateService) var appStateService: AppStateService
    @Injected(\.settingsService) var settingsService: SettingsServiceProtocol
    @Injected(\.appStoreReviewService) var reviewService: AppStoreReviewService
    @Injected(\.storeKitService) private var storeKitService: StoreKitService
    @Injected(\.networkService) var networkService

    @AppStorage("AppState.PremiumState") var isPremium: Bool = false
    @AppStorage("AppState.SubscriptionsState") var subscriptionsState: RenewalState = .expired
    @AppStorage("AppState.LastClosedSpecialOfferSheet") var lastClosedSpecialOffer: Int = .init()
    @AppStorage("AppState.AppBackgroundDate") var appBackgroundDate: Date = .init()
    @Published public var pinCodeField: String = ""
    @Published public var authState: LockscreenViewState = .locked
    @Published var activeFullScreenSheet: FullScreenSheet?
    @Published var isShowSplashScreen: Bool = true
    @Published var isNeedAuthCheking = false

    let firstRunAction: (() -> Void)?

    let appUpdateAction: (() -> Void)?

    var isShowLockscreen: Bool {
        if FeatureFlags.secure.lookscreen ?? false {
            if settingsService.pinCodeEnabend || settingsService.biometricEnabled, authState != .unlocked {
                true
            } else {
                false
            }
        } else {
            false
        }
    }

    public init(
        firstRunAction: (() -> Void)? = nil,
        appUpdateAction: (() -> Void)? = nil
    ) {
        self.firstRunAction = firstRunAction
        self.appUpdateAction = appUpdateAction
    }
}

extension LauncherViewModel {
    enum FullScreenSheet: Identifiable, Equatable, Sendable {
        case onboarding
        case payWall
        case rate
        case specialOffer(event: Components.Schemas.InAppPurchaseOffer)
        public var id: Int {
            switch self {
            case .onboarding: 0
            case .payWall: 1
            case .rate: 2
            case .specialOffer: 3
            }
        }
    }
}

// Lockscreen
public extension LauncherViewModel {
    func launcherSheetsChek() async {
        checkOnboarding()
        await checkAppRate()
        checkSpecialOffer()
    }

    func checkPassword() {
        authState = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.pinCodeField == self.settingsService.getPINCode() {
                self.authState = .unlocked
                self.activeFullScreenSheet = nil
                logSecurity("Unlocked by PIN")
            } else {
                self.authState = .error
                self.pinCodeField = ""
                logError("PIN unlock failed")
            }
        }
    }

    func appBiometricUnlock() {
        Task {
            let reason = "Auth in app"
            let authenticate = await biometricService.authenticating(reason: reason)
            if authenticate {
                authState = .unlocked
                activeFullScreenSheet = nil
                logSecurity("Unlocked by biometric")
            } else {
                logError("Biometric unlock failed")
                authState = .error
            }
        }
    }

    func checkOnboarding() {
        if !appStateService.isCompletedOnboarding {
            activeFullScreenSheet = .onboarding
            logNotice("Onboarding shown")
        }
    }

    func setPayWall() {
        activeFullScreenSheet = nil
        delay(time: 0.2) {
            Task { @MainActor in
                self.activeFullScreenSheet = .payWall
                logNotice("Paywall shown")
            }
        }
    }

    func checkAppRate() async {
        if await reviewService.isShowReviewSheet, activeFullScreenSheet == nil {
            activeFullScreenSheet = .rate
            logNotice("App rate shown")
        }
    }

    func checkDateInSelectedPeriod(startDate: Date, endDate: Date) -> Bool {
        if startDate < endDate {
            (startDate ... endDate).contains(Date())
        } else {
            false
        }
    }

    func checkSpecialOffer() {
        if !isPremium, activeFullScreenSheet == nil {
            Task {
                await fetchAndSetSpecialOffer()
            }
        }
    }

    @Sendable func onAppear() async {
        isShowSplashScreen = false
        if appStateService.appRunCount == 0 {
            firstRunAction?()
        } else if appStateService.lastRunVersion != Info.app.version {
            appUpdateAction?()
        }

        appStateService.appRun()

        await checkPremium()
    }

    func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            log("↩️ [STATE] App background")
            appBackgroundDate = Date()
            pinCodeField = ""
            isNeedAuthCheking = true
        case .active:
            log("❇️ [STATE] App active")
            if isNeedAuthCheking, appBackgroundDate.addingTimeInterval(settingsService.appLockTimeout) < Date() {
                authState = .locked
                isNeedAuthCheking = false
            }
        default:
            break
        }
    }

    func onCompeteOnboarding(_ isCompletedOnbarding: Bool) {
        if isCompletedOnbarding, !isPremium {
            setPayWall()
        } else {
            activeFullScreenSheet = nil
        }
    }

    func checkPremium() async {
        guard let appStoreID = Info.app.appStoreID else {
            logError("Not found App Store ID in AppConfig.plist")
            return
        }
        let productIdsResult = await networkService.fetchAppStoreProductIds(appId: appStoreID)

        guard let productIds = productIdsResult.successResult else {
            logError("Not loaded product IDs")
            return
        }

        let status = await storeKitService.fetchPremiumAndSubscriptionsStatus(productIds: productIds)

        guard let premiumStatus = status.0 else {
            logWarning("Could not fetch premium status")
            return
        }

        isPremium = premiumStatus
        log("\(premiumStatus ? "👑 [INFO] Premium status" : "🆓 [INFO] Free status")")

        guard let subscriptionStatus = status.1 else {
            logWarning("Could not fetch subscription status")
            return
        }

        if #available(iOS 15.4, macOS 12.3, *) {
            logInfo("Subscription: \(subscriptionStatus.localizedDescription)")
        }
        subscriptionsState = subscriptionStatus
    }

    func fetchAndSetSpecialOffer() async {
        let result = await networkService.fetchSpecialOffers()
        switch result {
        case let .success(offers):
            logSuccess("Offers loaded")
            if let offer = offers.first(where: { checkDateInSelectedPeriod(startDate: $0.startDate, endDate: $0.endDate) }) {
                if offer.id != lastClosedSpecialOffer {
                    activeFullScreenSheet = .specialOffer(event: offer)
                    logNotice("Offer shown")
                }
            }
        case let .failure(error):
            logError("Loading special offers failed", error: error)
        }
    }
}
