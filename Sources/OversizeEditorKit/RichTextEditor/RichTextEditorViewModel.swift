//
// Copyright © 2024 Alexander Romanov
// RichTextEditorViewModel.swift, created on 20.05.2026
//

import Observation
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
@MainActor
@Observable
final class RichTextEditorViewModel {
    var textSelection: AttributedTextSelection = .init()
    var selectedDesign: Font.Design = .default
    var selectedIsItalic: Bool = false
    var selectedTextStyle: Font.TextStyle = .body
    var isFontStyleSelection: Bool = false
    var findNavigatorIsPresented: Bool = false
    var sheet: Sheet?
    var selectedFontName: String?
    var linkURL: URL?
    var linkURLString: String = ""

    // MARK: - Typing Overrides

    var typingBoldOverride: Bool? = nil
    var typingItalicOverride: Bool? = nil
    var typingUnderlineOverride: Bool? = nil
    var typingStrikethroughOverride: Bool? = nil
    var typingColorOverride: Color? = nil
    var typingHighlightOverride: Color? = nil
    var typingRemoveHighlightOverride: Bool = false
    var typingTextStyleOverride: Font.TextStyle? = nil
    var typingFontActive: Bool = false
    var isApplyingOverrides: Bool = false

    var hasTypingOverrides: Bool {
        typingBoldOverride != nil || typingItalicOverride != nil ||
            typingUnderlineOverride != nil || typingStrikethroughOverride != nil ||
            typingColorOverride != nil || typingHighlightOverride != nil ||
            typingRemoveHighlightOverride || typingTextStyleOverride != nil ||
            typingFontActive
    }

    func clearTypingOverrides() {
        typingBoldOverride = nil
        typingItalicOverride = nil
        typingUnderlineOverride = nil
        typingStrikethroughOverride = nil
        typingColorOverride = nil
        typingHighlightOverride = nil
        typingRemoveHighlightOverride = false
        typingTextStyleOverride = nil
        typingFontActive = false
    }

    func toggleTypingBold(currentBold: Bool) {
        typingBoldOverride = !currentBold
    }

    func toggleTypingItalic() {
        let current = typingItalicOverride ?? selectedIsItalic
        typingItalicOverride = !current
        selectedIsItalic = typingItalicOverride!
    }

    func toggleTypingUnderline(in text: AttributedString) {
        let current = typingUnderlineOverride ?? (textSelection.typingAttributes(in: text).underlineStyle != nil)
        typingUnderlineOverride = !current
    }

    func toggleTypingStrikethrough(in text: AttributedString) {
        let current = typingStrikethroughOverride ?? (textSelection.typingAttributes(in: text).strikethroughStyle != nil)
        typingStrikethroughOverride = !current
    }

    init() {}

    // MARK: - Selection State

    func hasSelection(in text: AttributedString) -> Bool {
        switch textSelection.indices(in: text) {
        case .insertionPoint: false
        case let .ranges(ranges): !ranges.isEmpty
        }
    }

    var isItalicSupported: Bool {
        selectedFontName != nil || selectedDesign != .rounded
    }

    func isSelectionUnderlined(in text: AttributedString) -> Bool {
        if case .insertionPoint = textSelection.indices(in: text), let override = typingUnderlineOverride { return override }
        return textSelection.typingAttributes(in: text).underlineStyle != nil
    }

    func isSelectionStrikethrough(in text: AttributedString) -> Bool {
        if case .insertionPoint = textSelection.indices(in: text), let override = typingStrikethroughOverride { return override }
        return textSelection.typingAttributes(in: text).strikethroughStyle != nil
    }

    func hasSelectionLink(in text: AttributedString) -> Bool {
        textSelection.typingAttributes(in: text).link != nil
    }

    func selectionCurrentLink(in text: AttributedString) -> URL? {
        textSelection.typingAttributes(in: text).link
    }

    // MARK: - Underline & Strikethrough

