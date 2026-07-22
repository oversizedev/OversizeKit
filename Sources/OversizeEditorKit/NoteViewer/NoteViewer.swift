//
// Copyright © 2026 Alexander Romanov
// NoteViewer.swift
//

import OversizeUI
import SwiftUI

public struct NoteViewer: View {
    private let title: String
    private let text: String?
    private let content: AttributedString?

    public init(_ title: String = "Note", text: String) {
        self.title = title
        self.text = text
        content = nil
    }

    public init(_ title: String = "Note", content: AttributedString) {
        self.title = title
        self.content = content
        text = nil
    }

    public var body: some View {
        LayoutView(title) {
            Group {
                if let content {
                    Text(content)
                } else if let text {
                    Text(text)
                }
            }
            .body()
            .foregroundColor(.onSurfacePrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .paddingContent()
        }
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NoteViewer(
            text: "Pack sunscreen, water, and snacks for the hike. Check weather forecast the day before departure."
        )
    }
}
