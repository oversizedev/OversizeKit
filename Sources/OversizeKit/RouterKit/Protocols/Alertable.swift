//
// Copyright © 2024 Alexander Romanov
// Alertable.swift, created on 14.04.2024
//

import Foundation

public protocol Alertable: Equatable, Hashable, Identifiable {}

public extension Alertable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.id == rhs.id {
            true
        } else {
            false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
