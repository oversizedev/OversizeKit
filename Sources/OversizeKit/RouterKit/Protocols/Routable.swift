//
// Copyright © 2024 Alexander Romanov
// Routable.swift, created on 14.04.2024
//

import SwiftUI

public protocol Routable: Equatable, Hashable, Identifiable {}

public extension Routable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.id == rhs.id {
            true
        } else {
            false
        }
    }
}
