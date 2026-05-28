//
// Copyright © 2025 Alexander Romanov
// EmojiButton.swift
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct EmojiButton: View {
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: .xSmall, style: .continuous)
                        .fill(isSelected ? Color.primary.opacity(0.08) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .xSmall, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.accentColor : Color.clear,
                            lineWidth: 2
                        )
                )
                .contentShape(Rectangle())
            
        }
        .buttonStyle(.scale)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    HStack {
        EmojiButton(emoji: "😀", isSelected: false, action: {})
        EmojiButton(emoji: "❤️", isSelected: true, action: {})
    }
    .padding()
}
