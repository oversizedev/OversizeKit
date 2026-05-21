//
// Copyright © 2024 Alexander Romanov
// RichTextBottomBar.swift, created on 20.05.2026
//

import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct RichTextBottomBar: View {
    @Binding var text: AttributedString
    var viewModel: RichTextEditorViewModel
    var namespace: Namespace.ID
    @FocusState.Binding var isFocus: Bool

    var body: some View {
        GlassEffectContainer(spacing: .zero) {
            HStack(spacing: .zero) {
                ScrollView(.horizontal) {
                    HStack(spacing: .zero) {
                        if viewModel.hasSelection(in: text) || viewModel.isFontStyleSelection {
                            RichTextSelectionActionsView(
                                text: $text,
                                viewModel: viewModel,
                                namespace: namespace
                            )
                        } else {
                            RichTextTextActionsView(
                                viewModel: viewModel,
                                namespace: namespace
                            )
                        }
                    }
                }
                .scrollIndicators(.hidden)

                Separator(.vertical)
                    .lineWidth(3)
                    .frame(height: .regular)

                Button {
                    isFocus.toggle()
                } label: {
                    Icon(isFocus ? Image.ComputerAndTV.keyboardCloseDown : Image.ComputerAndTV.keyboardOpenUp)
                        .padding(.xSmall)
                        .padding(.trailing, .xxxSmall)
                }
                .glassEffectUnion(id: "bar", namespace: namespace)
            }
        }
        .glassEffect()
        .padding(.horizontal, .small)
        .padding(.vertical, .xSmall)
        .controlSize(.regular)
        .buttonStyle(.scale)
        .animation(.default, value: viewModel.textSelection)
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @State var text: AttributedString = .init("Sample text")
    @Previewable @FocusState var isFocus: Bool
    @Previewable @Namespace var namespace
    let viewModel = RichTextEditorViewModel()
    RichTextBottomBar(text: $text, viewModel: viewModel, namespace: namespace, isFocus: $isFocus)
}
