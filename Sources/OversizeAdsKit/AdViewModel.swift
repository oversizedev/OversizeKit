//
// Copyright © 2023 Alexander Romanov
// AdViewModel.swift, created on 30.06.2023
//  

import SwiftUI
import OversizeNetwork
import Factory
import OversizeServices

@MainActor
public class AdViewModel: ObservableObject {
    @Injected(\.networkService) var networkService

    @Published var appAd: Components.Schemas.AdBanner?
    
    public func fetchAdBanners() async {
        let status = await networkService.fetchAdsBanners()
        switch status {
        case .success(let banners):
            appAd = banners.filter { $0.id != Int(Info.app.appStoreID ?? "") }.randomElement()
        case .failure:
            break
        }
    }
    
}
