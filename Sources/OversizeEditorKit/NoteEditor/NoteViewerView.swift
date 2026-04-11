//
// Copyright © 2026 Alexander Romanov
// NoteViewerView.swift
//

import OversizeUI
import SwiftUI

public struct NoteViewer: View {
    private let title: String
    private let text: String

    public init(_ title: String = "Note", text: String) {
        self.title = title
        self.text = text
    }

    public var body: some View {
        LayoutView(title) {
            Text(text)
                .body()
                .foregroundColor(.onSurfacePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .paddingContent()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NoteViewer(
            text: "Pack sunscreen, water, and snacks for the hike. Check weather forecast the day before departure."
        )
    }
}
