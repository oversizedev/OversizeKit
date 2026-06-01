//
// Copyright © 2025 Alexander Romanov
// IconPickerButton.swift
//

import OversizeUI
import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if (canImport(UIKit) && !os(watchOS)) || canImport(AppKit)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
struct IconPickerButton: View {
    #if canImport(UIKit) && !os(watchOS)
    let icon: UIImage
    #elseif canImport(AppKit)
    let icon: NSImage
    #endif
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            iconView
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

    @ViewBuilder
    private var iconView: some View {
        #if canImport(UIKit) && !os(watchOS)
        Icon(Image(uiImage: icon))
        #elseif canImport(AppKit)
        Icon(Image(nsImage: icon))
        #endif
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
#Preview {
    HStack {
        #if canImport(UIKit) && !os(watchOS)
        IconPickerButton(icon: UIImage(systemName: "star") ?? UIImage(), isSelected: false, action: {})
        IconPickerButton(icon: UIImage(systemName: "star.fill") ?? UIImage(), isSelected: true, action: {})
        #endif
    }
    .padding()
}
#endif
