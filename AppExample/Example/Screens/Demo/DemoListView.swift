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
            VStack(spacing: .small) {
                SectionView("Kits") {
                    VStack(spacing: .zero) {
                        row("Media", image: "photo", destination: .media, identifier: AccessibilityIdentifier.mediaRow)
                        row("Editor", image: "text.cursor", destination: .editor, identifier: AccessibilityIdentifier.editorRow)
                        row("Calendar", image: "calendar", destination: .calendar)
                        row("Contacts", image: "person.crop.circle", destination: .contacts)
                        row("Location", image: "mappin.and.ellipse", destination: .location)
                        row("Notification", image: "bell.badge", destination: .notification)
                        row("Cloud", image: "icloud", destination: .cloud)
                    }
                }
                .sectionContentCompactRowMargins()

                SectionView("OversizeKit") {
                    VStack(spacing: .zero) {
                        row("Store", image: "creditcard", destination: .store)
                        row("Lockscreen", image: "lock", destination: .lockscreen)
                        row("Web", image: "link", destination: .web)
                        row("Debug", image: "ladybug", destination: .debug)
                    }
                }
                .sectionContentCompactRowMargins()
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle(RootTab.demo.title)
    }

    private func row(
        _ title: String,
        image: String,
        destination: DemoDestinations,
        identifier: String? = nil
    ) -> some View {
        Row(title) {
            navigator.navigate(to: destination)
        } leading: {
            Image(systemName: image)
        }
        .navigatable()
        .buttonStyle(.row)
        .accessibilityIdentifier(identifier ?? title)
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
    .appEnvironment()
}
