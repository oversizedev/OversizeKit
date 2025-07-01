//
// Copyright © 2022 Alexander Romanov
// DebugMenuViewModel.swift
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
public final class DebugMenuViewModel: ObservableObject {
    @Injected(\.appStateService) var appStateService: AppStateService

    public init() {}

    func onTapRestOnboarding() {
        appStateService.resetOnboarding()
    }

    func onTapRestAppRunCount() {
        appStateService.resetAppRunCount()
    }
}
