//
// Copyright © 2024 Alexander Romanov
// ArticleBottomBar.swift, created on 03.03.2024
//

import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct ArticleBottomBar: View {
    enum Action {
        case undo
        case redo
        case insertImage
        case insertQuote
        case insertList
        case insertNumberedList
        case insertSeparator
        case insertLink
        case pasteText
        case openEmojiPicker
        case toggleBold
        case toggleItalic
        case toggleUnderline
        case toggleStrikethrough
        case applyHighlight(Color)
        case removeHighlight
        case openFontPicker
        case openTextStylePicker
        case openLinkSheet
        case toggleFontStyleSelection
        case toggleFocus
    }

    private let hasSelection: Bool
    private let isFontStyleSelection: Bool
    private let isFocus: Bool
    private let canUndo: Bool
    private let canRedo: Bool
    private let isSelectionBold: Bool
    private let isEffectiveItalic: Bool
    private let isSelectionUnderlined: Bool
    private let isSelectionStrikethrough: Bool
    private let isItalicSupported: Bool
    private let selectedTextStyleName: String
    private let hasSelectionLink: Bool
    private let selectionHighlightColor: Color?
    private let namespace: Namespace.ID
    private let onAction: (Action) -> Void

    @State private var isScrollInteracting = false

    init(
        hasSelection: Bool,
        isFontStyleSelection: Bool,
        isFocus: Bool,
        canUndo: Bool,
        canRedo: Bool,
        isSelectionBold: Bool,
        isEffectiveItalic: Bool,
        isSelectionUnderlined: Bool,
        isSelectionStrikethrough: Bool,
        isItalicSupported: Bool,
        selectedTextStyleName: String,
        hasSelectionLink: Bool,
        selectionHighlightColor: Color?,
        namespace: Namespace.ID,
        onAction: @escaping (Action) -> Void
    ) {
        self.hasSelection = hasSelection
        self.isFontStyleSelection = isFontStyleSelection
        self.isFocus = isFocus
        self.canUndo = canUndo
        self.canRedo = canRedo
        self.isSelectionBold = isSelectionBold
        self.isEffectiveItalic = isEffectiveItalic
        self.isSelectionUnderlined = isSelectionUnderlined
        self.isSelectionStrikethrough = isSelectionStrikethrough
        self.isItalicSupported = isItalicSupported
        self.selectedTextStyleName = selectedTextStyleName
        self.hasSelectionLink = hasSelectionLink
        self.selectionHighlightColor = selectionHighlightColor
        self.namespace = namespace
        self.onAction = onAction
    }

    var body: some View {
        GlassEffectContainer(spacing: .zero) {
            HStack(spacing: .zero) {
                ScrollView(.horizontal) {
                    HStack(spacing: .zero) {
                        if hasSelection || isFontStyleSelection {
                            RichTextSelectionActionsView(
                                hasSelection: hasSelection,
                                isSelectionBold: isSelectionBold,
                                isEffectiveItalic: isEffectiveItalic,
                                isSelectionUnderlined: isSelectionUnderlined,
                                isSelectionStrikethrough: isSelectionStrikethrough,
                                isItalicSupported: isItalicSupported,
                                selectedTextStyleName: selectedTextStyleName,
                                hasSelectionLink: hasSelectionLink,
                                selectionHighlightColor: selectionHighlightColor,
                                namespace: namespace
                            ) { action in
                                switch action {
                                case .toggleBold: onAction(.toggleBold)
                                case .toggleItalic: onAction(.toggleItalic)
                                case .toggleUnderline: onAction(.toggleUnderline)
                                case .toggleStrikethrough: onAction(.toggleStrikethrough)
                                case .openFontPicker: onAction(.openFontPicker)
                                case .openTextStylePicker: onAction(.openTextStylePicker)
                                case .openLinkSheet: onAction(.openLinkSheet)
                                case .toggleFontStyleSelection: onAction(.toggleFontStyleSelection)
                                case let .highlight(highlightAction):
                                    switch highlightAction {
                                    case let .applyHighlight(color): onAction(.applyHighlight(color))
                                    case .removeHighlight: onAction(.removeHighlight)
                                    }
                                }
                            }
                            .transition(.scale(scale: 0.01, anchor: UnitPoint(x: 0.25, y: 0.5)).combined(with: .opacity))
                        } else {
                            insertionActions
                                .transition(.scale(scale: 0.01, anchor: UnitPoint(x: 0.25, y: 0.5)).combined(with: .opacity))
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onScrollPhaseChange { _, newPhase in isScrollInteracting = newPhase.isScrolling }
                .environment(\.barScrollInteracting, isScrollInteracting)

                Separator(.vertical)
                    .lineWidth(3)
                    .frame(height: .regular)

                Button { onAction(.toggleFocus) } label: {
                    Icon(isFocus ? Image.ComputerAndTV.keyboardCloseDown : Image.ComputerAndTV.keyboardOpenUp)
                }
                .buttonStyle(.bar)
                .glassEffectUnion(id: "bar", namespace: namespace)
            }
        }
        .glassEffect()
        .padding(.horizontal, .small)
        .padding(.vertical, .xSmall)
        .controlSize(.regular)
        .buttonStyle(.scale)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: hasSelection || isFontStyleSelection)
    }

    @ViewBuilder
    private var insertionActions: some View {
        if canUndo {
            RepeatingButton(action: { onAction(.undo) }) {
                Icon(Image.Arrow.reverseLeft)
            }
            .buttonStyle(.bar)
            .barItem(namespace: namespace)
            .padding(.leading, .xxSmall)
        }

        if canRedo {
            RepeatingButton(action: { onAction(.redo) }) {
                Icon(Image.Arrow.reverseRight)
            }
            .buttonStyle(.bar)
            .barItem(namespace: namespace)
            .padding(.leading, canUndo ? 0 : .xxSmall)
        }

        if canUndo || canRedo {
            Separator(.vertical)
                .lineWidth(3)
                .frame(height: .regular)
        }

        Button { onAction(.toggleFontStyleSelection) } label: {
            Icon(Image.Editor.titleCase)
        }
        .buttonStyle(.bar)
        .barItem(namespace: namespace)
        .padding(.leading, canUndo || canRedo ? 0 : .xxSmall)

        #if os(iOS)
        Button { onAction(.insertImage) } label: {
            Icon(Image.Base.picture2)
                .padding(.leading, .xxxSmall)
        }
        .buttonStyle(.bar)
        .barItem(namespace: namespace)
        #endif

        Button { onAction(.insertQuote) } label: {
            Icon(Image.Editor.creativeQuoteClose)
        }
        .buttonStyle(.bar)
        .barItem(namespace: namespace)

        Menu {
            Button { onAction(.insertSeparator) } label: {
                Label("Separator", systemImage: "minus")
            }
            .tint(Color.onSurfacePrimary)

            Button { onAction(.insertNumberedList) } label: {
                Label("Numbered List", systemImage: "list.number")
            }
            .tint(Color.onSurfacePrimary)

            Button { onAction(.insertList) } label: {
                Label("Bulleted List", systemImage: "list.bullet")
            }
            .tint(Color.onSurfacePrimary)

            Button { onAction(.openEmojiPicker) } label: {
                Label("Emoji", systemImage: "face.smiling")
            }
            .tint(Color.onSurfacePrimary)

        } label: {
            Icon(Image.Base.more)
                .iconColor(Color.onSurfacePrimary)
        }
        .buttonStyle(.bar)
        .barItem(namespace: namespace)

        Separator(.vertical)
            .lineWidth(3)
            .frame(height: .regular)

        Button { onAction(.pasteText) } label: {
            Icon(Image.Documentation.clipboard)
        }
        .buttonStyle(.bar)
        .barItem(namespace: namespace)
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @Namespace var namespace
    ArticleBottomBar(
        hasSelection: false,
        isFontStyleSelection: false,
        isFocus: true,
        canUndo: false,
        canRedo: false,
        isSelectionBold: false,
        isEffectiveItalic: false,
        isSelectionUnderlined: false,
        isSelectionStrikethrough: false,
        isItalicSupported: true,
        selectedTextStyleName: "Body",
        hasSelectionLink: false,
        selectionHighlightColor: nil,
        namespace: namespace
    ) { _ in }
}
