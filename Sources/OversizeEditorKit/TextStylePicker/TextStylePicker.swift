//
// Copyright © 2024 Alexander Romanov
// TextStylePicker.swift, created on 21.05.2026
//

import OversizeCore
import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct TextStylePicker: View {
    @Binding var selectedStyle: Font.TextStyle
    var styles: [Font.TextStyle]
    @Environment(\.dismiss) private var dismiss

    public init(selectedStyle: Binding<Font.TextStyle>, styles: [Font.TextStyle] = Font.TextStyle.allCases) {
        _selectedStyle = selectedStyle
        self.styles = styles
    }

    public var body: some View {
        ListLayoutView("Style") {
            ListSection {
                ForEach(styles, id: \.self) { style in
                    Button {
                        selectedStyle = style
                        dismiss()
                    } label: {
                        HStack {
                            Text(style.displayName)
                                .font(.system(style))
                            Spacer()
                            if selectedStyle == style {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .foregroundStyle(Color.onSurfacePrimary)
                    }
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) { dismiss() }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                #if !os(tvOS) && !os(watchOS)
                    .keyboardShortcut(.cancelAction)
                #endif
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var style: Font.TextStyle = .body
    NavigationStack {
        TextStylePicker(selectedStyle: $style)
    }
}
