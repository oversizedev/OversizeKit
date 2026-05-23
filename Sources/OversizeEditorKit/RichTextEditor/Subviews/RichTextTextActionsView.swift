//
// Copyright © 2024 Alexander Romanov
// RichTextTextActionsView.swift, created on 20.05.2026
//

import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct RichTextTextActionsView: View {
    enum Action {
        case undo
        case redo
        case toggleFontStyleSelection
        case openAIWritingSheet
    }

    private let canUndo: Bool
    private let canRedo: Bool
    private let namespace: Namespace.ID
    private let onAction: (Action) -> Void

    init(
        canUndo: Bool,
        canRedo: Bool,
        namespace: Namespace.ID,
        onAction: @escaping (Action) -> Void
    ) {
        self.canUndo = canUndo
        self.canRedo = canRedo
        self.namespace = namespace
        self.onAction = onAction
    }

    var body: some View {
        // MARK: - Undo / Redo

        if canUndo {
            RepeatingButton(action: { onAction(.undo) }) {
                Icon(Image.Arrow.reverseLeft)
            }
            .buttonStyle(.bar)
            .barItem(namespace: namespace)
        }

        if canRedo {
            RepeatingButton(action: { onAction(.redo) }) {
                Icon(Image.Arrow.reverseRight)
            }
            .buttonStyle(.bar)
            .barItem(namespace: namespace)
        }

        if canUndo || canRedo {
            Separator(.vertical)
                .lineWidth(3)
                .frame(height: .regular)
        }

        Button { onAction(.toggleFontStyleSelection) } label: {
            Icon(Image.Editor.titleCase)
        }
        .buttonStyle(.bar)
        .barItem(namespace: namespace)

        Separator(.vertical)
            .lineWidth(3)
            .frame(height: .regular)

        Button { onAction(.openAIWritingSheet) } label: {
            Icon(Image.Ai.sparksAi)
        }
        #if os(iOS)
        .matchedTransitionSource(id: "aiWriting", in: namespace)
        #endif
        .buttonStyle(.bar)
        .barItem(namespace: namespace)
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @Namespace var namespace
    ScrollView(.horizontal) {
        HStack(spacing: .zero) {
            RichTextTextActionsView(
                canUndo: true,
                canRedo: false,
                namespace: namespace
            ) { _ in }
        }
    }
}
