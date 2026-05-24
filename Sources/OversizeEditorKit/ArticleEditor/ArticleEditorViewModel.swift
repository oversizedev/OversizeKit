//
// Copyright © 2024 Alexander Romanov
// ArticleEditorViewModel.swift, created on 03.03.2024
//

import OversizeCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
@MainActor
@Observable
final class ArticleEditorViewModel {
    // MARK: - State

    var blocks: [ArticleBlock] = [.init()]
    var focusedId: UUID?
    #if canImport(UIKit)
    var pickerSelectedImage: UIImage?
    #endif

    // MARK: - Formatting State

    var textSelection: AttributedTextSelection = .init()
    var fontResolutionContext: Font.Context?
    var selectedIsItalic: Bool = false
    var isFontStyleSelection: Bool = false
    var selectedTextStyle: Font.TextStyle = .body {
        didSet {
            guard oldValue != selectedTextStyle else { return }
            performApplyTextStyle(selectedTextStyle)
        }
    }

    var selectedDesign: Font.Design = .default
    var selectedFontName: String?
    var linkURL: URL?
    var sheet: Sheet?

    // MARK: - Typing Overrides

    var typingBoldOverride: Bool?
    var typingItalicOverride: Bool?
    var typingUnderlineOverride: Bool?
    var typingStrikethroughOverride: Bool?
    var typingHighlightColor: Color?
    var typingRemoveHighlight: Bool = false
    var typingLinkURL: URL?
    var typingRemoveLink: Bool = false
    var typingTextStyleOverride: Font.TextStyle?
    var typingFontActive: Bool = false
    private(set) var isApplyingOverrides: Bool = false

    // MARK: - Action

    enum Action {
        case splitBlock(blockId: UUID, text: AttributedString, continuationType: BlockType)
        case insertBlock(ArticleBlock)
        case removeBlock(blockId: UUID)
        case moveBlocks(fromOffsets: IndexSet, toOffset: Int)
        case deleteOffsets(IndexSet)
        case insertImage
        #if canImport(UIKit)
        case imageSelected(UIImage?)
        #endif
        case toggleBold
        case toggleItalic
        case toggleUnderline
        case toggleStrikethrough
        case applyHighlight(Color)
        case removeHighlight
        case toggleFontStyleSelection
        case openTextStylePicker
        case openFontPicker
        case openLinkSheet
        case applyLink(URL?)
        case applyFont(name: String?, design: Font.Design)
        case applyTypingOverrides(blockId: UUID, oldText: AttributedString, newText: AttributedString)
    }

    func send(_ action: Action) {
        switch action {
        case let .splitBlock(blockId, text, continuationType):
            performSplitBlock(blockId: blockId, text: text, continuationType: continuationType)
        case let .insertBlock(block):
            performInsertBlock(block)
        case let .removeBlock(blockId):
            blocks.removeAll { $0.id == blockId }
        case let .moveBlocks(from, to):
            blocks.move(fromOffsets: from, toOffset: to)
        case let .deleteOffsets(offsets):
            blocks.remove(atOffsets: offsets)
        case .insertImage:
            #if os(iOS)
            sheet = .photoPicker
            #endif
        #if canImport(UIKit)
        case let .imageSelected(image):
            performImageSelected(image)
        #endif
        case .toggleBold:
            performToggleBold()
        case .toggleItalic:
            performToggleItalic()
        case .toggleUnderline:
            performToggleUnderline()
        case .toggleStrikethrough:
            performToggleStrikethrough()
        case let .applyHighlight(color):
            performApplyHighlight(color)
        case .removeHighlight:
            performRemoveHighlight()
        case .toggleFontStyleSelection:
            isFontStyleSelection.toggle()
        case .openTextStylePicker:
            sheet = .textStylePicker
        case .openFontPicker:
            sheet = .fontPicker
        case .openLinkSheet:
            linkURL = selectionCurrentLink
            sheet = .link
        case let .applyLink(url):
            performApplyLink(url)
            sheet = nil
        case let .applyFont(name, design):
            performApplyFont(fontName: name, design: design)
        case let .applyTypingOverrides(blockId, oldText, newText):
            performApplyTypingOverrides(blockId: blockId, oldText: oldText, newText: newText)
        }
    }

    func handleDeleteKey(blockId: UUID) -> KeyPress.Result {
        guard let idx = blocks.firstIndex(where: { $0.id == blockId }),
              blocks[idx].text.characters.isEmpty,
              idx > 0
        else { return .ignored }
        blocks.remove(at: idx)
        focusedId = blocks[..<idx]
            .last(where: { $0.type == .text || $0.type == .quote || $0.type == .list })?.id
        return .handled
    }
}

