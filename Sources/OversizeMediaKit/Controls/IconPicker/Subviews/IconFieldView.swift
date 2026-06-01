//
// Copyright © 2021 Alexander Romanov
// IconFieldView.swift
//

import OversizeUI
import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if (canImport(UIKit) && !os(watchOS)) || canImport(AppKit)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
struct IconFieldView: View {
    let label: String
    #if canImport(UIKit) && !os(watchOS)
    @Binding var selection: UIImage?
    #elseif canImport(AppKit)
    @Binding var selection: NSImage?
    #endif
    @Binding var showModal: Bool

    var body: some View {
        Button {
            showModal.toggle()
        } label: {
            HStack(spacing: .xxSmall) {
                Text(label)
                    .onSurfacePrimary()

                Spacer()
                if let platformImage = selection {
                    #if canImport(UIKit) && !os(watchOS)
                    Icon(Image(uiImage: platformImage))
                    #elseif canImport(AppKit)
                    Icon(Image(nsImage: platformImage))
                    #endif
                }
                Image.Base.chevronDown.icon(.onSurfacePrimary)
            }
        }
        .buttonStyle(.field)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
#Preview {
    #if canImport(UIKit) && !os(watchOS)
    IconFieldView(label: "Icon", selection: .constant(nil), showModal: .constant(false))
        .padding()
    #endif
}
#endif
