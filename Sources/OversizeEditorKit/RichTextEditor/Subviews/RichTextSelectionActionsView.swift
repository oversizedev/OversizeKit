//
// Copyright © 2024 Alexander Romanov
// RichTextSelectionActionsView.swift, created on 20.05.2026
//

import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct RichTextSelectionActionsView: View {
    @Binding var text: AttributedString
    var viewModel: RichTextEditorViewModel
    var namespace: Namespace.ID
    @Environment(\.fontResolutionContext) var fontResolutionContext

    var body: some View {
        if !viewModel.hasSelection(in: text) {
            Button {
                withAnimation(.interactiveSpring) {
                    viewModel.isFontStyleSelection.toggle()
                }
            } label: {
                Icon(Image.Base.chevronLeft)
                    .padding(.xSmall)
                    .padding(.leading, .xxxSmall)
            }
            .barItem(namespace: namespace)
        }

        // MARK: - Style

        #if os(iOS) || os(macOS)
        Button {
            viewModel.present(.textStylePicker)
        } label: {
            Text(viewModel.selectedTextStyle.displayName)
                .headline(.bold)
                .foregroundStyle(Color.onSurfacePrimary)
                .padding(.horizontal, .xSmall)
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
            text = applyingBoldToggle(to: text)
        } label: {
            Icon(Image.Editor.boldType)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(isSelectionBold ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Italic

        if viewModel.isItalicSupported {
            Button {
                text = applyingItalicToggle(to: text)
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
            var mutableText = text
            viewModel.toggleUnderline(text: &mutableText)
            text = mutableText
        } label: {
            Icon(Image.Editor.underline)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(viewModel.isSelectionUnderlined(in: text) ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Strikethrough

        Button {
            var mutableText = text
            viewModel.toggleStrikethrough(text: &mutableText)
            text = mutableText
        } label: {
            Icon(Image.Editor.strikethrough)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(viewModel.isSelectionStrikethrough(in: text) ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Font Family

        #if os(iOS) || os(macOS)
        Button {
            viewModel.present(.fontPicker)
        } label: {
            Icon(Image.Editor.searchFont)
                .padding(.xSmall)
        }
        #if os(iOS)
        .matchedTransitionSource(id: "fontPicker", in: namespace)
        #endif
        .barItem(namespace: namespace)
        #endif
        
#if os(iOS) || os(macOS)
RichTextHighlightMenuView(text: $text, viewModel: viewModel, namespace: namespace)
#endif

        // MARK: - Link

        #if os(iOS) || os(macOS)
        Button {
            viewModel.linkURLString = viewModel.selectionCurrentLink(in: text)?.absoluteString ?? ""
            viewModel.present(.link)
        } label: {
            Icon(Image.Base.link)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(viewModel.hasSelectionLink(in: text) ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)
        #endif

        // MARK: - Highlight


    }

    // MARK: - Font Helpers

    private var isSelectionBold: Bool {
        if case .insertionPoint = viewModel.textSelection.indices(in: text),
           let override = viewModel.typingBoldOverride { return override }
        let font = viewModel.textSelection.typingAttributes(in: text).font
        return (font ?? .default).resolve(in: fontResolutionContext).isBold
    }

    private var isEffectiveItalic: Bool {
        if case .insertionPoint = viewModel.textSelection.indices(in: text) {
            return viewModel.typingItalicOverride ?? viewModel.selectedIsItalic
        }
        return viewModel.selectedIsItalic
    }

    private func applyingBoldToggle(to text: AttributedString) -> AttributedString {
        switch viewModel.textSelection.indices(in: text) {
        case .insertionPoint:
            viewModel.toggleTypingBold(currentBold: isSelectionBold)
            return text
        case let .ranges(ranges):
            var mutableText = text
            let newBold = !isSelectionBold
            let italic = viewModel.selectedIsItalic
            let design = viewModel.selectedDesign
            let fontName = viewModel.selectedFontName
            mutableText.transform(updating: &viewModel.textSelection) { mt in
                for range in ranges.ranges {
                    let runs = mt[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                    for item in runs {
                        let resolved = item.font.resolve(in: fontResolutionContext)
                        mt[item.run].font = if let fontName {
                            RichTextEditorViewModel.resolveCustomFont(name: fontName, size: resolved.pointSize, bold: newBold, italic: italic)
                        } else {
                            RichTextEditorViewModel.resolveSystemFont(size: resolved.pointSize, bold: newBold, italic: italic, design: design)
                        }
                    }
                }
            }
            return mutableText
        }
    }

    private func applyingItalicToggle(to text: AttributedString) -> AttributedString {
        switch viewModel.textSelection.indices(in: text) {
        case .insertionPoint:
            viewModel.toggleTypingItalic()
            return text
        case let .ranges(ranges):
            var mutableText = text
            let newItalic = !viewModel.selectedIsItalic
            viewModel.selectedIsItalic = newItalic
            let design = viewModel.selectedDesign
            let fontName = viewModel.selectedFontName
            mutableText.transform(updating: &viewModel.textSelection) { mt in
                for range in ranges.ranges {
                    let runs = mt[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                    for item in runs {
                        let resolved = item.font.resolve(in: fontResolutionContext)
                        mt[item.run].font = if let fontName {
                            RichTextEditorViewModel.resolveCustomFont(name: fontName, size: resolved.pointSize, bold: resolved.isBold, italic: newItalic)
                        } else {
                            RichTextEditorViewModel.resolveSystemFont(size: resolved.pointSize, bold: resolved.isBold, italic: newItalic, design: design)
                        }
                    }
                }
            }
            return mutableText
        }
    }

}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @State var text: AttributedString = .init("Sample text for selection")
    @Previewable @Namespace var namespace
    let viewModel = RichTextEditorViewModel()
    NavigationStack {
        RichTextSelectionActionsView(text: $text, viewModel: viewModel, namespace: namespace)
    }
}
