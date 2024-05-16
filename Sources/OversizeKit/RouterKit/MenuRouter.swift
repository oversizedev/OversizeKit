//
// Copyright © 2024 Alexander Romanov
// File.swift, created on 06.05.2024
//

import Foundation

public class MenuRouter<Menu: Menuble>: ObservableObject {
    @Published public var menu: Menu?
    @Published public var subMenu: Menu?

    public init(menu: Menu) {
        self.menu = menu
    }

    public func changeMenu(_ menu: Menu) {
        self.menu = menu
    }

    public func changeSubMenu(_ menu: Menu) {
        self.menu = menu
    }
}