// MARK: - Event Handlers

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension ArticleEditorViewModel {
    func onFocusedBlockTextChanged(from oldText: AttributedString, to newText: AttributedString) {
        guard !isApplyingOverrides, let id = focusedId else { return }
        if newText.characters.contains("\n") {
            send(.splitBlock(blockId: id, text: newText, continuationType: focusedBlockContinuationType))
            return
        }
        let addedCount = newText.characters.count - oldText.characters.count
        if hasTypingOverrides, addedCount > 0 {
            send(.applyTypingOverrides(blockId: id, oldText: oldText, newText: newText))
        } else if isFontStyleSelection, !hasTypingOverrides {
            isFontStyleSelection = false
        }
    }

    func onTextSelectionChanged(_ newSelection: AttributedTextSelection) {
        if case .ranges = newSelection.indices(in: focusedBlockText) {
            clearTypingOverrides()
        }
    }
}

// MARK: - Sheet

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension ArticleEditorViewModel {
    enum Sheet: Identifiable {
        case textStylePicker, fontPicker, link, photoPicker

        var id: String {
            switch self {
            case .textStylePicker: "textStylePicker"
            case .fontPicker: "fontPicker"
            case .link: "link"
            case .photoPicker: "photoPicker"
            }
        }
    }
}

// MARK: - Computed State

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension ArticleEditorViewModel {
    var hasSelection: Bool {
        guard let idx = focusedBlockIndex else { return false }
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint: return false
        case let .ranges(ranges): return !ranges.isEmpty
        }
    }

    var hasTypingOverrides: Bool {
        typingBoldOverride != nil || typingItalicOverride != nil ||
            typingUnderlineOverride != nil || typingStrikethroughOverride != nil ||
            typingHighlightColor != nil || typingRemoveHighlight ||
            typingLinkURL != nil || typingRemoveLink ||
            typingTextStyleOverride != nil || typingFontActive
    }

    func clearTypingOverrides() {
        typingBoldOverride = nil
        typingItalicOverride = nil
        typingUnderlineOverride = nil
        typingStrikethroughOverride = nil
        typingHighlightColor = nil
        typingRemoveHighlight = false
        typingLinkURL = nil
        typingRemoveLink = false
        typingTextStyleOverride = nil
        typingFontActive = false
    }

    var isSelectionBold: Bool {
        if case .insertionPoint = textSelection.indices(in: focusedBlockText),
           let override = typingBoldOverride { return override }
        guard let idx = focusedBlockIndex, let context = fontResolutionContext else { return false }
        let font = textSelection.typingAttributes(in: blocks[idx].text).font
        return (font ?? .default).resolve(in: context).isBold
    }

    var isEffectiveItalic: Bool {
        if case .insertionPoint = textSelection.indices(in: focusedBlockText) {
            return typingItalicOverride ?? selectedIsItalic
        }
        return selectedIsItalic
    }

    var isSelectionUnderlined: Bool {
        if case .insertionPoint = textSelection.indices(in: focusedBlockText),
           let override = typingUnderlineOverride { return override }
        guard let idx = focusedBlockIndex else { return false }
        return textSelection.typingAttributes(in: blocks[idx].text).underlineStyle != nil
    }

    var isSelectionStrikethrough: Bool {
        if case .insertionPoint = textSelection.indices(in: focusedBlockText),
           let override = typingStrikethroughOverride { return override }
        guard let idx = focusedBlockIndex else { return false }
        return textSelection.typingAttributes(in: blocks[idx].text).strikethroughStyle != nil
    }

    var hasSelectionLink: Bool {
        if case .insertionPoint = textSelection.indices(in: focusedBlockText) {
            if typingRemoveLink { return false }
            if typingLinkURL != nil { return true }
        }
        guard let idx = focusedBlockIndex else { return false }
        return textSelection.typingAttributes(in: blocks[idx].text).link != nil
    }

    var selectionHighlightColor: Color? {
        if case .insertionPoint = textSelection.indices(in: focusedBlockText) {
            if typingRemoveHighlight { return nil }
            if let color = typingHighlightColor { return color }
        }
        guard let idx = focusedBlockIndex else { return nil }
        return textSelection.typingAttributes(in: blocks[idx].text).backgroundColor
    }

    var selectedTextStyleName: String {
        selectedTextStyle.displayName
    }

    var isItalicSupported: Bool {
        true
    }

    var focusedBlockContinuationType: BlockType {
        guard let idx = focusedBlockIndex else { return .text }
        return blocks[idx].type == .list ? .list : .text
    }

    var selectionCurrentLink: URL? {
        guard let idx = focusedBlockIndex else { return nil }
        return textSelection.typingAttributes(in: blocks[idx].text).link
    }

    private var focusedBlockIndex: Int? {
        blocks.firstIndex(where: { $0.id == focusedId })
    }

    var focusedBlockText: AttributedString {
        focusedBlockIndex.map { blocks[$0].text } ?? .init()
    }
}

