//
// Copyright © 2024 Alexander Romanov
// RichTextHighlightMenuView.swift, created on 21.05.2026
//

import OversizeResources
import OversizeUI
import SwiftUI

enum HighlightColor: CaseIterable {
    case yellow, orange, red, green, blue, purple

    var color: Color {
        switch self {
        case .yellow: Color(red: 1.0, green: 0.9, blue: 0.0)
        case .orange: Color(red: 1.0, green: 0.6, blue: 0.0)
        case .red: Color(red: 1.0, green: 0.25, blue: 0.25)
        case .green: Color(red: 0.3, green: 0.85, blue: 0.4)
        case .blue: Color(red: 0.3, green: 0.6, blue: 1.0)
        case .purple: Color(red: 0.85, green: 0.4, blue: 1.0)
        }
    }

    var onColor: Color {
        switch self {
        case .yellow, .orange, .green: .black
        case .red, .blue, .purple: .white
        }
    }

    var title: String {
        switch self {
        case .yellow: "Yellow"
        case .orange: "Orange"
        case .red: "Red"
        case .green: "Green"
        case .blue: "Blue"
        case .purple: "Purple"
        }
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public struct RichTextHighlightMenuView: View {
    public enum Action {
        case applyHighlight(Color)
        case removeHighlight
    }

    private let currentHighlightColor: Color?
    private let namespace: Namespace.ID
    private let onAction: (Action) -> Void

    public init(
        currentHighlightColor: Color?,
        namespace: Namespace.ID,
        onAction: @escaping (Action) -> Void
    ) {
        self.currentHighlightColor = currentHighlightColor
        self.namespace = namespace
        self.onAction = onAction
    }

    public var body: some View {
        Menu {
            ForEach(HighlightColor.allCases, id: \.self) { highlight in
                Button {
                    onAction(.applyHighlight(highlight.color))
                } label: {
                    Label(highlight.title, systemImage: "circle.fill")
                }
                .tint(highlight.color)
            }
            Divider()
            Button {
                onAction(.removeHighlight)
            } label: {
                Label {
                    Text("Remove")
                } icon: {
                    Image.Editor.TrashWithLines.mini
                }
                .tint(Color.onSurfacePrimary)
            }
        } label: {
            Icon(Image.Editor.markerWithLine)
                .iconColor(currentHighlightColor ?? Color.onSurfacePrimary)
                .padding(.xxSmall)
                .background(Circle().fill(currentHighlightColor?.opacity(0.15) ?? .clear))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @Namespace var namespace
    HStack {
        RichTextHighlightMenuView(currentHighlightColor: nil, namespace: namespace) { _ in }
    }
    .padding()
}
