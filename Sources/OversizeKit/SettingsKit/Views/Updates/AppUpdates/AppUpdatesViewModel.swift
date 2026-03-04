//
// Copyright © 2026 Alexander Romanov
// AppUpdatesViewModel.swift, created on 04.03.2026
//

import FactoryKit
import OversizeArchitecture
import OversizeCore
import OversizeNetwork
import OversizeServices

@ViewModel(module: AppUpdates.self)
public actor AppUpdatesViewModel: ViewModelProtocol {
    @Injected(\.networkService) var networkService

    public func onFetch() async {
        guard let appId = Info.App.appStoreId else {
            await state.update { $0.state = .result([]) }
            return
        }
        await state.update { $0.state = .loading }
        let result = await networkService.fetchAppUpdates(appId: appId)
        switch result {
        case let .success(versions):
            await state.update { $0.state = .result(versions) }
        case let .failure(error):
            await state.update { $0.state = .error(error) }
        }
    }
}
