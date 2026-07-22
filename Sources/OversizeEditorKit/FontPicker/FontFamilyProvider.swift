//
// Copyright © 2024 Alexander Romanov
// FontFamilyProvider.swift, created on 20.05.2026
//

#if canImport(UIKit)
import UIKit

@MainActor
enum FontFamilyProvider {
    static var familyNames: [String] {
        UIFont.familyNames.sorted()
    }

    static var systemFamilyName: String {
        UIFont.systemFont(ofSize: 16).familyName
    }

    static func fontNames(forFamily family: String) -> [String] {
        UIFont.fontNames(forFamilyName: family)
    }

    static func fontFace(for fontName: String) -> String {
        UIFont(name: fontName, size: 16)
            .flatMap { $0.fontDescriptor.object(forKey: .face) as? String }
            ?? fontName
    }

    static func displayName(for fontName: String) -> String {
        guard let font = UIFont(name: fontName, size: 16) else { return fontName }
        let family = font.familyName == systemFamilyName ? "System Font" : font.familyName
        if UIFont.fontNames(forFamilyName: font.familyName).count == 1 {
            return family
        }
        return "\(family) \(fontFace(for: fontName))"
    }
}

#elseif canImport(AppKit)
import AppKit

@MainActor
enum FontFamilyProvider {
    static var familyNames: [String] {
        NSFontManager.shared.availableFontFamilies.sorted()
    }

    static var systemFamilyName: String {
        NSFont.systemFont(ofSize: 16).familyName ?? ""
    }

    static func fontNames(forFamily family: String) -> [String] {
        NSFontManager.shared.availableMembers(ofFontFamily: family)?
            .compactMap { $0.first as? String } ?? []
    }

    static func fontFace(for fontName: String) -> String {
        guard let font = NSFont(name: fontName, size: 16) else { return fontName }
        let familyName = font.familyName ?? fontName
        return NSFontManager.shared.availableMembers(ofFontFamily: familyName)?
            .first(where: { ($0.first as? String) == fontName })
            .flatMap { $0[1] as? String } ?? fontName
    }

    static func displayName(for fontName: String) -> String {
        guard let font = NSFont(name: fontName, size: 16) else { return fontName }
        let familyName = font.familyName ?? fontName
        let displayFamily = familyName == systemFamilyName ? "System Font" : familyName
        if fontNames(forFamily: familyName).count == 1 {
            return displayFamily
        }
        return "\(displayFamily) \(fontFace(for: fontName))"
    }
}
#endif
