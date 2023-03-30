//
// Copyright © 2023 Alexander Romanov
// PhotoViewerView.swift
//

import SwiftUI

import OversizePhotoComponents
import OversizeUI
import SwiftUI

public struct PhotoViewerView: View {
    private let title: String
    private let images: [Image]
    @State private var isShowPhoto: Bool = false
    @Binding private var selection: Int

    public init(_ title: String = "Photos", selection: Binding<Int>, images: [Image]) {
        self.title = title
        self.images = images
        _selection = selection
    }

    public var body: some View {
//        PageView(title) {
        VStack(spacing: 0) {
//            ModalNavigationBar(title: title) {
//                BarButton(.back)
//            }
            if images.isEmpty {
                Text("Not photos")
                    .title3()
                    .onSurfaceHighEmphasisForegroundColor()
            } else {
                PhotoSliderView(selection: $selection, photos: images)
            }
        }
//        .leadingBar {
//            BarButton(.back)
//        }
    }
}

// struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
// }
