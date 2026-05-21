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
                    FontPicker(selectedFontName: Bindable(viewModel).selectedFontName)
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
