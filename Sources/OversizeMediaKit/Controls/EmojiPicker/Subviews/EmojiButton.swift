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
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(isSelected ? Color.surfaceSecondary : Color.clear)
                )
                .padding(5)
                .background(
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.accentColor : Color.clear,
                            lineWidth: isSelected ? 2.5 : 0
                        )
                )
        }
        .buttonStyle(.scale)

//        Button(action: action) {
//            Icon(icon)
//                .padding(.xSmall)
//                .background(
//                    Circle()
//                        .fill(Color.surfaceSecondary)
//                )
//                .padding(5)
//                .background(
//                    Circle()
//                        .strokeBorder(
//                            isSelected ? Color.accentColor : Color.clear,
//                            lineWidth: isSelected ? 2.5 : 0
//                        )
//                )
//        }
//        .buttonStyle(.scale)
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
