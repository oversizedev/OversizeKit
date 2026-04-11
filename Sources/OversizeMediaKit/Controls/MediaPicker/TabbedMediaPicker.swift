//
// Copyright © 2023 Alexander Romanov
// TabbedMediaPicker.swift
//

import OversizeUI
import SwiftUI

#if os(iOS)
public struct TabbedMediaPicker: View {
    @Binding var selectionPhotos: [UIImage]
    @Binding var selectionPhotosDate: [Date]
    @Binding var selectionURL: URL?

    public init(photos: Binding<[UIImage]>, photosDate: Binding<[Date]>, selectionURL: Binding<URL?>) {
        _selectionPhotos = photos
        _selectionPhotosDate = photosDate
        _selectionURL = selectionURL
    }

    public var body: some View {
        TabView {
            NavigationStack {
                PhotoLibraryPicker(selection: $selectionPhotos, dates: $selectionPhotosDate)
            }
            .tabItem {
                Label {
                    Text("Gallery")
                } icon: {
                    Image.Base.camera
                        .renderingMode(.template)
                }
            }

            NavigationStack {
                FilePicker(url: $selectionURL)
            }
            .tabItem {
                Label {
                    Text("File")
                } icon: {
                    Image.Base.folder
                        .renderingMode(.template)
                }
            }
        }
    }
}
#endif
