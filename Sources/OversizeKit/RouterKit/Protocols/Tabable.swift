//
// Copyright © 2024 Alexander Romanov
// Tabable.swift, created on 14.04.2024
//

import Foundation

public protocol Tabable: CaseIterable, Equatable, Identifiable {}

public extension Tabable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
