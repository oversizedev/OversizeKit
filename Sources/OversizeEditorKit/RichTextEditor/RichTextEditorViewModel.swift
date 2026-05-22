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
    // MARK: - Text State

    var text: AttributedString {
        willSet {
            guard !isApplyingOverrides else { return }
            registerUndo(with: text)
        }
    }

    var canUndo: Bool = false
    var canRedo: Bool = false

    weak var undoManager: UndoManager? {
        didSet { observeUndoManager() }
    }

    // MARK: - UI State

    var textSelection: AttributedTextSelection = .init()
    var selectedDesign: Font.Design = .default
    var selectedIsItalic: Bool = false
    var selectedTextStyle: Font.TextStyle = .body {
        didSet {
            guard oldValue != selectedTextStyle else { return }
            performApplyTextStyle(selectedTextStyle)
        }
    }

    var isFontStyleSelection: Bool = false
    var findNavigatorIsPresented: Bool = false
    var sheet: Sheet?
    var selectedFontName: String?
    var linkURLString: String = ""
    var fontResolutionContext: Font.Context?

    // MARK: - Typing Overrides

    var typingBoldOverride: Bool?
    var typingItalicOverride: Bool?
    var typingUnderlineOverride: Bool?
    var typingStrikethroughOverride: Bool?
    var typingColorOverride: Color?
    var typingHighlightOverride: Color?
    var typingRemoveHighlightOverride: Bool = false
    var typingTextStyleOverride: Font.TextStyle?
    var typingFontActive: Bool = false
    private(set) var isApplyingOverrides: Bool = false

    @ObservationIgnored nonisolated(unsafe) private var undoObservations: [NSObjectProtocol] = []

    init(_ text: AttributedString) {
        self.text = text
    }

    deinit {
        undoObservations.forEach { NotificationCenter.default.removeObserver($0) }
    }
}

// MARK: - Action

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension RichTextEditorViewModel {
    enum Action {
        case undo
        case redo
        case toggleBold
        case toggleItalic
        case toggleUnderline
        case toggleStrikethrough
        case applyColor(Color)
        case applyHighlight(Color)
        case removeHighlight
        case applyLink(String)
        case applyFont(name: String?, design: Font.Design)
        case activateTypingFont
        case toggleFontStyleSelection
        case applyTypingOverrides(oldText: AttributedString, newText: AttributedString)
        case openLinkSheet
        case openAIWritingSheet
    }

    func syncText(_ newValue: AttributedString) {
        guard text != newValue else { return }
        isApplyingOverrides = true
        text = newValue
        isApplyingOverrides = false
    }

    func send(_ action: Action) {
        switch action {
        case .undo:
            undoManager?.undo()
        case .redo:
            undoManager?.redo()
        case .toggleBold:
            performToggleBold()
        case .toggleItalic:
            performToggleItalic()
        case .toggleUnderline:
            performToggleUnderline()
        case .toggleStrikethrough:
            performToggleStrikethrough()
        case let .applyColor(color):
            performApplyColor(color)
        case let .applyHighlight(color):
            performApplyHighlight(color)
        case .removeHighlight:
            performRemoveHighlight()
        case let .applyLink(urlString):
            performApplyLink(urlString)
        case let .applyFont(name, design):
            performApplyFont(fontName: name, design: design)
        case .activateTypingFont:
            typingFontActive = true
        case .toggleFontStyleSelection:
            withAnimation(.interactiveSpring) {
                isFontStyleSelection.toggle()
            }
        case let .applyTypingOverrides(oldText, newText):
            performApplyTypingOverrides(oldText: oldText, newText: newText)
        case .openLinkSheet:
            linkURLString = selectionCurrentLink?.absoluteString ?? ""
            present(.link)
        case .openAIWritingSheet:
            present(.aiWriting)
        }
    }

    func insertGeneratedText(_ inputText: String) {
        let attributed = AttributedString(inputText)
        switch textSelection.indices(in: text) {
        case .insertionPoint(let cursor):
            text.insert(attributed, at: cursor)
        case .ranges(let ranges):
            if let range = ranges.ranges.first {
                text.replaceSubrange(range, with: attributed)
            }
        }
    }
}

