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
    @Environment(\.dismiss) private var dismiss

    @Namespace var unionNamespace
    @FocusState var isFocus: Bool

    @Binding var text: AttributedString
    @State var viewModel = RichTextEditorViewModel()

    private let title: String?

    public init(_ title: String? = nil, text: Binding<AttributedString>) {
        self.title = title
        _text = text
    }

    public var body: some View {
        TextEditor(text: $text, selection: $viewModel.textSelection)
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
                    text: $text,
                    viewModel: viewModel,
                    namespace: unionNamespace,
                    isFocus: $isFocus
                )
            }
            .onChange(of: text) { _, _ in
                if viewModel.isFontStyleSelection {
                    withAnimation(.interactiveSpring) {
                        viewModel.isFontStyleSelection = false
                    }
                }
            }
            .onAppear {
                isFocus = true
            }
            // .animation(.default, value: isFocus)
            .sheet(item: $viewModel.sheet) { resolveSheet(sheet: $0) }
        #if os(iOS) || os(macOS)
            .onChange(of: viewModel.selectedTextStyle) { _, style in
                guard case let .ranges(ranges) = viewModel.textSelection.indices(in: text) else { return }
                let italic = viewModel.selectedIsItalic
                let design = viewModel.selectedDesign
                let customFontName = viewModel.selectedFontName
                let stylePointSize = Font.system(style).resolve(in: fontResolutionContext).pointSize
                var mutableText = text
                mutableText.transform(updating: &viewModel.textSelection) { mt in
                    for range in ranges.ranges {
                        let runs = mt[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                        for item in runs {
                            let isBold = item.font.resolve(in: fontResolutionContext).isBold
                            let base: Font = if let fontName = customFontName {
                                isBold ? Font.custom(fontName, size: stylePointSize).bold() : Font.custom(fontName, size: stylePointSize)
                            } else {
                                Font.system(style, design: design, weight: isBold ? .bold : .regular)
                            }
                            mt[item.run].font = italic ? base.italic() : base
                        }
                    }
                }
                text = mutableText
            }
        #endif
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @State var text: AttributedString = .init("Pack sunscreen, water, and snacks for the hike. Check weather forecast the day before departure.")
    NavigationStack {
        RichTextEditor("New Article", text: $text)
    }
}
