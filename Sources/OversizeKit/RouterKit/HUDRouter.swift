//
// Copyright © 2024 Alexander Romanov
// HUDRouter.swift, created on 14.04.2024
//

import Foundation
import OversizeModels

public class HUDRouter: ObservableObject {
    @Published public var isShowHud: Bool = false
    @Published public var hudText: String = ""
    @Published public var type: HUDMessageType = .default

    public init() {}
}

public extension HUDRouter {
    func present(_ text: String, type: HUDMessageType = .default) {
        hudText = text
        self.type = type
        isShowHud = true
    }
}
