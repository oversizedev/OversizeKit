//
// Copyright © 2024 Alexander Romanov
// RichTextEditorViewSheet.swift, created on 21.05.2026
//

import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension RichTextEditorViewModel {
    func present(_ sheet: RichTextEditorViewModel.Sheet) {
        self.sheet = sheet
    }

    func close() {
        sheet = nil
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension RichTextEditorViewModel {
    enum Sheet {
        case fontPicker
        case textStylePicker
        case link
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension RichTextEditorViewModel.Sheet: Identifiable {
    var id: String {
        switch self {
        case .fontPicker: "fontPicker"
        case .textStylePicker: "textStylePicker"
        case .link: "link"
        }
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension RichTextEditor {
    func resolveSheet(sheet: RichTextEditorViewModel.Sheet) -> some View {
        Group {
            switch sheet {
            case .fontPicker:
                #if os(iOS) || os(macOS)
                NavigationStack {
                    SystemFontPicker(
                        selectedDesign: Bindable(viewModel).selectedDesign,
                        selectedFontName: Bindable(viewModel).selectedFontName,
                        onApply: { fontName in
                            guard case let .ranges(ranges) = viewModel.textSelection.indices(in: text) else { return }
                            let italic = viewModel.selectedIsItalic
                            let design = viewModel.selectedDesign
                            var mutableText = text
                            mutableText.transform(updating: &viewModel.textSelection) { mt in
                                for range in ranges.ranges {
                                    let runs = mt[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                                    for item in runs {
                                        let resolved = item.font.resolve(in: fontResolutionContext)
                                        let base: Font = if let fontName {
                                            Font.custom(fontName, size: resolved.pointSize)
                                        } else {
                                            Font.system(size: resolved.pointSize, weight: resolved.isBold ? .bold : .regular, design: design)
                                        }
                                        mt[item.run].font = italic ? base.italic() : base
                                    }
                                }
                            }
                            text = mutableText
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
            case .link:
                #if os(iOS) || os(macOS)
                NavigationStack {
                    Form {
                        TextField("https://example.com", text: Bindable(viewModel).linkURLString)
                            .autocorrectionDisabled()
                        #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                        #endif
                        if viewModel.hasSelectionLink(in: text) {
                            Button("Remove link", role: .destructive) {
                                var mutableText = text
                                viewModel.applyLink("", text: &mutableText)
                                text = mutableText
                                viewModel.close()
                            }
                        }
                    }
                    .navigationTitle("Link")
                    .toolbarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", systemImage: "xmark", role: .cancel) {
                                viewModel.close()
                            }
                            .labelStyle(.toolbar)
                            .buttonStyle(.toolbarSecondary)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Apply") {
                                var mutableText = text
                                viewModel.applyLink(viewModel.linkURLString, text: &mutableText)
                                text = mutableText
                                viewModel.close()
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
                #else
                EmptyView()
                #endif
            }
        }
    }
}
