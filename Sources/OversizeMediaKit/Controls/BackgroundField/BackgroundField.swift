//
// Copyright © 2026 Alexander Romanov
// BackgroundField.swift
//

import OversizeUI
import SwiftUI

#if os(iOS)
@available(iOS 17.0, *)
public struct BackgroundField: View {
    @Binding private var selection: BackgroundPickerType
    @State private var isShowPicker = false

    private let presetImages: [UIImage]
    private let presetColors: [Color]
    private let presetGradients: [(startColor: Color, endColor: Color, direction: GradientDirection)]

    public init(
        _ selection: Binding<BackgroundPickerType>,
        images: [UIImage] = [],
        colors: [Color] = [],
        gradients: [(startColor: Color, endColor: Color, direction: GradientDirection)] = []
    ) {
        _selection = selection
        presetImages = images
        presetColors = colors
        presetGradients = gradients
    }

    public var body: some View {
        Button {
            isShowPicker.toggle()
        } label: {
            HStack {
                Text(selectionLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)

                thumbnail
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Color.border, lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.field)
        .animation(.default, value: selectionLabel)
        .sheet(isPresented: $isShowPicker) {
            NavigationStack {
                BackgroundPicker(
                    selection: $selection,
                    images: presetImages,
                    colors: presetColors,
                    gradients: presetGradients
                )
                .navigationTitle("Background")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnail: some View {
        switch selection {
        case let .image(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        case let .color(color):
            color
        case let .gradient(start, end, direction):
            LinearGradient(
                colors: [start, end],
                startPoint: direction.startPoint,
                endPoint: direction.endPoint
            )
        }
    }

    // MARK: - Label

    private var selectionLabel: String {
        switch selection {
        case .image: "Photo"
        case .color: "Color"
        case .gradient: "Gradient"
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    VStack {
        BackgroundField(.constant(.color(.blue)))
        BackgroundField(.constant(.gradient(startColor: .blue, endColor: .purple, direction: .topBottom)))
    }
    .padding()
}
#endif
