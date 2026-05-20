//
// Copyright © 2024 Alexander Romanov
// FontFamilyCellView.swift, created on 20.05.2026
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct FontFamilyCellView: View {
    @Binding var selectedFontName: String?
    let family: String
    let fonts: [String]
    let onSelect: () -> Void

    var body: some View {
        if fonts.count == 1 {
            Button(family) {
                selectedFontName = fonts[0]
                onSelect()
            }
            .font(Font.custom(fonts[0], size: 17))
        } else {
            NavigationLink(family) {
                FontFacePicker(
                    selectedFontName: $selectedFontName,
                    familyName: family,
                    fonts: fonts,
                    onSelect: onSelect
                )
            }
            .font(Font.custom(fonts[0], size: 17))
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var font: String? = nil
    NavigationStack {
        List {
            FontFamilyCellView(
                selectedFontName: $font,
                family: "Georgia",
                fonts: ["Georgia", "Georgia-Bold"],
                onSelect: {}
            )
            FontFamilyCellView(
                selectedFontName: $font,
                family: "Courier New",
                fonts: ["CourierNewPSMT"],
                onSelect: {}
            )
        }
    }
}
