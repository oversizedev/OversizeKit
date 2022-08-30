//
// Copyright © 2022 Alexander Romanov
// AppLauncherViewModel.swift
//

#if os(iOS)
    import LocalAuthentication
#endif
import OversizePINCode
import OversizeSecurityService
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

public final class AppLauncherViewModel: ObservableObject {
    @Injected(\.biometricService) var biometricService
    @Injected(\.appStateService) var appStateService
    @Injected(\.settingsService) var settingsService
    @Injected(\.appStoreReviewService) var reviewService
    @Injected(\.storeKitService) private var storeKitService: StoreKitService

    @AppStorage("AppState.PremiumState") var isPremium: Bool = false
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
        print("Check premium...")
        Task {
            let status = await storeKitService.fetchPremiumStatus()
            isPremium = status
            print("Status: \(status ? "Premium" : "Not premium")")
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
        let reason = "Auth in app"
        #if os(iOS)
            biometricService.authenticating(reason: reason) { [weak self] authenticate in
                switch authenticate {
                case true:
                    DispatchQueue.main.async {
                        self?.authState = .unlocked
                    }
                case false:
                    DispatchQueue.main.async {
                        self?.authState = .error
                    }
                }
            }
        #endif
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
