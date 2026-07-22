//
// Copyright © 2021 Alexander Romanov
// IconCircleView.swift
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
struct IconCircleView: View {
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
            Group {
                if let platformImage = selection {
                    #if canImport(UIKit) && !os(watchOS)
                    Image(uiImage: platformImage)
                    #elseif canImport(AppKit)
                    Image(nsImage: platformImage)
                    #endif
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

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
#Preview {
    #if canImport(UIKit) && !os(watchOS)
    IconCircleView(selection: .constant(nil), showModal: .constant(false))
    #endif
}
#endif
