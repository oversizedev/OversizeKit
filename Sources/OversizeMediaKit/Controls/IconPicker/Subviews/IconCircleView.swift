//
// Copyright © 2021 Alexander Romanov
// IconCircleView.swift
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct IconCircleView: View {
    @Binding var selection: Image?
    @Binding var showModal: Bool

    var body: some View {
        Button {
            showModal.toggle()
        } label: {
            Group {
                if let image = selection {
                    image
                } else {
                    Image.Base.edit.icon(size: .large)
                }
            }
            .padding(.xxSmall)
        }
        .buttonStyle(.iconTertiary)
        .controlSize(.extraLarge)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    IconCircleView(selection: .constant(nil), showModal: .constant(false))
}
