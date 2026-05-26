//
// Copyright © 2024 Alexander Romanov
// ArticleEditor.swift, created on 03.03.2024
//

import OversizeKit
import OversizeMediaKit
import OversizeResources
import OversizeUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public struct ArticleEditor: View {
    @Namespace private var unionNamespace
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = ArticleEditorViewModel()

    private var isFocus: Bool {
        viewModel.focusedId != nil
    }

    public init() {}

    public var body: some View {
        List {
            ForEach($viewModel.blocks) { $block in
                Group {
                    switch block.type {
                    case .text: textBlockView(block: $block)
                    case .image: imageBlockView(block: $block)
                    case .separator: separatorBlockView
                    case .quote: quoteBlockView(block: $block)
                    case .list: listBlockView(block: $block)
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            }
            .onMove { viewModel.send(.moveBlocks(fromOffsets: $0, toOffset: $1)) }
            .onDelete { viewModel.send(.deleteOffsets($0)) }
            #if os(iOS)
                .listRowSpacing(0)
            #endif
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)
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
                case .toggleFocus: viewModel.toggleFocus()
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
                viewModel.focusedId = viewModel.blocks.first?.id
            }
    }

    // MARK: - Block Views

    @ViewBuilder
    private func textBlockView(block: Binding<ArticleBlock>) -> some View {
        let blockId = block.wrappedValue.id
        #if canImport(UIKit)
        ArticleTextView(
            text: block.wrappedValue.text,
            isFocused: viewModel.focusedId == blockId,
            onTextChange: { viewModel.onTextChanged($0, blockId: blockId) },
            onSelectionChange: { viewModel.onSelectionChanged($0, typingAttributes: $1) },
            onReturn: { viewModel.onReturn(blockId: blockId) },
            onDeleteWhenEmpty: { viewModel.onDeleteWhenEmpty(blockId: blockId) },
            onFocus: { viewModel.onFocused(blockId: blockId, textView: $0) },
            onBlur: { viewModel.onBlurred(from: $0, blockId: blockId) }
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(minHeight: 0)
        #else
        TextEditor(text: Binding(
            get: { AttributedString(block.wrappedValue.text) },
            set: { block.wrappedValue.text = NSAttributedString($0) }
        ))
        .fixedSize(horizontal: false, vertical: true)
        #endif
    }

    @ViewBuilder
    private func quoteBlockView(block: Binding<ArticleBlock>) -> some View {
        let blockId = block.wrappedValue.id
        HStack(alignment: .top, spacing: .xSmall) {
            RoundedRectangle(cornerRadius: 2)
                .fill(.tint.opacity(0.7))
                .frame(width: 3)
                .padding(.vertical, .xxSmall)
            #if canImport(UIKit)
            ArticleTextView(
                text: block.wrappedValue.text,
                isFocused: viewModel.focusedId == blockId,
                defaultFont: .italicSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
                defaultTextColor: .secondaryLabel,
                onTextChange: { viewModel.onTextChanged($0, blockId: blockId) },
                onSelectionChange: { viewModel.onSelectionChanged($0, typingAttributes: $1) },
                onReturn: { viewModel.onReturn(blockId: blockId) },
                onDeleteWhenEmpty: { viewModel.onDeleteWhenEmpty(blockId: blockId) },
                onFocus: { viewModel.onFocused(blockId: blockId, textView: $0) },
                onBlur: { viewModel.onBlurred(from: $0, blockId: blockId) }
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(minHeight: 0)
            #else
            TextEditor(text: Binding(
                get: { AttributedString(block.wrappedValue.text) },
                set: { block.wrappedValue.text = NSAttributedString($0) }
            ))
            .italic()
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            #endif
        }
        .overlay(alignment: .trailing) {
            if viewModel.focusedId == blockId {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.tertiary)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.focusedId)
    }

    @ViewBuilder
    private func listBlockView(block: Binding<ArticleBlock>) -> some View {
        let blockId = block.wrappedValue.id
        HStack(alignment: .top, spacing: .xSmall) {
            Text("•")
                .foregroundStyle(.primary)
                .padding(.top, 4)
            #if canImport(UIKit)
            ArticleTextView(
                text: block.wrappedValue.text,
                isFocused: viewModel.focusedId == blockId,
                onTextChange: { viewModel.onTextChanged($0, blockId: blockId) },
                onSelectionChange: { viewModel.onSelectionChanged($0, typingAttributes: $1) },
                onReturn: { viewModel.onReturn(blockId: blockId) },
                onDeleteWhenEmpty: { viewModel.onDeleteWhenEmpty(blockId: blockId) },
                onFocus: { viewModel.onFocused(blockId: blockId, textView: $0) },
                onBlur: { viewModel.onBlurred(from: $0, blockId: blockId) }
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(minHeight: 0)
            #else
            TextEditor(text: Binding(
                get: { AttributedString(block.wrappedValue.text) },
                set: { block.wrappedValue.text = NSAttributedString($0) }
            ))
            .fixedSize(horizontal: false, vertical: true)
            #endif
        }
        .overlay(alignment: .trailing) {
            if viewModel.focusedId == blockId {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.tertiary)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.focusedId)
    }

    private var separatorBlockView: some View {
        Divider()
            .padding(.vertical, .small)
    }

    @ViewBuilder
    private func imageBlockView(block: Binding<ArticleBlock>) -> some View {
        let blockId = block.wrappedValue.id
        #if canImport(UIKit)
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
        #endif
    }

    // MARK: - Sheet

    @ViewBuilder
    private func resolveSheet(_ sheet: ArticleEditorViewModel.Sheet) -> some View {
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
        ArticleEditor()
    }
}
