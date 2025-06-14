//
// Copyright © 2023 Alexander Romanov
// AboutViewModel.swift, created on 30.09.2023
//

import FactoryKit
import OversizeModels
import OversizeNetwork
import OversizeServices
import SwiftUI

@MainActor
public class AboutViewModel: ObservableObject {
    @Injected(\.networkService) var networkService
    @Published var state: AboutViewModel.State = State.initial

    public init() {}

    public func fetchApps() async {
        state = .loading
        async let resultApps = networkService.fetchApps()
        async let resultInfo = networkService.fetchCompany()
        if case let .success(apps) = await resultApps, case let .success(info) = await resultInfo {
            state = .result(apps, info)
        } else {
            state = .error(.network(type: .noResponse))
        }
    }
}

extension AboutViewModel {
    enum State {
        case initial
        case loading
        case result([Components.Schemas.App], Components.Schemas.Company)
        case error(AppError)
    }
}
