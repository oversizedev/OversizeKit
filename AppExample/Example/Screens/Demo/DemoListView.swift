//
// Copyright © 2026 Alexander Romanov
// DemoListView.swift, created on 06.09.2026
//

import NavigatorUI
import OversizeUI
import SwiftUI

struct DemoListView: View {
    @Environment(\.navigator) private var navigator

    var body: some View {
        ScrollView {
            SectionView("Kits") {
                VStack(spacing: .zero) {
                    Row("Media") {
                        navigator.navigate(to: DemoDestinations.media)
                    } leading: {
                        Image(systemName: "photo")
                    }
                    .rowArrow()
                    .buttonStyle(.row)
                    .accessibilityIdentifier(AccessibilityIdentifier.mediaRow)

                    Row("Editor") {
                        navigator.navigate(to: DemoDestinations.editor)
                    } leading: {
                        Image(systemName: "text.cursor")
                    }
                    .rowArrow()
                    .buttonStyle(.row)
                    .accessibilityIdentifier(AccessibilityIdentifier.editorRow)
                }
            }
            .sectionContentCompactRowMargins()
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle(RootTab.demo.title)
    }
}

extension DemoListView {
    enum AccessibilityIdentifier {
        static let mediaRow = "demo.media.row"
        static let editorRow = "demo.editor.row"
    }
}

#Preview {
    NavigationStack {
        DemoListView()
    }
}
