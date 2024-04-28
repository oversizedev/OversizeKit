//
// Copyright © 2024 Alexander Romanov
// TabRouter.swift, created on 13.04.2024
//

import Foundation

public class TabRouter<Tab: Tabable>: ObservableObject {
    @Published public var tab: Tab

    public init(tab: Tab) {
        self.tab = tab
    }

    public func changeTab(_ tab: Tab) {
        self.tab = tab
    }
}
