//
// Copyright © 2023 Alexander Romanov
// AttachmentView.swift
//

import OversizeUI
import SwiftUI

public struct AttachmentView: View {
    @Environment(\.dismiss) var dismiss

    public init() {}

    public var body: some View {
        LayoutView("Attachment") {
            SectionView {
                VStack(spacing: .zero) {
                    Row("Add investment") {
                        Image.Base.attach
                            .icon()
                    }

                    Row("Add link") {
                        Image.Base.link
                            .icon()
                    }
                }
            }
            .surfaceContentRowMargins()
        } background: {
            Color.backgroundSecondary
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
                #if !os(tvOS) && !os(watchOS)
                .keyboardShortcut(.cancelAction)
                #endif
            }
        }
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    AttachmentView()
}
