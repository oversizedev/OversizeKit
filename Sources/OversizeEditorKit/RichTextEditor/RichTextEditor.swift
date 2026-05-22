//
// Copyright © 2024 Alexander Romanov
// RichTextEditor.swift, created on 03.03.2024
//

import OversizeCore
import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public struct RichTextEditor: View {
    @Environment(\.fontResolutionContext) var fontResolutionContext
    @Environment(\.undoManager) private var undoManager
    @Environment(\.dismiss) private var dismiss

    @Namespace var unionNamespace
    @FocusState var isFocus: Bool

    @Binding var text: AttributedString
    @State var viewModel: RichTextEditorViewModel

    private let title: String?

    public init(_ title: String? = nil, text: Binding<AttributedString>) {
        self.title = title
        _text = text
        _viewModel = State(wrappedValue: RichTextEditorViewModel(text.wrappedValue))
    }

    public var body: some View {
        TextEditor(text: $viewModel.text, selection: $viewModel.textSelection)
            .focused($isFocus)
            .findNavigator(isPresented: $viewModel.findNavigatorIsPresented)
            .writingToolsBehavior(.complete)
            .contentMargins(.horizontal, .regular, for: .scrollContent)
            .textEditorStyle(.plain)
            .toolbar {
                if let title {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Toggle(isOn: $viewModel.findNavigatorIsPresented) {
                        Label("Find and replace", systemImage: "magnifyingglass")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                    #if !os(tvOS)
                        .keyboardShortcut(.cancelAction)
                    #endif
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                RichTextBottomBar(
                    hasSelection: viewModel.hasSelection,
                    isFontStyleSelection: viewModel.isFontStyleSelection,
                    isFocus: isFocus,
                    canUndo: viewModel.canUndo,
                    canRedo: viewModel.canRedo,
                    isSelectionBold: viewModel.isSelectionBold,
                    isEffectiveItalic: viewModel.isEffectiveItalic,
                    isSelectionUnderlined: viewModel.isSelectionUnderlined,
                    isSelectionStrikethrough: viewModel.isSelectionStrikethrough,
                    isItalicSupported: viewModel.isItalicSupported,
                    selectedTextStyleName: viewModel.selectedTextStyle.displayName,
                    hasSelectionLink: viewModel.hasSelectionLink,
                    selectionHighlightColor: viewModel.selectionHighlightColor,
                    namespace: unionNamespace
                ) { action in
                    switch action {
                    case .undo: viewModel.send(.undo)
                    case .redo: viewModel.send(.redo)
                    case .toggleBold: viewModel.send(.toggleBold)
                    case .toggleItalic: viewModel.send(.toggleItalic)
                    case .toggleUnderline: viewModel.send(.toggleUnderline)
                    case .toggleStrikethrough: viewModel.send(.toggleStrikethrough)
                    case let .applyHighlight(color): viewModel.send(.applyHighlight(color))
                    case .removeHighlight: viewModel.send(.removeHighlight)
                    case .openFontPicker: viewModel.present(.fontPicker)
                    case .openTextStylePicker: viewModel.present(.textStylePicker)
                    case .openLinkSheet: viewModel.send(.openLinkSheet)
                    case .toggleFontStyleSelection: viewModel.send(.toggleFontStyleSelection)
                    case .openAIWritingSheet: viewModel.send(.openAIWritingSheet)
                    case .toggleFocus: isFocus.toggle()
                    }
                }
            }
            .onChange(of: viewModel.text) { oldText, newText in
                guard !viewModel.isApplyingOverrides else { return }
                text = newText
                let addedCount = newText.characters.count - oldText.characters.count
                if viewModel.hasTypingOverrides, addedCount > 0 {
                    viewModel.send(.applyTypingOverrides(oldText: oldText, newText: newText))
                    text = viewModel.text
                    return
                }
                if viewModel.isFontStyleSelection, !viewModel.hasTypingOverrides {
                    withAnimation(.interactiveSpring) {
                        viewModel.isFontStyleSelection = false
                    }
                }
            }
            .onChange(of: text) { _, newText in
                viewModel.syncText(newText)
            }
            .onChange(of: viewModel.textSelection) { _, newSelection in
                if case .ranges = newSelection.indices(in: viewModel.text) {
                    viewModel.clearTypingOverrides()
                }
            }
            .onAppear {
                isFocus = true
                viewModel.undoManager = undoManager
                viewModel.fontResolutionContext = fontResolutionContext
            }
            .onChange(of: undoManager) { _, newValue in
                viewModel.undoManager = newValue
            }
            .onChange(of: fontResolutionContext) { _, newValue in
                viewModel.fontResolutionContext = newValue
            }
            .sheet(item: $viewModel.sheet) { resolveSheet(sheet: $0) }
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @State var text: AttributedString = .init("Pack sunscreen, water, and snacks for the hike. Check weather forecast the day before departure.")
    NavigationStack {
        RichTextEditor("New Article", text: $text)
    }
}
