//
// Copyright © 2025 Alexander Romanov
// EmojiGroupSection.swift
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct EmojiGroupSection: View {
    let group: EmojiGroup
    @Binding var selection: String

    var body: some View {
        SectionView(group.title) {
            EmojiGrid(emojis: group.emojis, selection: $selection)
        }
        .surfaceContentMargins(.small)
        .sectionViewStyle(.edgeToEdge)
        .surfaceRadius(.regular)
        .id(group)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    EmojiGroupSection(group: .smileysAndEmotion, selection: .constant("😀"))
        .padding()
}
