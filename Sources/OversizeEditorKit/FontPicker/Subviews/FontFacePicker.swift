//
// Copyright © 2024 Alexander Romanov
// FontFacePicker.swift, created on 20.05.2026
//

import OversizeUI
import SwiftUI

// MARK: - ViewModel

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@MainActor
@Observable
final class FontFacePickerViewModel {
    var searchQuery: String = ""
    let familyName: String
    private let allFaces: [(fontName: String, faceName: String)]

    init(familyName: String, fonts: [String]) {
        self.familyName = familyName
        allFaces = fonts.map { ($0, FontFamilyProvider.fontFace(for: $0)) }
    }

    var filteredFaces: [(fontName: String, faceName: String)] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return allFaces }
        return allFaces.filter { $0.faceName.localizedCaseInsensitiveContains(trimmed) }
    }
}

// MARK: - View

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct FontFacePicker: View {
    @Binding var selectedFontName: String?
    let onSelect: () -> Void
    @State private var viewModel: FontFacePickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(selectedFontName: Binding<String?>, familyName: String, fonts: [String], onSelect: @escaping () -> Void) {
        _selectedFontName = selectedFontName
        self.onSelect = onSelect
        _viewModel = State(initialValue: FontFacePickerViewModel(familyName: familyName, fonts: fonts))
    }

    var body: some View {
        ListLayoutView(viewModel.familyName) {
            ListSection {
                ForEach(viewModel.filteredFaces, id: \.fontName) { fontName, faceName in
                    Button(faceName) {
                        selectedFontName = fontName
                        dismiss()
                        onSelect()
                    }
                    .font(Font.custom(fontName, size: 17))
                    .foregroundStyle(Color.onSurfacePrimary)
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .toolbarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchQuery)
        .toolbar {
            #if os(iOS)
            if #available(iOS 26.0, *) {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
            }
            #endif
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var font: String? = nil
    NavigationStack {
        FontFacePicker(
            selectedFontName: $font,
            familyName: "Helvetica",
            fonts: ["Helvetica", "Helvetica-Bold", "Helvetica-Oblique", "Helvetica-BoldOblique"],
            onSelect: {}
        )
    }
}
