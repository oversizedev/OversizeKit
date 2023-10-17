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
        let result = await networkService.fetchApps()
        switch result {
        case let .success(ads):
            guard let ad = ads.filter({ $0.appStoreId != Info.app.appStoreID }).randomElement() else {
                state = .error(.custom(title: "Not ad"))
                return
            }
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
        case result(Components.Schemas.AppShort)
        case error(AppError)
    }
}
