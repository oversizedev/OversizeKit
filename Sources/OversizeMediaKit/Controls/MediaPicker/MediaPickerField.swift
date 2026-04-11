//
// Copyright © 2023 Alexander Romanov
// MediaPickerField.swift
//

import OversizeUI
import SwiftUI

#if os(iOS)
public struct MediaPickerField<CustomSection: View>: View {
    @State private var isShowPicker: Bool = false

    @Binding var selectionPhotos: [UIImage]
    @Binding var selectionPhotosDate: [Date]
    @Binding var selectionURL: URL?

    private let customSection: CustomSection?

    public init(
        photos: Binding<[UIImage]>,
        photosDate: Binding<[Date]>,
        selectionURL: Binding<URL?>,
        @ViewBuilder customSection: () -> CustomSection
    ) {
        _selectionPhotos = photos
        _selectionPhotosDate = photosDate
        _selectionURL = selectionURL
        self.customSection = customSection()
    }

    public var body: some View {
        Button {
            isShowPicker.toggle()
        } label: {
            Text("Add media")
        }
        .buttonStyle(.field)
        .sheet(isPresented: $isShowPicker) {
            NavigationStack {
                MediaPicker(
                    photos: $selectionPhotos,
                    photosDate: $selectionPhotosDate,
                    selectionURL: $selectionURL
                ) {
                    customSection
                }
                .scrollDisabled(true)
                .presentationDetents(customSection == nil ? [.height(430)] : [.medium, .large])
            }
        }
    }
}

// MARK: - Convenience init

public extension MediaPickerField where CustomSection == EmptyView {
    init(photos: Binding<[UIImage]>, photosDate: Binding<[Date]>, selectionURL: Binding<URL?>) {
        _selectionPhotos = photos
        _selectionPhotosDate = photosDate
        _selectionURL = selectionURL
        customSection = nil
    }
}

#Preview {
    MediaPickerField(
        photos: .constant([]),
        photosDate: .constant([]),
        selectionURL: .constant(nil)
    )
    .padding()
}
#endif
