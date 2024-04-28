//
// Copyright © 2024 Alexander Romanov
// HUDRouter.swift, created on 14.04.2024
//

import Foundation

public class HUDRouter: ObservableObject {
    @Published public var isShowHud: Bool = false
    @Published public var hudText: String = ""

    public init() {}
}

public extension HUDRouter {
    func present(_ text: String) {
        hudText = text
        isShowHud = true
    }
}
