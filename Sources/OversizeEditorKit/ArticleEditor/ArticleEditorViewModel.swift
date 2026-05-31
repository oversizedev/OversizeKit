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
    var isFocusTransferring: Bool = false
    #if canImport(UIKit)
    var pickerSelectedImage: UIImage?
    weak var focusedTextView: UITextView?
    private var lastFocusedId: UUID?
    @ObservationIgnored private var textViewRegistry: [UUID: UITextView] = [:]
    #endif

    // MARK: - Undo/Redo State

    var canUndo: Bool = false
    var canRedo: Bool = false

    weak var undoManager: UndoManager? {
        didSet {
            observeUndoManager()
            #if canImport(UIKit)
            for textView in textViewRegistry.values {
                (textView as? SharedUndoTextView)?.sharedUndoManager = undoManager
            }
            #endif
        }
    }

    @ObservationIgnored private nonisolated(unsafe) var undoObservations: [NSObjectProtocol] = []

    // MARK: - Selection State

    #if canImport(UIKit)
    var currentSelectedRange: NSRange = .init(location: 0, length: 0)
    var currentTypingAttributes: [NSAttributedString.Key: Any] = [:]
    #endif

    // MARK: - Formatting State

    var isFontStyleSelection: Bool = false
    var selectedTextStyle: Font.TextStyle = .body {
        didSet {
            guard oldValue != selectedTextStyle else { return }
            #if canImport(UIKit)
            performApplyTextStyle(selectedTextStyle)
            #endif
        }
    }

    var selectedDesign: Font.Design = .default
    var selectedFontName: String?
    var linkURL: URL?
    var sheet: Sheet?

    // MARK: - Action

    enum Action {
        case undo
        case redo
        case insertBlock(ArticleBlock)
        case removeBlock(blockId: UUID)
        case moveBlocks(fromOffsets: IndexSet, toOffset: Int)
        case deleteOffsets(IndexSet)
        case insertImage
        #if canImport(UIKit)
        case imageSelected(UIImage?)
        #endif
        case pasteText
        case insertEmoji(String)
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
        case openEmojiPicker
        case applyLink(URL?)
        case applyFont(name: String?, design: Font.Design)
    }

    func send(_ action: Action) {
        switch action {
        case .undo:
            undoManager?.undo()
            updateUndoRedoState()
        case .redo:
            undoManager?.redo()
            updateUndoRedoState()
        case let .insertBlock(block):
            performInsertBlock(block)
        case let .removeBlock(blockId):
            if let idx = blocks.firstIndex(where: { $0.id == blockId }) {
                let block = blocks[idx]
                blocks.remove(at: idx)
                registerUndoForRemove(block, originalIdx: idx)
            }
        case let .moveBlocks(from, to):
            let snapshot = blocks
            blocks.move(fromOffsets: from, toOffset: to)
            let movedBlocks = blocks
            undoManager?.registerUndo(withTarget: self) { target in
                let current = target.blocks
                target.blocks = snapshot
                target.undoManager?.registerUndo(withTarget: target) { inner in
                    inner.blocks = movedBlocks
                }
                _ = current
            }
            updateUndoRedoState()
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
        case .pasteText:
            #if canImport(UIKit)
            performPasteText()
            #endif
        case let .insertEmoji(emoji):
            #if canImport(UIKit)
            performInsertEmoji(emoji)
            #endif
        case .toggleBold:
            #if canImport(UIKit)
            performToggleBold()
            #endif
        case .toggleItalic:
            #if canImport(UIKit)
            performToggleItalic()
            #endif
        case .toggleUnderline:
            #if canImport(UIKit)
            performToggleUnderline()
            #endif
        case .toggleStrikethrough:
            #if canImport(UIKit)
            performToggleStrikethrough()
            #endif
        case let .applyHighlight(color):
            #if canImport(UIKit)
            performApplyHighlight(color)
            #else
            _ = color
            #endif
        case .removeHighlight:
            #if canImport(UIKit)
            performRemoveHighlight()
            #endif
        case .toggleFontStyleSelection:
            isFontStyleSelection.toggle()
        case .openTextStylePicker:
            sheet = .textStylePicker
        case .openFontPicker:
            sheet = .fontPicker
        case .openLinkSheet:
            #if canImport(UIKit)
            linkURL = currentTypingAttributes[.link] as? URL
            #endif
            sheet = .link
        case .openEmojiPicker:
            sheet = .emojiPicker
        case let .applyLink(url):
            #if canImport(UIKit)
            performApplyLink(url)
            #else
            _ = url
            #endif
            sheet = nil
        case let .applyFont(name, design):
            #if canImport(UIKit)
            performApplyFont(fontName: name, design: design)
            #else
            selectedFontName = name
            selectedDesign = design
            #endif
        }
    }

    // MARK: - Focus

    func toggleFocus() {
        #if canImport(UIKit)
        if focusedId != nil {
            focusedId = nil
        } else {
            focusedId = lastFocusedId ?? blocks.first?.id
        }
        #endif
    }

    deinit {
        undoObservations.forEach { NotificationCenter.default.removeObserver($0) }
    }
}

