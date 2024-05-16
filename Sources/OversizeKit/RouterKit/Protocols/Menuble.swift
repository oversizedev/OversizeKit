//
// Copyright © 2024 Alexander Romanov
// File.swift, created on 06.05.2024
//

public protocol Menuble: CaseIterable, Equatable, Identifiable {}

public extension Menuble {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
