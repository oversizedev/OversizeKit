//
// Copyright © 2021 Alexander Romanov
// IconField.swift, created on 02.04.2022
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct IconField: View {

    private let label: String
    private let icons: [Image]
    @Binding private var selection: Image?
    @State private var showModal = false

    var style: IconPickerStyle = .field

    public init(
        _ label: String,
        icons: [Image] = IconPickerIcons.defaultIcons,
        selection: Binding<Image?>
    ) {
        self.label = label
        self.icons = icons
        _selection = selection
    }

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

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension IconField {
    func iconPickerStyle(_ style: IconPickerStyle) -> Self {
        var control = self
        control.style = style
        return control
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    IconField("Choose icon", selection: .constant(nil))
        .padding()
}