// MARK: - Event Handlers

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension ArticleEditorViewModel {
    #if canImport(UIKit)
    func onTextChanged(_ text: NSAttributedString, blockId: UUID) {
        guard let idx = blocks.firstIndex(where: { $0.id == blockId }) else { return }
        blocks[idx].text = text
        updateUndoRedoState()
    }

    func onSelectionChanged(_ range: NSRange, typingAttributes: [NSAttributedString.Key: Any]) {
        currentSelectedRange = range
        currentTypingAttributes = typingAttributes
        if range.length > 0 {
            isFontStyleSelection = false
        }
    }

    func onReturn(blockId: UUID) {
        isFocusTransferring = true
        guard let idx = blocks.firstIndex(where: { $0.id == blockId }),
              let textView = focusedTextView else { return }
        let selectedRange = textView.selectedRange
        let fullText = textView.attributedText ?? NSAttributedString()
        let totalLength = fullText.length
        let cursorPosition = selectedRange.location

        let beforeText = cursorPosition > 0
            ? fullText.attributedSubstring(from: NSRange(location: 0, length: cursorPosition))
            : NSAttributedString()
        let afterStart = selectedRange.location + selectedRange.length
        let afterText = afterStart < totalLength
            ? fullText.attributedSubstring(from: NSRange(location: afterStart, length: totalLength - afterStart))
            : NSAttributedString()

        let newBlockType = focusedBlockContinuationType
        var newBlock = ArticleBlock(type: newBlockType)
        newBlock.text = afterText
        let newBlockId = newBlock.id

        registerUndoForSplit(blockId: blockId, originalText: fullText, beforeText: beforeText, newBlockId: newBlockId, newBlockType: newBlockType)

        blocks[idx].text = beforeText
        withAnimation {
            blocks.insert(newBlock, at: idx + 1)
        }
        focusedId = newBlockId
    }

    func onDeleteWhenEmpty(blockId: UUID) {
        guard let idx = blocks.firstIndex(where: { $0.id == blockId }),
              idx > 0 else { return }
        let block = blocks[idx]
        let previousId = blocks[..<idx]
            .last(where: { $0.type == .text || $0.type == .quote || $0.type == .list || $0.type == .numberedList })?.id
        if let prevId = previousId, let prevTextView = textViewRegistry[prevId] {
            isFocusTransferring = true
            prevTextView.becomeFirstResponder()
        }
        blocks.remove(at: idx)
        textViewRegistry.removeValue(forKey: blockId)
        focusedId = previousId
        registerUndoForRemove(block, originalIdx: idx)
    }

    func registerTextView(_ textView: UITextView, for blockId: UUID) {
        textViewRegistry[blockId] = textView
        (textView as? SharedUndoTextView)?.sharedUndoManager = undoManager
    }

    func onFocused(blockId: UUID, textView: UITextView) {
        isFocusTransferring = false
        focusedId = blockId
        lastFocusedId = blockId
        focusedTextView = textView
        currentTypingAttributes = textView.typingAttributes
        currentSelectedRange = textView.selectedRange
        updateUndoRedoState()
    }

    func onBlurred(from textView: UITextView, blockId: UUID) {
        guard sheet == nil else { return }
        guard blockId == focusedId, textView === focusedTextView else { return }
        focusedId = nil
        focusedTextView = nil
        currentSelectedRange = NSRange(location: 0, length: 0)
        currentTypingAttributes = [:]
        updateUndoRedoState()
    }
    #endif
}

// MARK: - Sheet

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension ArticleEditorViewModel {
    enum Sheet: Identifiable {
        case textStylePicker, fontPicker, link, photoPicker, emojiPicker

        var id: String {
            switch self {
            case .textStylePicker: "textStylePicker"
            case .fontPicker: "fontPicker"
            case .link: "link"
            case .photoPicker: "photoPicker"
            case .emojiPicker: "emojiPicker"
            }
        }
    }
}

