//
// Copyright © 2026 Alexander Romanov
// StoreConfiguration.swift
//

import Foundation

enum StoreConfiguration {
    static var productIdentifiers: [String] {
        guard let url = Bundle.main.url(forResource: "AppConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let store = plist["Store"] as? [String: Any],
              let identifiers = store["ProductIdentifiers"] as? [String]
        else {
            return []
        }
        return identifiers.filter { !$0.isEmpty }
    }
}