// MARK: - Computed State

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension RichTextEditorViewModel {
    var hasTypingOverrides: Bool {
        typingBoldOverride != nil || typingItalicOverride != nil ||
            typingUnderlineOverride != nil || typingStrikethroughOverride != nil ||
            typingColorOverride != nil || typingHighlightOverride != nil ||
            typingRemoveHighlightOverride || typingTextStyleOverride != nil ||
            typingFontActive
    }

    var hasSelection: Bool {
        switch textSelection.indices(in: text) {
        case .insertionPoint: false
        case let .ranges(ranges): !ranges.isEmpty
        }
    }

    var isItalicSupported: Bool {
        selectedFontName != nil || selectedDesign != .rounded
    }

    var isSelectionBold: Bool {
        if case .insertionPoint = textSelection.indices(in: text),
           let override = typingBoldOverride { return override }
        guard let context = fontResolutionContext else { return false }
        let font = textSelection.typingAttributes(in: text).font
        return (font ?? .default).resolve(in: context).isBold
    }

    var isEffectiveItalic: Bool {
        if case .insertionPoint = textSelection.indices(in: text) {
            return typingItalicOverride ?? selectedIsItalic
        }
        return selectedIsItalic
    }

    var isSelectionUnderlined: Bool {
        if case .insertionPoint = textSelection.indices(in: text),
           let override = typingUnderlineOverride { return override }
        return textSelection.typingAttributes(in: text).underlineStyle != nil
    }

    var isSelectionStrikethrough: Bool {
        if case .insertionPoint = textSelection.indices(in: text),
           let override = typingStrikethroughOverride { return override }
        return textSelection.typingAttributes(in: text).strikethroughStyle != nil
    }

    var hasSelectionLink: Bool {
        textSelection.typingAttributes(in: text).link != nil
    }

    var selectionCurrentLink: URL? {
        textSelection.typingAttributes(in: text).link
    }

    var selectionHighlightColor: Color? {
        textSelection.typingAttributes(in: text).backgroundColor
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
}

// MARK: - Private Implementations

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
private extension RichTextEditorViewModel {
    func registerUndo(with oldValue: AttributedString) {
        undoManager?.registerUndo(withTarget: self) { @MainActor target in
            target.text = oldValue
        }
    }

    func observeUndoManager() {
        undoObservations.forEach { NotificationCenter.default.removeObserver($0) }
        guard let um = undoManager else { return }
        let names: [NSNotification.Name] = [
            .NSUndoManagerDidUndoChange,
            .NSUndoManagerDidRedoChange,
            .NSUndoManagerDidCloseUndoGroup,
        ]
        undoObservations = names.map { name in
            NotificationCenter.default.addObserver(forName: name, object: um, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.canUndo = um.canUndo
                    self?.canRedo = um.canRedo
                }
            }
        }
    }

    func performToggleBold() {
        let isBold = isSelectionBold
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingBoldOverride = !isBold
        case let .ranges(ranges):
            guard let context = fontResolutionContext else { return }
            let newBold = !isBold
            let italic = selectedIsItalic
            let design = selectedDesign
            let fontName = selectedFontName
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    for item in mt[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                        let resolved = item.font.resolve(in: context)
                        mt[item.run].font = if let fontName {
                            RichTextEditorViewModel.resolveCustomFont(name: fontName, size: resolved.pointSize, bold: newBold, italic: italic)
                        } else {
                            RichTextEditorViewModel.resolveSystemFont(size: resolved.pointSize, bold: newBold, italic: italic, design: design)
                        }
                    }
                }
            }
        }
    }

    func performToggleItalic() {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            let current = typingItalicOverride ?? selectedIsItalic
            typingItalicOverride = !current
            selectedIsItalic = !current
        case let .ranges(ranges):
            guard let context = fontResolutionContext else { return }
            let newItalic = !selectedIsItalic
            selectedIsItalic = newItalic
            let design = selectedDesign
            let fontName = selectedFontName
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    for item in mt[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                        let resolved = item.font.resolve(in: context)
                        mt[item.run].font = if let fontName {
                            RichTextEditorViewModel.resolveCustomFont(name: fontName, size: resolved.pointSize, bold: resolved.isBold, italic: newItalic)
                        } else {
                            RichTextEditorViewModel.resolveSystemFont(size: resolved.pointSize, bold: resolved.isBold, italic: newItalic, design: design)
                        }
                    }
                }
            }
        }
    }

    func performToggleUnderline() {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            let current = typingUnderlineOverride ?? (textSelection.typingAttributes(in: text).underlineStyle != nil)
            typingUnderlineOverride = !current
        case let .ranges(ranges):
            let newStyle: Text.LineStyle? = isSelectionUnderlined ? nil : .init(pattern: .solid)
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].underlineStyle = newStyle
                }
            }
        }
    }

    func performToggleStrikethrough() {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            let current = typingStrikethroughOverride ?? (textSelection.typingAttributes(in: text).strikethroughStyle != nil)
            typingStrikethroughOverride = !current
        case let .ranges(ranges):
            let newStyle: Text.LineStyle? = isSelectionStrikethrough ? nil : .init(pattern: .solid)
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].strikethroughStyle = newStyle
                }
            }
        }
    }

    func performApplyColor(_ color: Color) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingColorOverride = color
        case let .ranges(ranges):
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].foregroundColor = color
                }
            }
        }
    }

    func performApplyHighlight(_ color: Color) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingHighlightOverride = color
            typingRemoveHighlightOverride = false
        case let .ranges(ranges):
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].backgroundColor = color
                }
            }
        }
    }

    func performRemoveHighlight() {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingHighlightOverride = nil
            typingRemoveHighlightOverride = true
        case let .ranges(ranges):
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].backgroundColor = nil
                }
            }
        }
    }

    func performApplyLink(_ urlString: String) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let url: URL? = if urlString.isEmpty {
            nil
        } else {
            URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)")
        }
        text.transform(updating: &textSelection) { mt in
            for range in ranges.ranges {
                mt[range].link = url
            }
        }
    }

    func performApplyFont(fontName: String?, design: Font.Design) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingFontActive = true
        case let .ranges(ranges):
            guard let context = fontResolutionContext else { return }
            let italic = selectedIsItalic
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    for item in mt[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                        let resolved = item.font.resolve(in: context)
                        let base = if let fontName {
                            Font.custom(fontName, size: resolved.pointSize)
                        } else {
                            Font.system(size: resolved.pointSize, weight: resolved.isBold ? .bold : .regular, design: design)
                        }
                        mt[item.run].font = italic ? base.italic() : base
                    }
                }
            }
        }
    }

    func performApplyTextStyle(_ style: Font.TextStyle) {
        switch textSelection.indices(in: text) {
        case .insertionPoint:
            typingTextStyleOverride = style
        case let .ranges(ranges):
            guard let context = fontResolutionContext else { return }
            let italic = selectedIsItalic
            let design = selectedDesign
            let customFontName = selectedFontName
            let stylePointSize = Font.system(style).resolve(in: context).pointSize
            text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    for item in mt[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                        let isBold = item.font.resolve(in: context).isBold
                        let base: Font = if let fontName = customFontName {
                            isBold ? Font.custom(fontName, size: stylePointSize).bold() : Font.custom(fontName, size: stylePointSize)
                        } else {
                            Font.system(style, design: design, weight: isBold ? .bold : .regular)
                        }
                        mt[item.run].font = italic ? base.italic() : base
                    }
                }
            }
        }
    }

    func performApplyTypingOverrides(oldText: AttributedString, newText: AttributedString) {
        let addedCount = newText.characters.count - oldText.characters.count
        guard hasTypingOverrides, addedCount > 0,
              case let .insertionPoint(cursor) = textSelection.indices(in: newText) else { return }
        var modified = newText
        applyTypingOverridesToRange(in: &modified, addedCount: addedCount, cursorIdx: cursor)
        isApplyingOverrides = true
        text = modified
        isApplyingOverrides = false
    }

    func applyTypingOverridesToRange(in text: inout AttributedString, addedCount: Int, cursorIdx: AttributedString.Index) {
        var startIdx = cursorIdx
        for _ in 0 ..< addedCount {
            startIdx = text.characters.index(before: startIdx)
        }
        let range = startIdx ..< cursorIdx

        let needsFontOverride = typingBoldOverride != nil || typingItalicOverride != nil ||
            typingTextStyleOverride != nil || typingFontActive
        if needsFontOverride, let context = fontResolutionContext {
            let boldOverride = typingBoldOverride
            let italic = typingItalicOverride ?? selectedIsItalic
            let design = selectedDesign
            let fontName = selectedFontName
            let styleOverride = typingTextStyleOverride
            let hasFontTraitOverride = typingBoldOverride != nil || typingItalicOverride != nil
            for item in text[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                let resolved = item.font.resolve(in: context)
                let bold = boldOverride ?? resolved.isBold
                let size: CGFloat = if let styleOverride {
                    Font.system(styleOverride).resolve(in: context).pointSize
                } else {
                    resolved.pointSize
                }
                text[item.run].font = if let fontName {
                    hasFontTraitOverride
                        ? RichTextEditorViewModel.resolveCustomFont(name: fontName, size: size, bold: bold, italic: italic)
                        : (italic ? Font.custom(fontName, size: size).italic() : Font.custom(fontName, size: size))
                } else {
                    RichTextEditorViewModel.resolveSystemFont(size: size, bold: bold, italic: italic, design: design)
                }
            }
        }
        if let underlineOverride = typingUnderlineOverride {
            text[range].underlineStyle = underlineOverride ? .init(pattern: .solid) : nil
        }
        if let strikethroughOverride = typingStrikethroughOverride {
            text[range].strikethroughStyle = strikethroughOverride ? .init(pattern: .solid) : nil
        }
        if let color = typingColorOverride {
            text[range].foregroundColor = color
        }
        if let highlight = typingHighlightOverride {
            text[range].backgroundColor = highlight
        } else if typingRemoveHighlightOverride {
            text[range].backgroundColor = nil
        }
    }
}

