//
// Copyright © 2022 Alexander Romanov
// ImageGridView.swift
//

import OversizeUI
import SwiftUI

public struct ImageGridView: View {
    @Environment(\.isLoading) var isLoading: Bool
    @Binding private var columnCount: Int
    private let images: [Image]
    private let tapAction: ((Image) -> Void)?
    private let longPressAction: ((Image) -> Void)?

    public init(
        _ images: [Image],
        columnCount: Binding<Int>,
        tapAction: ((Image) -> Void)? = nil,
        longPressAction: ((Image) -> Void)? = nil
    ) {
        self.images = images
        _columnCount = columnCount
        self.tapAction = tapAction
        self.longPressAction = longPressAction
    }

    public var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 40), spacing: 2), count: columnCount), alignment: .center, spacing: 2) {
            if isLoading {
                ForEach(0 ... 20, id: \.self) { _ in
                    Color.surfaceSecondary
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .contentShape(Rectangle())
                }
            } else {
                ForEach(0 ..< images.count, id: \.self) { index in
                    Color.clear
                        .background(
                            images[index]
                                .resizable()
                                .scaledToFill()
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            tapAction?(images[index])
                        }
                        .onLongPressGesture {
                            longPressAction?(images[index])
                        }
                }
            }
        }
        .padding(.vertical, .xxxSmall)
    }
}

#Preview {
    ScrollView {
        ImageGridView(
            [
                Image(systemName: "photo"),
                Image(systemName: "photo.fill"),
                Image(systemName: "photo.on.rectangle"),
                Image(systemName: "photo.on.rectangle.angled"),
                Image(systemName: "rectangle.on.rectangle"),
                Image(systemName: "photo.stack"),
            ],
            columnCount: .constant(4)
        )
    }
}
