//
// Copyright © 2023 Alexander Romanov
// PhotosGalleryView.swift
//

import OversizePhotoComponents
import OversizeUI
import SwiftUI

public struct PhotosGalleryView: View {
    private let title: String
    private let images: [Image]
    @State private var isShowPhoto: Bool = false
    @State private var selection: Int = 0

    public init(title: String = "Photos", images: [Image]) {
        self.title = title
        self.images = images
    }

    public var body: some View {
        PageView(title) {
            if images.isEmpty {
                Text("Not photos")
                    .title3()
                    .onSurfaceHighEmphasisForegroundColor()
            } else {
                ImageGridView(images, columnCount: .constant(3)) { image in
                    let index = images.firstIndex(of: image)
                    selection = index ?? 0
                    isShowPhoto = true
                } longPressAction: { _ in }
            }
        }
        .leadingBar {
            BarButton(.back)
        }
        .photoOverlay(isPresent: $isShowPhoto, selection: $selection, photos: images)
    }
}

struct PhotosGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosGalleryView(images: [])
    }
}