// MARK: - Computed State

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension ArticleEditorViewModel {
    var hasSelection: Bool {
        #if canImport(UIKit)
        currentSelectedRange.length > 0
        #else
        false
        #endif
    }

    var isSelectionBold: Bool {
        #if canImport(UIKit)
        (currentTypingAttributes[.font] as? UIFont)?.isBold ?? false
        #else
        false
        #endif
    }

    var isEffectiveItalic: Bool {
        #if canImport(UIKit)
        (currentTypingAttributes[.font] as? UIFont)?.isItalic ?? false
        #else
        false
        #endif
    }

    var isSelectionUnderlined: Bool {
        #if canImport(UIKit)
        guard let value = currentTypingAttributes[.underlineStyle] as? Int else { return false }
        return value != 0
        #else
        false
        #endif
    }

    var isSelectionStrikethrough: Bool {
        #if canImport(UIKit)
        guard let value = currentTypingAttributes[.strikethroughStyle] as? Int else { return false }
        return value != 0
        #else
        false
        #endif
    }

    var hasSelectionLink: Bool {
        #if canImport(UIKit)
        currentTypingAttributes[.link] != nil
        #else
        false
        #endif
    }

    var selectionHighlightColor: Color? {
        #if canImport(UIKit)
        guard let uiColor = currentTypingAttributes[.backgroundColor] as? UIColor else { return nil }
        return Color(uiColor: uiColor)
        #else
        nil
        #endif
    }

    var selectedTextStyleName: String {
        selectedTextStyle.displayName
    }

    var isItalicSupported: Bool {
        true
    }

    var focusedBlockContinuationType: BlockType {
        guard let idx = focusedBlockIndex else { return .text }
        switch blocks[idx].type {
        case .list: return .list
        case .numberedList: return .numberedList
        default: return .text
        }
    }

    private var focusedBlockIndex: Int? {
        blocks.firstIndex(where: { $0.id == focusedId })
    }
}

// MARK: - Undo Manager

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
private extension ArticleEditorViewModel {
    func updateUndoRedoState() {
        canUndo = undoManager?.canUndo ?? false
        canRedo = undoManager?.canRedo ?? false
    }

    func observeUndoManager() {
        undoObservations.forEach { NotificationCenter.default.removeObserver($0) }
        guard let um = undoManager else {
            canUndo = false
            canRedo = false
            return
        }
        canUndo = um.canUndo
        canRedo = um.canRedo
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
}

// MARK: - Private Block Operations

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
private extension ArticleEditorViewModel {
    func performInsertBlock(_ newBlock: ArticleBlock) {
        let insertIdx: Int
        if let idx = blocks.firstIndex(where: { $0.id == focusedId }) {
            insertIdx = idx + 1
            blocks.insert(newBlock, at: insertIdx)
        } else {
            insertIdx = blocks.count
            blocks.append(newBlock)
        }
        if newBlock.type == .text || newBlock.type == .quote || newBlock.type == .list || newBlock.type == .numberedList {
            focusedId = newBlock.id
        }
        registerUndoForInsert(newBlock, at: insertIdx)
    }

    func registerUndoForSplit(blockId: UUID, originalText: NSAttributedString, beforeText: NSAttributedString, newBlockId: UUID, newBlockType: BlockType) {
        undoManager?.registerUndo(withTarget: self) { target in
            let afterText: NSAttributedString
            if let newIdx = target.blocks.firstIndex(where: { $0.id == newBlockId }) {
                afterText = target.blocks[newIdx].text
                target.blocks.remove(at: newIdx)
            } else {
                afterText = NSAttributedString()
            }
            if let currentIdx = target.blocks.firstIndex(where: { $0.id == blockId }) {
                target.blocks[currentIdx].text = originalText
                #if canImport(UIKit)
                target.focusedTextView?.attributedText = originalText
                #endif
            }
            target.focusedId = blockId
            target.registerUndoForMergeThenSplit(blockId: blockId, originalNewBlockId: newBlockId, originalText: originalText, beforeText: beforeText, afterText: afterText, newBlockType: newBlockType)
        }
    }

