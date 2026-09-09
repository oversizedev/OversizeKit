//
// Copyright © 2026 Alexander Romanov
// MediaKitDemoView.swift, created on 06.09.2026
//

import OversizeMediaKit
import OversizeUI
import SwiftUI

struct MediaKitDemoView: View {
    @State private var emoji: String = "🚀"
    #if os(iOS)
    @State private var photo: UIImage?
    #endif

    private let emojis: [String] = ["🚀", "📦", "🎨", "🧭", "🔔", "📸"]

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                SectionView("Emoji") {
                    EmojiField("Icon", emojis: emojis, selection: $emoji)
                        .iconPickerStyle(.circle)
                }

                #if os(iOS)
                SectionView("Photo") {
                    PhotoField($photo)
                }
                #endif
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Media")
    }
}

#Preview {
    NavigationStack {
        MediaKitDemoView()
    }
}
