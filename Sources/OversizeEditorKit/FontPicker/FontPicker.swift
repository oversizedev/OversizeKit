//
// Copyright © 2024 Alexander Romanov
// FontPicker.swift, created on 20.05.2026
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct FontPicker: View {
    @Binding var selectedFontName: String?
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = FontPickerViewModel()

    var onApply: ((String) -> Void)?

    public init(selectedFontName: Binding<String?>, onApply: ((String) -> Void)? = nil) {
        _selectedFontName = selectedFontName
        self.onApply = onApply
    }

    private func onSelectFont() {
        if let name = selectedFontName { onApply?(name) }
        dismiss()
    }

    public var body: some View {
        ListLayoutView("Font") {
            if !viewModel.isSearching {
                RecentFontsSectionView(
                    selectedFontName: $selectedFontName,
                    recentFonts: viewModel.recentFonts,
                    onSelect: onSelectFont
                )
            }

            if viewModel.isSystemFontVisible {
                ListSection("System") {
                    NavigationLink("System Font (Default)") {
                        FontFacePicker(
                            selectedFontName: $selectedFontName,
                            familyName: "System Fonts",
                            fonts: viewModel.systemFonts,
                            onSelect: onSelectFont
                        )
                    }
                }
            }

            ForEach(viewModel.alphabets, id: \.self) { initial in
                let families = viewModel.families(for: initial)
                if !families.isEmpty {
                    let label = String(initial).uppercased()
                    if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                        ListSection(label) {
                            ForEach(families, id: \.self) { family in
                                let fonts = viewModel.fonts(for: family)
                                if !fonts.isEmpty {
                                    FontFamilyRowView(
                                        selectedFontName: $selectedFontName,
                                        family: family,
                                        fonts: fonts,
                                        onSelect: onSelectFont
                                    )
                                }
                            }
                        }
                        .sectionIndexLabel(Text(label))
                        .foregroundStyle(Color.onSurfacePrimary)
                    } else {
                        ListSection(label) {
                            ForEach(families, id: \.self) { family in
                                let fonts = viewModel.fonts(for: family)
                                if !fonts.isEmpty {
                                    FontFamilyRowView(
                                        selectedFontName: $selectedFontName,
                                        family: family,
                                        fonts: fonts,
                                        onSelect: onSelectFont
                                    )
                                }
                            }
                        }
                        .foregroundStyle(Color.onSurfacePrimary)
                    }
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        #if os(iOS)
            .listSectionIndexVisibility(.visible)
            .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .always))
        #else
            .searchable(text: $viewModel.searchQuery)
        #endif
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                #if os(iOS)
                if #available(iOS 26.0, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                }
                #endif
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                    #if !os(tvOS) && !os(watchOS)
                        .keyboardShortcut(.cancelAction)
                    #endif
                }
            }
            .onChange(of: selectedFontName) { _, name in
                guard let name else { return }
                viewModel.recordSelection(name)
            }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var font: String? = nil
    NavigationStack {
        FontPicker(selectedFontName: $font)
    }
}