    func registerUndoForMergeThenSplit(blockId: UUID, originalNewBlockId: UUID, originalText: NSAttributedString, beforeText: NSAttributedString, afterText: NSAttributedString, newBlockType: BlockType) {
        undoManager?.registerUndo(withTarget: self) { target in
            guard let currentIdx = target.blocks.firstIndex(where: { $0.id == blockId }) else { return }
            let newBlock = ArticleBlock(id: originalNewBlockId, type: newBlockType, text: afterText)
            target.blocks[currentIdx].text = beforeText
            target.blocks.insert(newBlock, at: currentIdx + 1)
            target.focusedId = originalNewBlockId
            target.registerUndoForSplit(blockId: blockId, originalText: originalText, beforeText: beforeText, newBlockId: originalNewBlockId, newBlockType: newBlockType)
        }
    }

    func registerUndoForInsert(_ block: ArticleBlock, at idx: Int) {
        undoManager?.registerUndo(withTarget: self) { target in
            if let currentIdx = target.blocks.firstIndex(where: { $0.id == block.id }) {
                let currentBlock = target.blocks[currentIdx]
                if target.focusedId == block.id {
                    target.focusedId = nil
                }
                target.blocks.remove(at: currentIdx)
                target.registerUndoForRemove(currentBlock, originalIdx: currentIdx)
            }
        }
    }

    func registerUndoForRemove(_ block: ArticleBlock, originalIdx: Int) {
        undoManager?.registerUndo(withTarget: self) { target in
            let safeIdx = min(originalIdx, target.blocks.count)
            target.blocks.insert(block, at: safeIdx)
            if block.type == .text || block.type == .quote || block.type == .list || block.type == .numberedList {
                target.focusedId = block.id
            }
            target.registerUndoForInsert(block, at: safeIdx)
        }
    }

    #if canImport(UIKit)
    func performImageSelected(_ image: UIImage?) {
        guard let image, let data = image.jpegData(compressionQuality: 0.8) else { return }
        let newBlock = ArticleBlock(imageData: data)
        performInsertBlock(newBlock)
        pickerSelectedImage = nil
    }

    func performPasteText() {
        guard let textView = focusedTextView,
              let pasteString = UIPasteboard.general.string,
              !pasteString.isEmpty,
              let idx = focusedBlockIndex else { return }
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        let pastedAttr = NSAttributedString(string: pasteString, attributes: textView.typingAttributes)
        mutable.replaceCharacters(in: currentSelectedRange, with: pastedAttr)
        let newLocation = currentSelectedRange.location + (pasteString as NSString).length
        applyMutable(mutable, to: textView, blockIndex: idx)
        let safeLocation = min(newLocation, mutable.length)
        textView.selectedRange = NSRange(location: safeLocation, length: 0)
        currentSelectedRange = textView.selectedRange
    }

    func performInsertEmoji(_ emoji: String) {
        guard let textView = focusedTextView,
              let idx = focusedBlockIndex else { return }
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        let emojiAttr = NSAttributedString(string: emoji, attributes: textView.typingAttributes)
        mutable.replaceCharacters(in: currentSelectedRange, with: emojiAttr)
        let newLocation = currentSelectedRange.location + (emoji as NSString).length
        applyMutable(mutable, to: textView, blockIndex: idx)
        textView.selectedRange = NSRange(location: min(newLocation, mutable.length), length: 0)
        currentSelectedRange = textView.selectedRange
    }
    #endif
}

// MARK: - Private Formatting

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
private extension ArticleEditorViewModel {
    #if canImport(UIKit)
    func performToggleBold() {
        guard let textView = focusedTextView, let idx = focusedBlockIndex else { return }
        let isBold = isSelectionBold

        if currentSelectedRange.length == 0 {
            var attrs = textView.typingAttributes
            let current = (attrs[.font] as? UIFont) ?? .preferredFont(forTextStyle: .body)
            attrs[.font] = isBold ? current.withoutTrait(.traitBold) : current.withTrait(.traitBold)
            textView.typingAttributes = attrs
            currentTypingAttributes = attrs
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.enumerateAttribute(.font, in: currentSelectedRange) { value, range, _ in
                let font = (value as? UIFont) ?? .preferredFont(forTextStyle: .body)
                mutable.addAttribute(.font, value: isBold ? font.withoutTrait(.traitBold) : font.withTrait(.traitBold), range: range)
            }
            applyMutable(mutable, to: textView, blockIndex: idx)
        }
    }

