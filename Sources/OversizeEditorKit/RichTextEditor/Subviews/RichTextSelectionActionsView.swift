//
// Copyright © 2024 Alexander Romanov
// RichTextSelectionActionsView.swift, created on 20.05.2026
//

import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct RichTextSelectionActionsView: View {
    enum Action {
        case toggleBold
        case toggleItalic
        case toggleUnderline
        case toggleStrikethrough
        case openFontPicker
        case openTextStylePicker
        case openLinkSheet
        case toggleFontStyleSelection
        case highlight(RichTextHighlightMenuView.Action)
    }

    private let hasSelection: Bool
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

    init(
        hasSelection: Bool,
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
        if !hasSelection {
            Button { onAction(.toggleFontStyleSelection) } label: {
                Icon(Image.Base.chevronLeft)
            }
            .buttonStyle(.bar)
            .barItem(namespace: namespace)
        }

        // MARK: - Style

        #if os(iOS) || os(macOS)
        Button {
            onAction(.openTextStylePicker)
        } label: {
            Text(selectedTextStyleName)
                .headline(.bold)
                .foregroundStyle(Color.onSurfacePrimary)
                .padding(.leading, hasSelection ? .medium : .xxSmall)
                .padding(.trailing, .small)
        }
        .matchedTransitionSource(id: "textStylePicker", in: namespace)
        .barItem(namespace: namespace)

        Separator(.vertical)
            .lineWidth(3)
            .frame(height: .regular)
        #endif

        // MARK: - Bold

        Button { onAction(.toggleBold) } label: {
            Icon(Image.Editor.boldType)
        }
        .buttonStyle(.barToggle(isOn: isSelectionBold))
        .barItem(namespace: namespace)

        // MARK: - Italic

        if isItalicSupported {
            Button { onAction(.toggleItalic) } label: {
                Icon(Image.Editor.italic)
            }
            .buttonStyle(.barToggle(isOn: isEffectiveItalic))
            .barItem(namespace: namespace)
        }

        // MARK: - Underline

        Button { onAction(.toggleUnderline) } label: {
            Icon(Image.Editor.underline)
        }
        .buttonStyle(.barToggle(isOn: isSelectionUnderlined))
        .barItem(namespace: namespace)

        // MARK: - Strikethrough

        Button { onAction(.toggleStrikethrough) } label: {
            Icon(Image.Editor.strikethrough)
        }
        .buttonStyle(.barToggle(isOn: isSelectionStrikethrough))
        .barItem(namespace: namespace)

        // MARK: - Font Family

        #if os(iOS) || os(macOS)
        Button { onAction(.openFontPicker) } label: {
            Icon(Image.Editor.searchFont)
        }
        .matchedTransitionSource(id: "fontPicker", in: namespace)
        .buttonStyle(.bar)
        .barItem(namespace: namespace)

        // MARK: - Highlight

        RichTextHighlightMenuView(
            currentHighlightColor: selectionHighlightColor,
            namespace: namespace
        ) { action in
            onAction(.highlight(action))
        }

        // MARK: - Link

        Button { onAction(.openLinkSheet) } label: {
            Icon(Image.Base.link)
        }
        .buttonStyle(.barToggle(isOn: hasSelectionLink))
        .barItem(namespace: namespace)
        #endif
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @Namespace var namespace
    NavigationStack {
        RichTextSelectionActionsView(
            hasSelection: true,
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
}
