//
// Copyright © 2021 Alexander Romanov
// IconPicker.swift, created on 02.04.2022
//

import OversizeUI
import SwiftUI

public enum IconPickerStyle {
    case field, circle
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct IconPicker: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    private let label: String
    private let icons: [Image]
    @Binding private var selection: Image?
    @State private var pendingIndex: Int?

    public init(_ label: String = "Icon", icons: [Image] = IconPickerIcons.defaultIcons, selection: Binding<Image?>) {
        self.label = label
        self.icons = icons
        _selection = selection
    }

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

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    
    @Previewable @State var selection: Image?
    
    NavigationStack {
        
        IconPicker(selection: $selection)
    }
}
