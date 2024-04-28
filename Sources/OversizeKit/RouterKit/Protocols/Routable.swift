//
// Copyright © 2024 Alexander Romanov
// Routable.swift, created on 14.04.2024
//

import SwiftUI

public protocol Routable: Equatable, Hashable, Identifiable {}

public extension Routable {
    var id: Self { self }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
