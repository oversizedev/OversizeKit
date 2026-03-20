//
// Copyright © 2022 Alexander Romanov
// ImageGridView.swift
//

import OversizeUI
import SwiftUI

public struct ImageGridView<ItemOverlay: View>: View {
    @Environment(\.isLoading) private var isLoading: Bool
    @Binding private var columnCount: Int
    private let images: [Image]
    private let itemOverlay: (Int, Image) -> ItemOverlay
    private let tapAction: ((Int) -> Void)?
    private let longPressAction: ((Int) -> Void)?

    public init(
        _ images: [Image],
        columnCount: Binding<Int>,
        @ViewBuilder itemOverlay: @escaping (Int, Image) -> ItemOverlay,
        tapAction: ((Int) -> Void)? = nil,
        longPressAction: ((Int) -> Void)? = nil
    ) {
        self.images = images
        _columnCount = columnCount
        self.itemOverlay = itemOverlay
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
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    Color.clear
                        .background(
                            image
                                .resizable()
                                .scaledToFill()
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .contentShape(Rectangle())
                        .overlay { itemOverlay(index, image) }
                        .photoOverlaySource(id: index)
                        .onTapGesture { tapAction?(index) }
                        .onLongPressGesture { longPressAction?(index) }
                }
            }
        }
        .padding(.vertical, .xxxSmall)
    }
}

public extension ImageGridView where ItemOverlay == EmptyView {
    init(
        _ images: [Image],
        columnCount: Binding<Int>,
        tapAction: ((Int) -> Void)? = nil,
        longPressAction: ((Int) -> Void)? = nil
    ) {
        self.images = images
        _columnCount = columnCount
        itemOverlay = { _, _ in EmptyView() }
        self.tapAction = tapAction
        self.longPressAction = longPressAction
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
