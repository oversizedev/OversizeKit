//
// Copyright © 2022 Alexander Romanov
// DebugInfoViewModel.swift
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
public final class DebugInfoViewModel: ObservableObject {
    @Injected(\.appStateService) var appStateService: AppStateService
    @Injected(\.settingsService) var settingsService: SettingsServiceProtocol
    @Injected(\.appStoreReviewService) var reviewService: AppStoreReviewServiceProtocol

    public init() {}
}
