//
// Copyright © 2026 Alexander Romanov
// AppUpdateViewState.swift, created on 04.03.2026
//

import Observation
import OversizeArchitecture
import OversizeNetwork
import SwiftUI

@Observable
public final class AppUpdateViewState: ViewStateProtocol {
    var version: Components.Schemas.Version?

    public init(input: AppUpdate.Input?) {
        version = input
    }
}