    func toggleUnderline(text: inout AttributedString) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            toggleTypingUnderline(in: text)
        case let .ranges(ranges):
            let newStyle: Text.LineStyle? = isSelectionUnderlined(in: text) ? nil : .init(pattern: .solid)
            text.transform(updating: &textSelection) { mutableText in
                for range in ranges.ranges {
                    mutableText[range].underlineStyle = newStyle
                }
            }
        }
    }

    func toggleStrikethrough(text: inout AttributedString) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            toggleTypingStrikethrough(in: text)
        case let .ranges(ranges):
            let newStyle: Text.LineStyle? = isSelectionStrikethrough(in: text) ? nil : .init(pattern: .solid)
            text.transform(updating: &textSelection) { mutableText in
                for range in ranges.ranges {
                    mutableText[range].strikethroughStyle = newStyle
                }
            }
        }
    }

    // MARK: - Color & Link

    func applyColor(_ color: Color, text: inout AttributedString) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingColorOverride = color
        case let .ranges(ranges):
            text.transform(updating: &textSelection) { mutableText in
                for range in ranges.ranges {
                    mutableText[range].foregroundColor = color
                }
            }
        }
    }

    func applyHighlight(_ color: Color, text: inout AttributedString) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingHighlightOverride = color
            typingRemoveHighlightOverride = false
        case let .ranges(ranges):
            text.transform(updating: &textSelection) { mutableText in
                for range in ranges.ranges {
                    mutableText[range].backgroundColor = color
                }
            }
        }
    }

    func removeHighlight(text: inout AttributedString) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingHighlightOverride = nil
            typingRemoveHighlightOverride = true
        case let .ranges(ranges):
            text.transform(updating: &textSelection) { mutableText in
                for range in ranges.ranges {
                    mutableText[range].backgroundColor = nil
                }
            }
        }
    }

    func selectionHighlightColor(in text: AttributedString) -> Color? {
        textSelection.typingAttributes(in: text).backgroundColor
    }

    func applyLink(_ urlString: String, text: inout AttributedString) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let url: URL?
        if urlString.isEmpty {
            url = nil
        } else {
            let normalized = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
            url = URL(string: normalized)
        }
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                mutableText[range].link = url
            }
        }
    }

    // MARK: - Font Resolution

    #if os(iOS)
    @MainActor
    static func resolveSystemFont(size: CGFloat, bold: Bool, italic: Bool, design: Font.Design) -> Font {
        let weight: UIFont.Weight = bold ? .bold : .regular
        let baseDescriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let designedDescriptor: UIFontDescriptor = switch design {
        case .serif:
            baseDescriptor.withDesign(.serif) ?? baseDescriptor
        case .rounded:
            baseDescriptor.withDesign(.rounded) ?? baseDescriptor
        case .monospaced:
            baseDescriptor.withDesign(.monospaced) ?? baseDescriptor
        default:
            baseDescriptor
        }
        var traits = designedDescriptor.symbolicTraits
        if italic { traits.insert(.traitItalic) }
        if let finalDescriptor = designedDescriptor.withSymbolicTraits(traits) {
            return Font(UIFont(descriptor: finalDescriptor, size: size))
        }
        return Font(UIFont(descriptor: designedDescriptor, size: size))
    }

    @MainActor
    static func resolveCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        guard let uiFont = UIFont(name: name, size: size) else {
            return fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
        }
        var traits: UIFontDescriptor.SymbolicTraits = []
        if bold { traits.insert(.traitBold) }
        if italic { traits.insert(.traitItalic) }
        if let descriptor = uiFont.fontDescriptor.withSymbolicTraits(traits) {
            return Font(UIFont(descriptor: descriptor, size: size))
        }
        return fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
    }

    #elseif os(macOS)
    @MainActor
    static func resolveSystemFont(size: CGFloat, bold: Bool, italic: Bool, design: Font.Design) -> Font {
        let weight: NSFont.Weight = bold ? .bold : .regular
        let baseDescriptor = NSFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let designedDescriptor: NSFontDescriptor = switch design {
        case .serif:
            baseDescriptor.withDesign(.serif) ?? baseDescriptor
        case .rounded:
            baseDescriptor.withDesign(.rounded) ?? baseDescriptor
        case .monospaced:
            baseDescriptor.withDesign(.monospaced) ?? baseDescriptor
        default:
            baseDescriptor
        }
        var traits = designedDescriptor.symbolicTraits
        if italic { traits.insert(.italic) }
        let finalDescriptor = designedDescriptor.withSymbolicTraits(traits)
        if let nsFont = NSFont(descriptor: finalDescriptor, size: size) {
            return Font(nsFont)
        }
        return Font(NSFont(descriptor: designedDescriptor, size: size) ?? NSFont.systemFont(ofSize: size, weight: weight))
    }

    @MainActor
    static func resolveCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        guard let nsFont = NSFont(name: name, size: size) else {
            return fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
        }
        let manager = NSFontManager.shared
        var result = nsFont
        result = bold
            ? manager.convert(result, toHaveTrait: .boldFontMask)
            : manager.convert(result, toNotHaveTrait: .boldFontMask)
        result = italic
            ? manager.convert(result, toHaveTrait: .italicFontMask)
            : manager.convert(result, toNotHaveTrait: .italicFontMask)
        return Font(result)
    }

    #else
    @MainActor
    static func resolveSystemFont(size: CGFloat, bold: Bool, italic: Bool, design: Font.Design) -> Font {
        var font = Font.system(size: size, weight: bold ? .bold : .regular, design: design)
        if italic { font = font.italic() }
        return font
    }

    @MainActor
    static func resolveCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
    }
    #endif

    @MainActor
    private static func fallbackCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        var font = Font.custom(name, size: size)
        if bold { font = font.bold() }
        if italic { font = font.italic() }
        return font
    }
}
