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

        Button {
            onAction(.undo)
        } label: {
            Icon(Image(systemName: "arrow.uturn.backward"))
                .padding(.xSmall)
                .padding(.leading, .xxxSmall)
        }
        .disabled(!canUndo)
        .barItem(namespace: namespace)

        Button {
            onAction(.redo)
        } label: {
            Icon(Image(systemName: "arrow.uturn.forward"))
                .padding(.xSmall)
        }
        .disabled(!canRedo)
        .barItem(namespace: namespace)

        Separator(.vertical)
            .lineWidth(3)
            .frame(height: .regular)

        Button {
            onAction(.toggleFontStyleSelection)
        } label: {
            Icon(Image.Editor.titleCase)
                .padding(.xSmall)
        }
        .barItem(namespace: namespace)
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @Namespace var namespace
    RichTextTextActionsView(
        canUndo: true,
        canRedo: false,
        namespace: namespace
    ) { _ in }
}