    func performToggleItalic() {
        guard let textView = focusedTextView, let idx = focusedBlockIndex else { return }
        let isItalic = isEffectiveItalic

        if currentSelectedRange.length == 0 {
            var attrs = textView.typingAttributes
            let current = (attrs[.font] as? UIFont) ?? .preferredFont(forTextStyle: .body)
            attrs[.font] = isItalic ? current.withoutTrait(.traitItalic) : current.withTrait(.traitItalic)
            textView.typingAttributes = attrs
            currentTypingAttributes = attrs
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.enumerateAttribute(.font, in: currentSelectedRange) { value, range, _ in
                let font = (value as? UIFont) ?? .preferredFont(forTextStyle: .body)
                mutable.addAttribute(.font, value: isItalic ? font.withoutTrait(.traitItalic) : font.withTrait(.traitItalic), range: range)
            }
            applyMutable(mutable, to: textView, blockIndex: idx)
        }
    }

    func performToggleUnderline() {
        guard let textView = focusedTextView, let idx = focusedBlockIndex else { return }
        let isUnderlined = isSelectionUnderlined

        if currentSelectedRange.length == 0 {
            var attrs = textView.typingAttributes
            attrs[.underlineStyle] = isUnderlined ? 0 : NSUnderlineStyle.single.rawValue
            textView.typingAttributes = attrs
            currentTypingAttributes = attrs
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.addAttribute(.underlineStyle, value: isUnderlined ? 0 : NSUnderlineStyle.single.rawValue, range: currentSelectedRange)
            applyMutable(mutable, to: textView, blockIndex: idx)
        }
    }

    func performToggleStrikethrough() {
        guard let textView = focusedTextView, let idx = focusedBlockIndex else { return }
        let isStrikethrough = isSelectionStrikethrough

        if currentSelectedRange.length == 0 {
            var attrs = textView.typingAttributes
            attrs[.strikethroughStyle] = isStrikethrough ? 0 : NSUnderlineStyle.single.rawValue
            textView.typingAttributes = attrs
            currentTypingAttributes = attrs
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.addAttribute(.strikethroughStyle, value: isStrikethrough ? 0 : NSUnderlineStyle.single.rawValue, range: currentSelectedRange)
            applyMutable(mutable, to: textView, blockIndex: idx)
        }
    }

    func performApplyHighlight(_ color: Color) {
        guard let textView = focusedTextView, let idx = focusedBlockIndex else { return }
        let uiColor = UIColor(color)

        if currentSelectedRange.length == 0 {
            var attrs = textView.typingAttributes
            attrs[.backgroundColor] = uiColor
            textView.typingAttributes = attrs
            currentTypingAttributes = attrs
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.addAttribute(.backgroundColor, value: uiColor, range: currentSelectedRange)
            applyMutable(mutable, to: textView, blockIndex: idx)
        }
    }

    func performRemoveHighlight() {
        guard let textView = focusedTextView, let idx = focusedBlockIndex else { return }

        if currentSelectedRange.length == 0 {
            var attrs = textView.typingAttributes
            attrs.removeValue(forKey: .backgroundColor)
            textView.typingAttributes = attrs
            currentTypingAttributes = attrs
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.removeAttribute(.backgroundColor, range: currentSelectedRange)
            applyMutable(mutable, to: textView, blockIndex: idx)
        }
    }

    func performApplyTextStyle(_ style: Font.TextStyle) {
        guard let textView = focusedTextView, let idx = focusedBlockIndex else { return }
        let targetUIStyle = uiFontTextStyle(from: style)
        let baseFont = UIFont.preferredFont(forTextStyle: targetUIStyle)

        if currentSelectedRange.length == 0 {
            var attrs = textView.typingAttributes
            let current = (attrs[.font] as? UIFont) ?? .preferredFont(forTextStyle: .body)
            var newFont = UIFont(descriptor: baseFont.fontDescriptor, size: baseFont.pointSize)
            if current.isBold { newFont = newFont.withTrait(.traitBold) }
            if current.isItalic { newFont = newFont.withTrait(.traitItalic) }
            attrs[.font] = newFont
            textView.typingAttributes = attrs
            currentTypingAttributes = attrs
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.enumerateAttribute(.font, in: currentSelectedRange) { value, range, _ in
                let current = (value as? UIFont) ?? .preferredFont(forTextStyle: .body)
                var newFont = baseFont
                if current.isBold { newFont = newFont.withTrait(.traitBold) }
                if current.isItalic { newFont = newFont.withTrait(.traitItalic) }
                mutable.addAttribute(.font, value: newFont, range: range)
            }
            applyMutable(mutable, to: textView, blockIndex: idx)
        }
    }