// MARK: - Private Block Operations

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
private extension ArticleEditorViewModel {
    func performSplitBlock(blockId: UUID, text: AttributedString, continuationType: BlockType) {
        let chars = text.characters
        guard let nlCharIdx = chars.firstIndex(of: "\n"),
              let idx = blocks.firstIndex(where: { $0.id == blockId })
        else { return }

        let nlOffset = chars.distance(from: chars.startIndex, to: nlCharIdx)
        let nlAttrIdx = text.index(text.startIndex, offsetByCharacters: nlOffset)
        blocks[idx].text = AttributedString(text[..<nlAttrIdx])

        let nextCharIdx = chars.index(after: nlCharIdx)
        let after: AttributedString = nextCharIdx < chars.endIndex
            ? AttributedString(text[text.index(text.startIndex, offsetByCharacters: chars.distance(from: chars.startIndex, to: nextCharIdx))...])
            : .init()

        var newBlock = ArticleBlock(type: continuationType)
        newBlock.text = after
        blocks.insert(newBlock, at: idx + 1)
        focusedId = newBlock.id
    }

    func performInsertBlock(_ newBlock: ArticleBlock) {
        if let idx = blocks.firstIndex(where: { $0.id == focusedId }) {
            blocks.insert(newBlock, at: idx + 1)
        } else {
            blocks.append(newBlock)
        }
        if newBlock.type == .text || newBlock.type == .quote || newBlock.type == .list {
            focusedId = newBlock.id
        }
    }

    #if canImport(UIKit)
    func performImageSelected(_ image: UIImage?) {
        guard let image, let data = image.jpegData(compressionQuality: 0.8) else { return }
        let newBlock = ArticleBlock(imageData: data)
        performInsertBlock(newBlock)
        pickerSelectedImage = nil
    }
    #endif
}

