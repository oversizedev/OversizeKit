//
// Copyright © 2026 Alexander Romanov
// EditorKitDemoView.swift, created on 06.09.2026
//

import OversizeEditorKit
import OversizeKit
import OversizeUI
import SwiftUI

struct EditorKitDemoView: View {
    @State private var note: String = "OversizeKit ships the screens every app repeats."
    @State private var link: URL?

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                SectionView("Note") {
                    NoteEditor("Note", text: $note)
                        .frame(minHeight: 160)
                }

                SectionView("Link") {
                    URLEditor("Link", url: $link) {
                        EmptyView()
                    }
                }
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Editor")
    }
}

#Preview {
    NavigationStack {
        EditorKitDemoView()
    }
}
