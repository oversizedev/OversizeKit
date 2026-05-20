//
// Copyright © 2023 Alexander Romanov
// AdViewModel.swift, created on 30.06.2023
//

import FactoryKit
import OversizeCore
import OversizeNetwork
import OversizeServices
import SwiftUI

@MainActor
@Observable
public final class AdViewModel {
    @ObservationIgnored
    @Injected(\.networkService) var networkService

    var state: LoadingState<Components.Schemas.Ad> = .idle

    public init() {}

    public func fetchAd() async {
        guard case .idle = state else { return }
        guard let id = Info.App.appStoreId else {
            state = .error(NetworkError.unknown(nil))
            return
        }
        let result = await networkService.fetchAd(appId: id)
        switch result {
        case let .success(ad):
            state = .result(ad)
            Log.info("Ads loaded")
        case let .failure(error):
            state = .error(error)
            Log.error("Not load Ads", error: error)
        }
    }
}
