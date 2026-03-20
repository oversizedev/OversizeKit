//
// Copyright © 2023 Alexander Romanov
// ImageGalleryView.swift
//

import OversizeUI
import SwiftUI

public struct ImageGallery: View {
    private let title: String
    private let images: [Image]
    @State private var isShowPhoto: Bool = false
    @State private var selection: Int = 0

    public init(title: String = "Photos", images: [Image]) {
        self.title = title
        self.images = images
    }

    public var body: some View {
        LayoutView(title) {
            if images.isEmpty {
                Text("Not photos")
                    .title3()
                    .onSurfacePrimary()
            } else {
                ImageGridView(images, columnCount: .constant(3), tapAction: { index in
                    selection = index
                    isShowPhoto = true
                })
            }
        }
        #if os(iOS)
        .photoOverlay(isPresent: $isShowPhoto, selection: $selection, photos: images)
        #endif
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "ImageGallery")
public typealias ImageGalleryView = ImageGallery

@available(*, deprecated, renamed: "ImageGallery")
public typealias PhotosGalleryView = ImageGallery

#Preview {
    NavigationStack {
        ImageGallery(images: [])
    }
}
