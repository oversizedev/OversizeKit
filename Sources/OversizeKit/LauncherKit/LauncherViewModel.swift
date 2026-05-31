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
    @Published var contentType: ContentType = .content
    @Published var activeFullScreenSheet: FullScreenSheet?
    @Published var isShowSplashScreen: Bool = true
    @Published var isNeedAuthCheking = false

    let firstRunAction: (() -> Void)?

    let appUpdateAction: (() -> Void)?

    var isShowLockscreen: Bool {
        if FeatureFlags.secure.lookscreen ?? false {
            if settingsService.pinCodeEnabled || settingsService.biometricEnabled, authState != .unlocked {
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
        Container.shared.networkService.register {
            NetworkService(headers: .init(
                appBundleId: Info.App.bundleId,
                acceptLanguage: Info.App.localeIdentifier,
                appStoreId: Info.App.appStoreId,
                appVersion: Info.App.version?.description
            ))
        }
    }
}

extension LauncherViewModel {
    enum FullScreenSheet: Identifiable, Equatable {
        case payWall
        case rate
        case specialOffer(event: Components.Schemas.InAppPurchaseOffer)
        case whatsNew(version: Components.Schemas.Version)
        var id: Int {
            switch self {
            case .payWall: 1
            case .rate: 2
            case .specialOffer: 3
            case .whatsNew: 4
            }
        }
    }

    enum ContentType {
        case content, onboarding
    }
}

/// Lockscreen
public extension LauncherViewModel {
    func launcherSheetsCheck() async {
        await checkOnboarding()
        await checkAppRate()
        await checkSpecialOffer()
    }

    func checkPassword() {
        authState = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.pinCodeField == self.settingsService.getPINCode() {
                self.authState = .unlocked
                self.activeFullScreenSheet = nil
                Log.notice("Unlocked by PIN")
            } else {
                self.authState = .error
                self.pinCodeField = ""
                Log.error("PIN unlock failed")
            }
        }
    }

    func appBiometricUnlock() async {
        let reason = "Auth in app"
        let authenticate = await biometricService.authenticating(reason: reason)
        if authenticate {
            authState = .unlocked
            activeFullScreenSheet = nil
            Log.notice("Unlocked by biometric")
        } else {
            Log.error("Biometric unlock failed")
            authState = .error
        }
    }

    func checkOnboarding() async {
        if !appStateService.isCompletedOnboarding {
            contentType = .onboarding
            Log.notice("Onboarding shown")
        }
    }

    func setPayWall() {
        activeFullScreenSheet = nil
        delay(time: 0.2) {
            Task { @MainActor in
                self.activeFullScreenSheet = .payWall
                Log.notice("Paywall shown")
            }
        }
    }

    func checkAppRate() async {
        if await reviewService.isShowReviewSheet, activeFullScreenSheet == nil {
            activeFullScreenSheet = .rate
            Log.notice("App rate shown")
        }
    }

    func checkDateInSelectedPeriod(startDate: Date, endDate: Date) -> Bool {
        if startDate < endDate {
            (startDate ... endDate).contains(Date())
        } else {
            false
        }
    }

    func checkSpecialOffer() async {
        if !isPremium, activeFullScreenSheet == nil {
            await fetchAndSetSpecialOffer()
        }
    }

    @Sendable func onAppear() async {
        isShowSplashScreen = false
        if appStateService.appRunCount == 0 {
            firstRunAction?()
        } else if appStateService.lastRunVersion != Info.App.version?.description {
            appUpdateAction?()
            if Info.App.version?.isMajor == true || Info.App.version?.isMinor == true {
                await fetchAndShowWhatsNew()
            }
        }

        appStateService.appRun()

        await checkPremium()
    }

    func fetchAndShowWhatsNew() async {
        guard let appStoreID = Info.App.appStoreId,
              let currentVersion = Info.App.version else { return }
        let result = await networkService.fetchAppUpdate(appId: appStoreID, version: currentVersion.description)
        switch result {
        case let .success(version):
            activeFullScreenSheet = .whatsNew(version: version)
            Log.notice("App update screen shown")
        case let .failure(error):
            Log.error("Loading app update failed", error: error)
        }
    }

    func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .inactive:
            Log.debug("App inactive")
        case .background:
            Log.debug("App background")
            appBackgroundDate = Date()
            pinCodeField = ""
            isNeedAuthCheking = true
        case .active:
            Log.debug("App active")
            if isNeedAuthCheking, appBackgroundDate.addingTimeInterval(settingsService.appLockTimeout) < Date() {
                authState = .locked
                isNeedAuthCheking = false
            }
        @unknown default:
            break
        }
    }

    func onCompeteOnboarding(_ isCompletedOnboarding: Bool) {
        contentType = .content
        if isCompletedOnboarding, !isPremium {
            setPayWall()
        }
    }

    func checkPremium() async {
        guard let appStoreID = Info.App.appStoreId else {
            Log.critical("Not found App Store ID in AppConfig.plist")
            return
        }
        let productIdsResult = await networkService.fetchAppStoreProductIds(appId: appStoreID)

        guard let productIds = productIdsResult.successResult else {
            Log.error("Not loaded product IDs")
            return
        }

        let status = await storeKitService.fetchPremiumAndSubscriptionsStatus(productIds: productIds)

        guard let premiumStatus = status.0 else {
            Log.warning("Could not fetch premium status")
            return
        }

        isPremium = premiumStatus
        Log.debug("\(premiumStatus ? "User Premium status" : "User Free status")")

        if let subscriptionStatus = status.1 {
            if #available(iOS 15.4, macOS 12.3, *) {
                Log.info("Subscription: \(subscriptionStatus.localizedDescription)")
            }
            subscriptionsState = subscriptionStatus
        }
    }

    func fetchAndSetSpecialOffer() async {
        let result = await networkService.fetchSpecialOffers()
        switch result {
        case let .success(offers):
            Log.info("Offers loaded")
            if let offer = offers.first(where: { checkDateInSelectedPeriod(startDate: $0.startDate, endDate: $0.endDate) }) {
                if offer.id != lastClosedSpecialOffer {
                    activeFullScreenSheet = .specialOffer(event: offer)
                    Log.notice("Offer shown")
                }
            }
        case let .failure(error):
            Log.error("Loading special offers failed", error: error)
        }
    }
}
