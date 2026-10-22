//
// Copyright © 2026 Alexander Romanov
// StoreConfiguration.swift
//

import Foundation

enum StoreConfiguration {
    static var productIdentifiers: [String] {
        let infoIdentifiers = identifiers(in: Bundle.main.object(forInfoDictionaryKey: "Store") as? [String: Any])
        if !infoIdentifiers.isEmpty {
            return infoIdentifiers
        }

        guard let url = Bundle.main.url(forResource: "AppConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            return []
        }
        return identifiers(in: plist["Store"] as? [String: Any])
    }

    private static func identifiers(in store: [String: Any]?) -> [String] {
        guard let identifiers = store?["ProductIdentifiers"] as? [String] else {
            return []
        }
        return identifiers.filter { !$0.isEmpty }
    }
}
