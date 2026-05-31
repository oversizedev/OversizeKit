//
// Copyright © 2025 Alexander Romanov
// EmojiGrid.swift
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct EmojiGrid: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let emojis: [String]
    @Binding var selection: String

    private var gridMinSize: CGFloat {
        switch horizontalSizeClass {
        case .compact, .none: 56
        default: 72
        }
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: gridMinSize))],
            spacing: .small
        ) {
            ForEach(emojis, id: \.self) { emoji in
                EmojiButton(emoji: emoji, isSelected: selection == emoji) {
                    selection = emoji
                }
            }
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    EmojiGrid(emojis: ["😀", "😃", "😄", "😁", "😆", "😅"], selection: .constant("😀"))
        .padding()
}
