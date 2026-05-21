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
        textSelection.typingAttributes(in: text).underlineStyle != nil
    }

    func isSelectionStrikethrough(in text: AttributedString) -> Bool {
        textSelection.typingAttributes(in: text).strikethroughStyle != nil
    }

    func hasSelectionLink(in text: AttributedString) -> Bool {
        textSelection.typingAttributes(in: text).link != nil
    }

    func selectionCurrentLink(in text: AttributedString) -> URL? {
        textSelection.typingAttributes(in: text).link
    }

    // MARK: - Underline & Strikethrough

    func toggleUnderline(text: inout AttributedString) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let newStyle: Text.LineStyle? = isSelectionUnderlined(in: text) ? nil : .init(pattern: .solid)
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                mutableText[range].underlineStyle = newStyle
            }
        }
    }

    func toggleStrikethrough(text: inout AttributedString) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let newStyle: Text.LineStyle? = isSelectionStrikethrough(in: text) ? nil : .init(pattern: .solid)
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                mutableText[range].strikethroughStyle = newStyle
            }
        }
    }

    // MARK: - Color & Link

    func applyColor(_ color: Color, text: inout AttributedString) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                mutableText[range].foregroundColor = color
            }
        }
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
}