// MARK: - Font Resolution

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension RichTextEditorViewModel {
    #if os(iOS)
    @MainActor
    static func resolveSystemFont(size: CGFloat, bold: Bool, italic: Bool, design: Font.Design) -> Font {
        let weight: UIFont.Weight = bold ? .bold : .regular
        let base = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let designed: UIFontDescriptor = switch design {
        case .serif: base.withDesign(.serif) ?? base
        case .rounded: base.withDesign(.rounded) ?? base
        case .monospaced: base.withDesign(.monospaced) ?? base
        default: base
        }
        var traits = designed.symbolicTraits
        if italic { traits.insert(.traitItalic) }
        if let final = designed.withSymbolicTraits(traits) {
            return Font(UIFont(descriptor: final, size: size))
        }
        return Font(UIFont(descriptor: designed, size: size))
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
        let base = NSFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let designed: NSFontDescriptor = switch design {
        case .serif: base.withDesign(.serif) ?? base
        case .rounded: base.withDesign(.rounded) ?? base
        case .monospaced: base.withDesign(.monospaced) ?? base
        default: base
        }
        var traits = designed.symbolicTraits
        if italic { traits.insert(.italic) }
        let final = designed.withSymbolicTraits(traits)
        if let nsFont = NSFont(descriptor: final, size: size) { return Font(nsFont) }
        return Font(NSFont(descriptor: designed, size: size) ?? NSFont.systemFont(ofSize: size, weight: weight))
    }

    @MainActor
    static func resolveCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        guard let nsFont = NSFont(name: name, size: size) else {
            return fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
        }
        let manager = NSFontManager.shared
        var result = nsFont
        result = bold ? manager.convert(result, toHaveTrait: .boldFontMask) : manager.convert(result, toNotHaveTrait: .boldFontMask)
        result = italic ? manager.convert(result, toHaveTrait: .italicFontMask) : manager.convert(result, toNotHaveTrait: .italicFontMask)
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
