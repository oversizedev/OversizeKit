//
// Copyright © 2026 Alexander Romanov
// AppUpdatesViewState.swift, created on 04.03.2026
//

import Observation
import OversizeArchitecture
import OversizeCore
import OversizeNetwork
import SwiftUI

@Observable
public final class AppUpdatesViewState: ViewStateProtocol {
    var state: LoadingState<StateModel> = .idle
    var isNavigationBack: Bool = false

    public init(input _: AppUpdates.Input?) {}
}

extension AppUpdatesViewState {
    struct StateModel {
        let lastVersion: Components.Schemas.Version?
        let versions: [Components.Schemas.Version]
        let firstVersion: Components.Schemas.Version
    }
}
