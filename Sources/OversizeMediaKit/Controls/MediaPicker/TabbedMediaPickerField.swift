//
// Copyright © 2023 Alexander Romanov
// TabbedMediaPickerField.swift
//

import OversizeUI
import SwiftUI

#if os(iOS)
public struct TabbedMediaPickerField: View {
    @State private var isShowPicker: Bool = false

    @Binding var selectionPhotos: [UIImage]
    @Binding var selectionPhotosDate: [Date]
    @Binding var selectionURL: URL?

    public init(photos: Binding<[UIImage]>, photosDate: Binding<[Date]>, selectionURL: Binding<URL?>) {
        _selectionPhotos = photos
        _selectionPhotosDate = photosDate
        _selectionURL = selectionURL
    }

    public var body: some View {
        Button {
            isShowPicker.toggle()
        } label: {
            Text("Add photo")
        }
        .buttonStyle(.field)
        .sheet(isPresented: $isShowPicker) {
            TabbedMediaPicker(
                photos: $selectionPhotos,
                photosDate: $selectionPhotosDate,
                selectionURL: $selectionURL
            )
        }
    }
}
#endif
