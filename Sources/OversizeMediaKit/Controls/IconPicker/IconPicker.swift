//
// Copyright © 2021 Alexander Romanov
// IconPicker.swift, created on 02.04.2022
//

import OversizeUI
import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum IconPickerStyle {
    case field, circle
}

#if (canImport(UIKit) && !os(watchOS)) || canImport(AppKit)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
public struct IconPicker: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    private let label: String
    #if canImport(UIKit) && !os(watchOS)
    private let icons: [UIImage]
    @Binding private var selection: UIImage?
    #elseif canImport(AppKit)
    private let icons: [NSImage]
    @Binding private var selection: NSImage?
    #endif
    @State private var pendingIndex: Int?

    #if canImport(UIKit) && !os(watchOS)
    public init(_ label: String = "Icon", icons: [UIImage] = IconPickerIcons.defaultIcons, selection: Binding<UIImage?>) {
        self.label = label
        self.icons = icons
        _selection = selection
    }

    #elseif canImport(AppKit)
    public init(_ label: String = "Icon", icons: [NSImage] = IconPickerIcons.defaultIcons, selection: Binding<NSImage?>) {
        self.label = label
        self.icons = icons
        _selection = selection
    }
    #endif

    public var body: some View {
        LayoutView(label) {
            SectionView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 58))]) {
                    ForEach(icons.indices, id: \.self) { index in
                        IconPickerButton(
                            icon: icons[index],
                            isSelected: pendingIndex == index,
                            action: {
                                withAnimation(.interactiveSpring) {
                                    pendingIndex = index
                                }
                            }
                        )
                    }
                }
            }
            .surfaceContentMargins(.small)
            .surfaceRadius(.regular)
            .sectionViewStyle(.smallIndent)
        } background: {
            Color.backgroundSecondary
        }
        .navigationTitle(label)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", role: .cancel) {
                    pendingIndex = nil
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    if let index = pendingIndex, icons.indices.contains(index) {
                        selection = icons[index]
                    }
                    pendingIndex = nil
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarPrimary)
            }
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
#Preview {
    #if canImport(UIKit) && !os(watchOS)
    NavigationStack {
        IconPicker(selection: .constant(nil))
    }
    #endif
}
#endif
