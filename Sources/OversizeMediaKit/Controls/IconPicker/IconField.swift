//
// Copyright © 2021 Alexander Romanov
// IconField.swift, created on 02.04.2022
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
public struct IconField: View {
    private let label: String
    #if canImport(UIKit) && !os(watchOS)
    private let icons: [UIImage]
    @Binding private var selection: UIImage?
    #elseif canImport(AppKit)
    private let icons: [NSImage]
    @Binding private var selection: NSImage?
    #endif
    @State private var showModal = false

    var style: IconPickerStyle = .field

    #if canImport(UIKit) && !os(watchOS)
    public init(
        _ label: String,
        icons: [UIImage] = IconPickerIcons.defaultIcons,
        selection: Binding<UIImage?>
    ) {
        self.label = label
        self.icons = icons
        _selection = selection
    }

    #elseif canImport(AppKit)
    public init(
        _ label: String,
        icons: [NSImage] = IconPickerIcons.defaultIcons,
        selection: Binding<NSImage?>
    ) {
        self.label = label
        self.icons = icons
        _selection = selection
    }
    #endif

    public var body: some View {
        Group {
            switch style {
            case .field:
                IconFieldView(label: label, selection: $selection, showModal: $showModal)
            case .circle:
                IconCircleView(selection: $selection, showModal: $showModal)
            }
        }
        .sheet(isPresented: $showModal) {
            NavigationStack {
                IconPicker(label, icons: icons, selection: $selection)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
public extension IconField {
    func iconPickerStyle(_ style: IconPickerStyle) -> Self {
        var control = self
        control.style = style
        return control
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
#Preview {
    #if canImport(UIKit) && !os(watchOS)
    IconField("Choose icon", selection: .constant(nil))
        .padding()
    #endif
}
#endif
