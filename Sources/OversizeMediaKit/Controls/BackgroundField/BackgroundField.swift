//
// Copyright © 2026 Alexander Romanov
// BackgroundField.swift
//

import OversizeUI
import SwiftUI

#if os(iOS)
@available(iOS 17.0, *)
public struct BackgroundField: View {
    @Binding private var selection: BackgroundPickerResult
    @State private var isShowPicker = false

    public init(_ selection: Binding<BackgroundPickerResult>) {
        _selection = selection
    }

    public var body: some View {
        Button {
            isShowPicker.toggle()
        } label: {
            HStack {
                Text(selectionLabel)

                Spacer()

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
                BackgroundPicker(selection: $selection)
                    .navigationTitle("Background")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnail: some View {
        switch selection {
        case let .builtIn(bg):
            bg.gradient
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
        case let .builtIn(bg): bg.rawValue.capitalized
        case .image: "Photo"
        case .color: "Color"
        case .gradient: "Gradient"
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    VStack {
        BackgroundField(.constant(.builtIn(.ocean)))
        BackgroundField(.constant(.color(.blue)))
        BackgroundField(.constant(.gradient(startColor: .blue, endColor: .purple, direction: .topBottom)))
    }
    .padding()
}
#endif
