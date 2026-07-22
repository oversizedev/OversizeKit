//
// Copyright © 2024 Alexander Romanov
// RecentFontsSectionView.swift, created on 20.05.2026
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct RecentFontsSectionView: View {
    @Binding var selectedFontName: String?
    let recentFonts: [String]
    let onSelect: () -> Void

    var body: some View {
        if !recentFonts.isEmpty {
            ListSection("Recently Used") {
                ForEach(recentFonts, id: \.self) { fontName in
                    Button {
                        selectedFontName = fontName
                        onSelect()
                    } label: {
                        VStack(alignment: .leading, spacing: .xxxSmall) {
                            Text("Aa")
                                .font(Font.custom(fontName, size: 20))
                                .foregroundStyle(Color.onSurfacePrimary)
                            Text(FontFamilyProvider.displayName(for: fontName))
                                .font(.caption)
                                .foregroundStyle(Color.onSurfaceSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var font: String? = nil
    NavigationStack {
        List {
            RecentFontsSectionView(
                selectedFontName: $font,
                recentFonts: ["Georgia", "Helvetica-Bold"],
                onSelect: {}
            )
        }
    }
}
