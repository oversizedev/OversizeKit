//
// Copyright © 2024 Alexander Romanov
// FontPickerViewModel.swift, created on 20.05.2026
//

import Observation
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@MainActor
@Observable
final class FontPickerViewModel {
    var searchQuery: String = ""
    private(set) var recentFonts: [String] = []

    private let allFamilies: [String]
    private let maxRecentCount = 5
    private let defaultsKey = "recentFontString"
    let alphabets: [Character] = Array("abcdefghijklmnopqrstuvwxyz")

    init() {
        allFamilies = FontFamilyProvider.familyNames
        recentFonts = Self.loadRecentFonts(key: "recentFontString")
    }

    var filteredFamilies: [String] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return allFamilies }
        return allFamilies.filter { $0.localizedCaseInsensitiveContains(trimmed) }
    }

    var systemFonts: [String] {
        FontFamilyProvider.fontNames(forFamily: FontFamilyProvider.systemFamilyName)
    }

    var isSearching: Bool {
        !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isSystemFontVisible: Bool {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || "System Font".localizedCaseInsensitiveContains(trimmed)
    }

    func families(for initial: Character) -> [String] {
        filteredFamilies.filter { $0.first?.lowercased() == String(initial) }
    }

    func fonts(for family: String) -> [String] {
        FontFamilyProvider.fontNames(forFamily: family)
    }

    func recordSelection(_ name: String) {
        var updated = recentFonts.filter { $0 != name }
        updated.insert(name, at: 0)
        recentFonts = Array(updated.prefix(maxRecentCount))
        UserDefaults.standard.set(recentFonts.joined(separator: ","), forKey: defaultsKey)
    }

    private static func loadRecentFonts(key: String) -> [String] {
        (UserDefaults.standard.string(forKey: key) ?? "")
            .split(separator: Character(","))
            .compactMap(String.init)
    }
}
