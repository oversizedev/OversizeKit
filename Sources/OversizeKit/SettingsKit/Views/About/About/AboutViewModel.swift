//
// Copyright © 2023 Alexander Romanov
// AboutViewModel.swift, created on 30.09.2023
//

import FactoryKit
import OversizeCore
import OversizeNetwork
import OversizeServices
import OversizeUI
import SwiftUI

@MainActor
public class AboutViewModel: ObservableObject {
    @Injected(\.networkService) var networkService
    @Published var state: AboutViewModel.State = State.initial

    public init() {}

    public func fetchApps() async {
        state = .loading

        var networkPlatform: Components.Schemas.PlatformType

        #if os(macOS) || targetEnvironment(macCatalyst)
        networkPlatform = .macOS
        #elseif os(watchOS)
        networkPlatform = .watchOS
        #elseif os(visionOS)
        networkPlatform = visionOS
        #elseif canImport(UIKit)

        switch UIDevice.current.userInterfaceIdiom {
        case .tv:
            networkPlatform = .tvOS
        default:
            networkPlatform = .iOS
        }

        #else
        networkPlatform = .iOS
        #endif

        async let resultApps = networkService.fetchApps(platforms: [networkPlatform])
        async let resultInfo = networkService.fetchCompany()
        if case let .success(apps) = await resultApps, case let .success(info) = await resultInfo {
            state = .result(apps, info)
        } else {
            state = .error(NetworkError.noResponse)
        }
    }
}

extension AboutViewModel {
    enum State {
        case initial
        case loading
        case result([Components.Schemas.App], Components.Schemas.Company)
        case error(Error)
    }
}
