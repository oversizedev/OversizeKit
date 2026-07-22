//
// Copyright © 2026 Alexander Romanov
// AppUpdateViewState.swift, created on 04.03.2026
//

import Observation
import OversizeArchitecture
import OversizeCore
import OversizeNetwork
import SwiftUI

@Observable
public final class AppUpdateViewState: ViewStateProtocol {
    var state: LoadingState<Components.Schemas.Version> = .idle
    var versionString: String?

    public init(input: AppUpdate.Input?) {
        if case let .version(v) = input?.source {
            state = .result(v)
        } else if case let .versionString(s) = input?.source {
            versionString = s
        }
    }
}
