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
    var state: LoadingState<[Components.Schemas.Version]> = .idle

    public init(input _: AppUpdates.Input?) {}
}