// MARK: - Private Formatting

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
private extension ArticleEditorViewModel {
    func performToggleBold() {
        guard let idx = focusedBlockIndex, let context = fontResolutionContext else { return }
        let isBold = isSelectionBold
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            typingBoldOverride = !isBold
        case let .ranges(ranges):
            let newBold = !isBold
            let italic = selectedIsItalic
            let design = selectedDesign
            let fontName = selectedFontName
            blocks[idx].text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    for item in mt[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                        let resolved = item.font.resolve(in: context)
                        mt[item.run].font = fontName != nil
                            ? RichTextEditorViewModel.resolveCustomFont(name: fontName!, size: resolved.pointSize, bold: newBold, italic: italic)
                            : RichTextEditorViewModel.resolveSystemFont(size: resolved.pointSize, bold: newBold, italic: italic, design: design)
                    }
                }
            }
        }
    }

    func performToggleItalic() {
        guard let idx = focusedBlockIndex, let context = fontResolutionContext else { return }
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            let current = typingItalicOverride ?? selectedIsItalic
            typingItalicOverride = !current
            selectedIsItalic = !current
        case let .ranges(ranges):
            let newItalic = !selectedIsItalic
            selectedIsItalic = newItalic
            let design = selectedDesign
            let fontName = selectedFontName
            blocks[idx].text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    for item in mt[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                        let resolved = item.font.resolve(in: context)
                        mt[item.run].font = fontName != nil
                            ? RichTextEditorViewModel.resolveCustomFont(name: fontName!, size: resolved.pointSize, bold: resolved.isBold, italic: newItalic)
                            : RichTextEditorViewModel.resolveSystemFont(size: resolved.pointSize, bold: resolved.isBold, italic: newItalic, design: design)
                    }
                }
            }
        }
    }

    func performToggleUnderline() {
        guard let idx = focusedBlockIndex else { return }
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            typingUnderlineOverride = !isSelectionUnderlined
        case let .ranges(ranges):
            let newStyle: Text.LineStyle? = isSelectionUnderlined ? nil : .init(pattern: .solid)
            blocks[idx].text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].underlineStyle = newStyle
                }
            }
        }
    }

    func performToggleStrikethrough() {
        guard let idx = focusedBlockIndex else { return }
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            typingStrikethroughOverride = !isSelectionStrikethrough
        case let .ranges(ranges):
            let newStyle: Text.LineStyle? = isSelectionStrikethrough ? nil : .init(pattern: .solid)
            blocks[idx].text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].strikethroughStyle = newStyle
                }
            }
        }
    }

    func performApplyHighlight(_ color: Color) {
        guard let idx = focusedBlockIndex else { return }
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            typingHighlightColor = color
            typingRemoveHighlight = false
        case let .ranges(ranges):
            blocks[idx].text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].backgroundColor = color
                }
            }
        }
    }

    func performRemoveHighlight() {
        guard let idx = focusedBlockIndex else { return }
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            typingHighlightColor = nil
            typingRemoveHighlight = true
        case let .ranges(ranges):
            blocks[idx].text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].backgroundColor = nil
                }
            }
        }
    }

    func performApplyTextStyle(_ style: Font.TextStyle) {
        guard let idx = focusedBlockIndex, let context = fontResolutionContext else { return }
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            typingTextStyleOverride = style
        case let .ranges(ranges):
            let italic = selectedIsItalic
            let design = selectedDesign
            let customFontName = selectedFontName
            let stylePointSize = Font.system(style).resolve(in: context).pointSize
            blocks[idx].text.transform(updating: &textSelection) { mt in
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

    func performApplyLink(_ url: URL?) {
        guard let idx = focusedBlockIndex else { return }
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            typingLinkURL = url
            typingRemoveLink = (url == nil)
        case let .ranges(ranges):
            blocks[idx].text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    mt[range].link = url
                }
            }
        }
    }

    func performApplyTypingOverrides(blockId: UUID, oldText: AttributedString, newText: AttributedString) {
        guard let idx = blocks.firstIndex(where: { $0.id == blockId }) else { return }
        let addedCount = newText.characters.count - oldText.characters.count
        guard hasTypingOverrides, addedCount > 0,
              case let .insertionPoint(cursor) = textSelection.indices(in: newText)
        else {
            isApplyingOverrides = true
            blocks[idx].text = newText
            isApplyingOverrides = false
            return
        }

        var modified = newText
        var startIdx = cursor
        for _ in 0 ..< addedCount {
            startIdx = modified.characters.index(before: startIdx)
        }
        let range = startIdx ..< cursor

        let needsFontOverride = typingBoldOverride != nil || typingItalicOverride != nil
            || typingTextStyleOverride != nil || typingFontActive
        if needsFontOverride, let context = fontResolutionContext {
            let boldOverride = typingBoldOverride
            let italic = typingItalicOverride ?? selectedIsItalic
            let design = selectedDesign
            let fontName = selectedFontName
            let styleOverride = typingTextStyleOverride
            let hasFontTraitOverride = typingBoldOverride != nil || typingItalicOverride != nil
            for item in modified[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                let resolved = item.font.resolve(in: context)
                let bold = boldOverride ?? resolved.isBold
                let size: CGFloat = if let styleOverride {
                    Font.system(styleOverride).resolve(in: context).pointSize
                } else {
                    resolved.pointSize
                }
                modified[item.run].font = if let fontName {
                    hasFontTraitOverride
                        ? RichTextEditorViewModel.resolveCustomFont(name: fontName, size: size, bold: bold, italic: italic)
                        : (italic ? Font.custom(fontName, size: size).italic() : Font.custom(fontName, size: size))
                } else {
                    RichTextEditorViewModel.resolveSystemFont(size: size, bold: bold, italic: italic, design: design)
                }
            }
        }
        if let underlineOverride = typingUnderlineOverride {
            modified[range].underlineStyle = underlineOverride ? .init(pattern: .solid) : nil
        }
        if let strikethroughOverride = typingStrikethroughOverride {
            modified[range].strikethroughStyle = strikethroughOverride ? .init(pattern: .solid) : nil
        }
        if let highlightColor = typingHighlightColor {
            modified[range].backgroundColor = highlightColor
        } else if typingRemoveHighlight {
            modified[range].backgroundColor = nil
        }
        if let linkURL = typingLinkURL {
            modified[range].link = linkURL
        } else if typingRemoveLink {
            modified[range].link = nil
        }

        isApplyingOverrides = true
        blocks[idx].text = modified
        isApplyingOverrides = false
    }

    func performApplyFont(fontName: String?, design: Font.Design) {
        guard let idx = focusedBlockIndex, let context = fontResolutionContext else { return }
        selectedFontName = fontName
        selectedDesign = design
        switch textSelection.indices(in: blocks[idx].text) {
        case .insertionPoint:
            selectedFontName = fontName
            selectedDesign = design
            typingFontActive = true
        case let .ranges(ranges):
            let italic = selectedIsItalic
            blocks[idx].text.transform(updating: &textSelection) { mt in
                for range in ranges.ranges {
                    for item in mt[range].runs.map({ (run: $0.range, font: $0.font ?? .body) }) {
                        let resolved = item.font.resolve(in: context)
                        let base: Font = fontName != nil
                            ? Font.custom(fontName!, size: resolved.pointSize)
                            : Font.system(size: resolved.pointSize, weight: resolved.isBold ? .bold : .regular, design: design)
                        mt[item.run].font = italic ? base.italic() : base
                    }
                }
            }
        }
    }
}
