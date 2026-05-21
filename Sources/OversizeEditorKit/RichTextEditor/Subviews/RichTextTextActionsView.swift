//
// Copyright © 2024 Alexander Romanov
// RichTextTextActionsView.swift, created on 20.05.2026
//

import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct RichTextTextActionsView: View {
    var viewModel: RichTextEditorViewModel
    var namespace: Namespace.ID

    var body: some View {
        Button {
            withAnimation(.interactiveSpring) {
                viewModel.isFontStyleSelection.toggle()
            }
        } label: {
            Icon(Image.Editor.titleCase)
                .padding(.xSmall)
                .padding(.leading, .xxxSmall)
        }
        .barItem(namespace: namespace)

        Button {} label: {
            Icon(Image.Base.picture2)
                .padding(.xSmall)
                .padding(.leading, .xxxSmall)
        }
        .barItem(namespace: namespace)

        Button {} label: {
            Icon(Image.Base.link)
                .padding(.xSmall)
        }
        .barItem(namespace: namespace)
    }
}
