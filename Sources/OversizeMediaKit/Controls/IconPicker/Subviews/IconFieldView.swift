//
// Copyright © 2021 Alexander Romanov
// IconFieldView.swift
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct IconFieldView: View {
    let label: String
    @Binding var selection: Image?
    @Binding var showModal: Bool

    var body: some View {
        Button {
            showModal.toggle()
        } label: {
            HStack(spacing: .xxSmall) {
                Text(label)
                    .onSurfacePrimary()

                Spacer()
                if let image = selection {
                    image
                }
                Image.Base.chevronDown.icon(.onSurfacePrimary)
            }
        }
        .buttonStyle(.field)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    IconFieldView(label: "Icon", selection: .constant(nil), showModal: .constant(false))
        .padding()
}
