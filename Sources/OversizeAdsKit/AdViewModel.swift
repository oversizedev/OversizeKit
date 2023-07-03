//
// Copyright © 2023 Alexander Romanov
// AdViewModel.swift, created on 30.06.2023
//

import OversizeServices
import SwiftUI
// import OversizeNetwork
// import Factory

@MainActor
public class AdViewModel: ObservableObject {
    let appAd = Info.all?.apps.filter { $0.id != Info.app.appStoreID }.randomElement()
    /*
     @Injected(\.networkService) var networkService

     public func fetchAdBanners() async {
         let status = await networkService.fetchAdsBanners()
         switch status {
         case .success(let banners):
             appAd = banners.filter { $0.id != Int(Info.app.appStoreID ?? "") }.randomElement()
         case .failure:
             break
         }
     }
      */
}
