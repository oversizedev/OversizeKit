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
            Button {
                onAction(.toggleFontStyleSelection)
            } label: {
                Icon(Image.Base.chevronLeft)
                    .padding(.init(top: .xSmall, leading: .xSmall, bottom: .xSmall, trailing: .zero))
            }
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
        #if os(iOS)
        .matchedTransitionSource(id: "textStylePicker", in: namespace)
        #endif
        .barItem(namespace: namespace)

        Separator(.vertical)
            .lineWidth(3)
            .frame(height: .regular)
        #endif

        // MARK: - Bold

        Button {
            onAction(.toggleBold)
        } label: {
            Icon(Image.Editor.boldType)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(isSelectionBold ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Italic

        if isItalicSupported {
            Button {
                onAction(.toggleItalic)
            } label: {
                Icon(Image.Editor.italic)
                    .padding(.xxSmall)
                    .background(Circle().fillSurfaceSecondary().opacity(isEffectiveItalic ? 1 : 0))
                    .padding(.xxxSmall)
            }
            .barItem(namespace: namespace)
        }

        // MARK: - Underline

        Button {
            onAction(.toggleUnderline)
        } label: {
            Icon(Image.Editor.underline)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(isSelectionUnderlined ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Strikethrough

        Button {
            onAction(.toggleStrikethrough)
        } label: {
            Icon(Image.Editor.strikethrough)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(isSelectionStrikethrough ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Font Family

        #if os(iOS) || os(macOS)
        Button {
            onAction(.openFontPicker)
        } label: {
            Icon(Image.Editor.searchFont)
                .padding(.xSmall)
        }
        #if os(iOS)
        .matchedTransitionSource(id: "fontPicker", in: namespace)
        #endif
        .barItem(namespace: namespace)

        // MARK: - Highlight

        RichTextHighlightMenuView(
            currentHighlightColor: selectionHighlightColor,
            namespace: namespace
        ) { action in
            onAction(.highlight(action))
        }

        // MARK: - Link

        Button {
            onAction(.openLinkSheet)
        } label: {
            Icon(Image.Base.link)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(hasSelectionLink ? 1 : 0))
                .padding(.xxxSmall)
        }
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
