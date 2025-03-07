//
// Copyright © 2023 Alexander Romanov
// AdViewModel.swift, created on 30.06.2023
//

import Factory
import OversizeModels
import OversizeNetwork
import OversizeServices
import SwiftUI

@MainActor
public class AdViewModel: ObservableObject {
    @Injected(\.networkService) var networkService

    @Published var state = State.initial

    public init() {}

    public func fetchAd() async {
        guard let id = Info.app.appStoreIDInt else {
            state = .error(.network(type: .unknown))
            return
        }
        let result = await networkService.fetchAd(appId: id)
        switch result {
        case let .success(ad):
            state = .result(ad)
        case let .failure(error):
            state = .error(error)
        }
    }
}

extension AdViewModel {
    enum State {
        case initial
        case loading
        case result(Components.Schemas.Ad)
        case error(AppError)
    }
}
