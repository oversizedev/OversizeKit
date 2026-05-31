//
// Copyright © 2025 Alexander Romanov
// IconPickerButton.swift
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct IconPickerButton: View {
    let icon: Image
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Icon(icon)
                .padding(.xSmall)
                .background(
                    Circle()
                        .fill(Color.surfaceSecondary)
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
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    HStack {
        IconPickerButton(icon: Image(systemName: "star"), isSelected: false, action: {})
        IconPickerButton(icon: Image(systemName: "star.fill"), isSelected: true, action: {})
    }
    .padding()
}
