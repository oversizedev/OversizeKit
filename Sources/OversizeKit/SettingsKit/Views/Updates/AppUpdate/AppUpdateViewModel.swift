//
// Copyright © 2026 Alexander Romanov
// AppUpdateViewModel.swift, created on 04.03.2026
//

import FactoryKit
import OversizeArchitecture
import OversizeCore
import OversizeNetwork
import OversizeServices

@ViewModel(module: AppUpdate.self)
public actor AppUpdateViewModel: ViewModelProtocol {
    @Injected(\.networkService) var networkService

    public func onFetch() async {
        guard let appId = Info.App.appStoreId,
              let versionString = await state.versionString
        else { return }
        await state.update { $0.state = .loading }
        let result = await networkService.fetchAppUpdate(appId: appId, version: versionString)
        switch result {
        case let .success(version):
            await state.update { $0.state = .result(version) }
        case let .failure(error):
            await state.update { $0.state = .error(error) }
        }
    }
}