    func performApplyLink(_ url: URL?) {
        guard let idx = focusedBlockIndex else { return }

        if let textView = focusedTextView {
            if currentSelectedRange.length == 0 {
                var attrs = textView.typingAttributes
                if let url { attrs[.link] = url } else { attrs.removeValue(forKey: .link) }
                textView.typingAttributes = attrs
                currentTypingAttributes = attrs
            } else {
                let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
                if let url {
                    mutable.addAttribute(.link, value: url, range: currentSelectedRange)
                } else {
                    mutable.removeAttribute(.link, range: currentSelectedRange)
                }
                applyMutable(mutable, to: textView, blockIndex: idx)
            }
        } else if currentSelectedRange.length > 0 {
            let mutable = NSMutableAttributedString(attributedString: blocks[idx].text)
            if let url {
                mutable.addAttribute(.link, value: url, range: currentSelectedRange)
            } else {
                mutable.removeAttribute(.link, range: currentSelectedRange)
            }
            blocks[idx].text = mutable
        }
    }

    func performApplyFont(fontName: String?, design: Font.Design) {
        guard let textView = focusedTextView, let idx = focusedBlockIndex else { return }
        selectedFontName = fontName
        selectedDesign = design

        if currentSelectedRange.length == 0 {
            var attrs = textView.typingAttributes
            let current = (attrs[.font] as? UIFont) ?? .preferredFont(forTextStyle: .body)
            attrs[.font] = resolvedFont(name: fontName, design: design, size: current.pointSize, bold: current.isBold, italic: current.isItalic)
            textView.typingAttributes = attrs
            currentTypingAttributes = attrs
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.enumerateAttribute(.font, in: currentSelectedRange) { value, range, _ in
                let current = (value as? UIFont) ?? .preferredFont(forTextStyle: .body)
                mutable.addAttribute(.font, value: resolvedFont(name: fontName, design: design, size: current.pointSize, bold: current.isBold, italic: current.isItalic), range: range)
            }
            applyMutable(mutable, to: textView, blockIndex: idx)
        }
    }

    func applyMutable(_ mutable: NSMutableAttributedString, to textView: UITextView, blockIndex idx: Int) {
        let savedRange = textView.selectedRange
        let previousText = NSAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        let blockId = blocks[idx].id
        textView.attributedText = mutable
        let safeRange = NSRange(location: min(savedRange.location, mutable.length), length: min(savedRange.length, max(0, mutable.length - savedRange.location)))
        textView.selectedRange = safeRange
        blocks[idx].text = mutable
        registerUndoForTextMutation(blockId: blockId, restoreText: previousText)
    }

    func registerUndoForTextMutation(blockId: UUID, restoreText: NSAttributedString) {
        undoManager?.registerUndo(withTarget: self) { target in
            guard let currentIdx = target.blocks.firstIndex(where: { $0.id == blockId }),
                  let textView = target.textViewRegistry[blockId] else { return }
            let currentText = NSAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
            let currentRange = textView.selectedRange
            textView.attributedText = restoreText
            textView.selectedRange = NSRange(location: min(currentRange.location, restoreText.length), length: 0)
            target.blocks[currentIdx].text = restoreText
            target.registerUndoForTextMutation(blockId: blockId, restoreText: currentText)
        }
    }

    func resolvedFont(name: String?, design: Font.Design, size: CGFloat, bold: Bool, italic: Bool) -> UIFont {
        var font: UIFont = if let name {
            UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
        } else {
            applyFontDesign(design, to: .systemFont(ofSize: size))
        }
        if bold { font = font.withTrait(.traitBold) }
        if italic { font = font.withTrait(.traitItalic) }
        return font
    }

    func applyFontDesign(_ design: Font.Design, to font: UIFont) -> UIFont {
        switch design {
        case .monospaced:
            let weight: UIFont.Weight = font.isBold ? .bold : .regular
            let mono = UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: weight)
            return font.isItalic ? mono.withTrait(.traitItalic) : mono
        case .rounded:
            if let descriptor = font.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: 0)
            }
            return font
        case .serif:
            if let descriptor = font.fontDescriptor.withDesign(.serif) {
                return UIFont(descriptor: descriptor, size: 0)
            }
            return font
        default:
            return font
        }
    }

    func uiFontTextStyle(from textStyle: Font.TextStyle) -> UIFont.TextStyle {
        switch textStyle {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
    #endif
}

// MARK: - UIFont Helpers

#if canImport(UIKit)
private extension UIFont {
    func withTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert(trait)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func withoutTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove(trait)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }

    var isBold: Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    var isItalic: Bool {
        fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}
#endif
