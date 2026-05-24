//
// Copyright © 2024 Alexander Romanov
// ArticleListEditor.swift, created on 03.03.2024
//

import OversizeKit
import OversizeMediaKit
import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public struct ArticleListEditor: View {
    @Namespace private var unionNamespace
    @Environment(\.dismiss) private var dismiss
    @Environment(\.fontResolutionContext) private var fontResolutionContext
    @Environment(\.undoManager) private var undoManager

    @State private var viewModel = ArticleListEditorViewModel()
    @FocusState private var focusedId: UUID?
    @State private var isFocus: Bool = false

    public init() {}

    public var body: some View {
        ListLayoutView("Editor") {
            ForEach($viewModel.blocks) { $block in
                let continuationType: BlockType = block.type == .list ? .list : .text
                let textBinding = Binding<AttributedString>(
                    get: { block.text },
                    set: { newValue in
                        guard !viewModel.isApplyingOverrides else { return }
                        if newValue.characters.contains("\n") {
                            viewModel.send(.splitBlock(blockId: block.id, text: newValue, continuationType: continuationType))
                        } else {
                            block.text = newValue
                        }
                    }
                )
                Group {
                    switch block.type {
                    case .text: textBlockView(block: $block, textBinding: textBinding)
                    case .image: imageBlockView(block: $block)
                    case .separator: separatorBlockView
                    case .quote: quoteBlockView(block: $block, textBinding: textBinding)
                    case .list: listBlockView(block: $block, textBinding: textBinding)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: .medium, bottom: 0, trailing: .medium))
            }
            .onMove { viewModel.send(.moveBlocks(fromOffsets: $0, toOffset: $1)) }
            .onDelete { viewModel.send(.deleteOffsets($0)) }
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom) {
            ArticleBottomBar(
                hasSelection: viewModel.hasSelection,
                isFontStyleSelection: viewModel.isFontStyleSelection,
                isFocus: isFocus,
                isSelectionBold: viewModel.isSelectionBold,
                isEffectiveItalic: viewModel.isEffectiveItalic,
                isSelectionUnderlined: viewModel.isSelectionUnderlined,
                isSelectionStrikethrough: viewModel.isSelectionStrikethrough,
                isItalicSupported: viewModel.isItalicSupported,
                selectedTextStyleName: viewModel.selectedTextStyleName,
                hasSelectionLink: viewModel.hasSelectionLink,
                selectionHighlightColor: viewModel.selectionHighlightColor,
                namespace: unionNamespace
            ) { action in
                switch action {
                case .insertImage: viewModel.send(.insertImage)
                case .insertQuote: viewModel.send(.insertBlock(ArticleBlock(type: .quote)))
                case .insertList: viewModel.send(.insertBlock(ArticleBlock(type: .list)))
                case .insertSeparator: viewModel.send(.insertBlock(ArticleBlock(type: .separator)))
                case .insertLink: break
                case .toggleBold: viewModel.send(.toggleBold)
                case .toggleItalic: viewModel.send(.toggleItalic)
                case .toggleUnderline: viewModel.send(.toggleUnderline)
                case .toggleStrikethrough: viewModel.send(.toggleStrikethrough)
                case let .applyHighlight(color): viewModel.send(.applyHighlight(color))
                case .removeHighlight: viewModel.send(.removeHighlight)
                case .openFontPicker: viewModel.send(.openFontPicker)
                case .openTextStylePicker: viewModel.send(.openTextStylePicker)
                case .openLinkSheet: viewModel.send(.openLinkSheet)
                case .toggleFontStyleSelection: viewModel.send(.toggleFontStyleSelection)
                case .toggleFocus:
                    if isFocus { focusedId = nil } else { focusedId = viewModel.focusedId }
                }
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        #if canImport(UIKit)
            .onChange(of: viewModel.pickerSelectedImage) { _, image in
                viewModel.send(.imageSelected(image))
            }
        #endif
            .sheet(item: $viewModel.sheet) { resolveSheet($0) }
            .onAppear {
                viewModel.fontResolutionContext = fontResolutionContext
                focusedId = viewModel.blocks.first?.id
                viewModel.focusedId = focusedId
            }
            .onChange(of: fontResolutionContext) { _, value in
                viewModel.fontResolutionContext = value
            }
            .onChange(of: focusedId) { oldValue, newValue in
                isFocus = newValue != nil
                if oldValue != newValue {
                    viewModel.clearTypingOverrides()
                }
                if let newValue {
                    viewModel.focusedId = newValue
                }
            }
            .onChange(of: viewModel.focusedId) { _, newValue in
                guard focusedId != newValue else { return }
                focusedId = newValue
            }
            .onChange(of: viewModel.focusedBlockText) { oldText, newText in
                guard !viewModel.isApplyingOverrides else { return }
                let addedCount = newText.characters.count - oldText.characters.count
                if viewModel.hasTypingOverrides, addedCount > 0, let focusedId = viewModel.focusedId {
                    viewModel.send(.applyTypingOverrides(blockId: focusedId, oldText: oldText, newText: newText))
                } else if viewModel.isFontStyleSelection, !viewModel.hasTypingOverrides {
                    viewModel.isFontStyleSelection = false
                }
            }
            .onChange(of: viewModel.textSelection) { _, newSelection in
                if case .ranges = newSelection.indices(in: viewModel.focusedBlockText) {
                    viewModel.clearTypingOverrides()
                }
            }
    }

    // MARK: - Block Views

    @ViewBuilder
    private func textBlockView(block: Binding<ArticleBlock>, textBinding: Binding<AttributedString>) -> some View {
        let blockId = block.wrappedValue.id
        TextEditor(text: textBinding, selection: $viewModel.textSelection)
            .frame(minHeight: 44)
            .focused($focusedId, equals: blockId)
            .overlay(alignment: .trailing) {
                if focusedId == blockId {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.tertiary)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .animation(.default, value: focusedId)
            .onKeyPress(.delete) { viewModel.handleDeleteKey(blockId: blockId) }
    }

    @ViewBuilder
    private func quoteBlockView(block: Binding<ArticleBlock>, textBinding: Binding<AttributedString>) -> some View {
        let blockId = block.wrappedValue.id
        HStack(alignment: .top, spacing: .xSmall) {
            RoundedRectangle(cornerRadius: 2)
                .fill(.tint.opacity(0.7))
                .frame(width: 3)
                .padding(.vertical, .xxSmall)
            TextEditor(text: textBinding, selection: $viewModel.textSelection)
                .frame(minHeight: 44)
                .italic()
                .foregroundStyle(.secondary)
                .focused($focusedId, equals: blockId)
                .onKeyPress(.delete) { viewModel.handleDeleteKey(blockId: blockId) }
        }
        .overlay(alignment: .trailing) {
            if focusedId == blockId {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.tertiary)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: focusedId)
    }

    @ViewBuilder
    private func listBlockView(block: Binding<ArticleBlock>, textBinding: Binding<AttributedString>) -> some View {
        let blockId = block.wrappedValue.id
        HStack(alignment: .top, spacing: .xSmall) {
            Text("•")
                .foregroundStyle(.primary)
                .padding(.top, 4)
            TextEditor(text: textBinding, selection: $viewModel.textSelection)
                .frame(minHeight: 44)
                .focused($focusedId, equals: blockId)
                .onKeyPress(.delete) { viewModel.handleDeleteKey(blockId: blockId) }
        }
        .overlay(alignment: .trailing) {
            if focusedId == blockId {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.tertiary)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: focusedId)
    }

    private var separatorBlockView: some View {
        Divider()
            .padding(.vertical, .small)
    }

    @ViewBuilder
    private func imageBlockView(block: Binding<ArticleBlock>) -> some View {
        let blockId = block.wrappedValue.id
        if let data = block.imageData.wrappedValue, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.vertical, .xSmall)
                .overlay(alignment: .topTrailing) {
                    Button {
                        viewModel.send(.removeBlock(blockId: blockId))
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black.opacity(0.5))
                            .font(.title3)
                    }
                    .padding(.xSmall)
                }
        }
    }

    // MARK: - Sheet

    @ViewBuilder
    private func resolveSheet(_ sheet: ArticleListEditorViewModel.Sheet) -> some View {
        switch sheet {
        case .textStylePicker:
            #if os(iOS) || os(macOS)
            NavigationStack {
                TextStylePicker(selectedStyle: Bindable(viewModel).selectedTextStyle)
            }
            #if os(iOS)
            .presentationDetents([.medium, .large])
            .navigationTransition(.zoom(sourceID: "textStylePicker", in: unionNamespace))
            #endif
            #else
            EmptyView()
            #endif

        case .fontPicker:
            #if os(iOS) || os(macOS)
            NavigationStack {
                SystemFontPicker(
                    selectedDesign: Bindable(viewModel).selectedDesign,
                    selectedFontName: Bindable(viewModel).selectedFontName,
                    onApply: { fontName in
                        viewModel.send(.applyFont(name: fontName, design: viewModel.selectedDesign))
                    }
                )
            }
            #if os(iOS)
            .presentationDetents([.medium, .large])
            .navigationTransition(.zoom(sourceID: "fontPicker", in: unionNamespace))
            #endif
            #else
            EmptyView()
            #endif

        case .link:
            #if os(iOS) || os(macOS)
            NavigationStack {
                URLEditor("Link", url: Bindable(viewModel).linkURL) {
                    Button("Apply") {
                        viewModel.send(.applyLink(viewModel.linkURL))
                    }
                }
                .toolbar {
                    if viewModel.hasSelectionLink {
                        ToolbarItem(placement: .destructiveAction) {
                            Button("Remove link", role: .destructive) {
                                viewModel.send(.applyLink(nil))
                            }
                        }
                    }
                }
            }
            .presentationDetents([.medium])
            #else
            EmptyView()
            #endif

        case .photoPicker:
            #if os(iOS)
            NavigationStack {
                PhotoLibraryPicker(selection: Bindable(viewModel).pickerSelectedImage)
                    .hideCamera()
            }
            #else
            EmptyView()
            #endif
        }
    }
}

// MARK: - Preview

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    NavigationStack {
        ArticleListEditor()
    }
}
