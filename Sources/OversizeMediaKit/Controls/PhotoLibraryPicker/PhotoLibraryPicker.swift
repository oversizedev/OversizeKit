//
// Copyright © 2023 Alexander Romanov
// PhotoLibraryPicker.swift
//

import OversizeComponents
import OversizeLocalizable
import OversizeUI
import PhotosUI
import SwiftUI

#if os(iOS)
@available(iOS 17.0, *)
public struct PhotoLibraryPicker: View {
    @Environment(\.dismiss) var dismiss

    private var isCameraHidden: Bool = false

    @State var galleryImages: [PHAsset] = []
    @State private var cameraImage: UIImage = .init()
    @State var isShowCamera: Bool = false
    @State var isImportingPhotos: Bool = false
    @State var importProgress = 0.0
    @State private var selectedAssets: [PHAsset] = []
    @State private var isShimmering: Bool = false

    @Binding var selection: UIImage?
    @Binding var selectionDate: Date?
    @Binding private var multiSelection: [UIImage]
    @Binding private var multiSelectionDates: [Date]

    private let isMultiMode: Bool

    private let threeColumnGrid = [
        GridItem(.flexible(minimum: 40), spacing: 2),
        GridItem(.flexible(minimum: 40), spacing: 2),
        GridItem(.flexible(minimum: 40), spacing: 2),
    ]

    public init(selection: Binding<UIImage?>, date: Binding<Date?> = .constant(nil)) {
        _selection = selection
        _selectionDate = date
        _multiSelection = .constant([])
        _multiSelectionDates = .constant([])
        isMultiMode = false
    }

    public init(selection: Binding<[UIImage]>, dates: Binding<[Date]>, preselected: [PHAsset] = []) {
        _selection = .constant(nil)
        _selectionDate = .constant(nil)
        _multiSelection = selection
        _multiSelectionDates = dates
        _selectedAssets = State(initialValue: preselected)
        isMultiMode = true
    }

    public var body: some View {
        LayoutView("Gallery") {
            content()
                .disabled(isImportingPhotos)
                .opacity(isImportingPhotos ? 0.6 : 1)
                .onAppear {
                    getImages()
                    isShimmering = true
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) { dismiss() }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
            }
            ToolbarItem(placement: .primaryAction) {
                if isMultiMode {
                    if isImportingPhotos {
                        ProgressView()
                    } else if !selectedAssets.isEmpty {
                        Button("\(L10n.Button.add) (\(selectedAssets.count))", systemImage: "plus") {
                            Task { await importMultiplePhotos() }
                        }
                        .labelStyle(.toolbar)
                        .buttonStyle(.toolbarPrimary)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowCamera, onDismiss: {
            if isMultiMode {
                multiSelection.append(cameraImage)
                multiSelectionDates.append(Date())
            } else {
                selection = cameraImage
            }
            dismiss()
        }) {
            ImagePicker(sourceType: .camera, selectedImage: $cameraImage)
                .ignoresSafeArea(.all)
        }
    }

    private func content() -> some View {
        LazyVGrid(columns: threeColumnGrid, alignment: .center, spacing: 2) {
            if !isCameraHidden {
                Button {
                    isShowCamera.toggle()
                } label: {
                    ZStack {
                        CameraPreviewView()
                        Circle()
                            .fill(.black.opacity(0.2))
                            .frame(width: 48, height: 48)
                        Image.Base.Camera.fill
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    }
                    .frame(minHeight: galleryImages.count > 0 ? nil : 200)
                }
                .buttonStyle(.scale)
            }

            if galleryImages.isEmpty {
                ForEach(0 ..< 20, id: \.self) { _ in
                    placeholderCell
                }
            } else {
                ForEach(galleryImages, id: \.self) { asset in
                    if isMultiMode {
                        multiSelectCell(asset: asset)
                    } else {
                        singleSelectCell(asset: asset)
                    }
                }
            }
        }
    }

    private var placeholderCell: some View {
        Color.surfaceSecondary
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .opacity(isShimmering ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isShimmering)
    }

    private func singleSelectCell(asset: PHAsset) -> some View {
        Color.clear
            .background(
                Image(uiImage: getThumbnailFromAsset(asset: asset))
                    .resizable()
                    .scaledToFill()
            )
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .contentShape(Rectangle())
            .overlay {
                if isImportingPhotos {
                    ProgressView()
                }
            }
            .onTapGesture {
                Task { await importPhoto(asset) }
            }
    }

    private func multiSelectCell(asset: PHAsset) -> some View {
        let isSelected = selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier })
        return Color.clear
            .background(
                Image(uiImage: getThumbnailFromAsset(asset: asset))
                    .resizable()
                    .scaledToFill()
            )
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .contentShape(Rectangle())
            .overlay(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: .xxSmall, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .shadow(radius: 4)
                        .opacity(isSelected ? 0 : 1)

                    RoundedRectangle(cornerRadius: .xxSmall, style: .continuous)
                        .fill(Color.accent)
                        .frame(width: 24, height: 24)
                        .opacity(isSelected ? 1 : 0)

                    Image(systemName: "checkmark")
                        .font(.caption.weight(.black))
                        .foregroundColor(.onPrimary)
                        .opacity(isSelected ? 1 : 0)
                }
                .padding(.all, .xxSmall)
            }
            .onTapGesture {
                toggleSelection(asset)
            }
    }

    // MARK: - Selection

    private func toggleSelection(_ asset: PHAsset) {
        if let idx = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            selectedAssets.remove(at: idx)
        } else {
            selectedAssets.append(asset)
        }
    }

    // MARK: - Import

    @MainActor
    func importPhoto(_ asset: PHAsset) async {
        isImportingPhotos = true
        selection = getFullImageFromAsset(asset: asset)
        selectionDate = asset.creationDate
        dismiss()
    }

    @MainActor
    func importMultiplePhotos() async {
        isImportingPhotos = true
        let images = selectedAssets.map { getFullImageFromAsset(asset: $0) }
        let dates = selectedAssets.map { $0.creationDate ?? Date() }
        multiSelection += images
        multiSelectionDates += dates
        dismiss()
    }

    func incrementImportCounter() {
        importProgress += 1
    }

    func getThumbnailFromAsset(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option: PHImageRequestOptions = .init()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: option) { result, _ in
            thumbnail = result!
        }
        return thumbnail
    }

    func getFullImageFromAsset(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option: PHImageRequestOptions = .init()
        var thumbnail = UIImage()
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        option.resizeMode = .none
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option) { result, _ in
            thumbnail = result!
        }
        incrementImportCounter()
        return thumbnail
    }

    func getImages() {
        Task {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            guard status == .authorized || status == .limited else { return }
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 25000
            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            var images: [PHAsset] = []
            assets.enumerateObjects { object, _, _ in
                images.append(object)
            }
            await MainActor.run {
                galleryImages = images
            }
        }
    }
}

// MARK: - Modifiers

@available(iOS 17.0, *)
public extension PhotoLibraryPicker {
    func hideCamera(_ hidden: Bool = true) -> Self {
        var view = self
        view.isCameraHidden = hidden
        return view
    }
}

// MARK: - Deprecated

@available(iOS 17.0, *)
@available(*, deprecated, renamed: "PhotoLibraryPicker")
public typealias GalleryPhotoPicker = PhotoLibraryPicker

@available(iOS 17.0, *)
#Preview("Single selection") {
    NavigationStack {
        PhotoLibraryPicker(selection: .constant(nil))
    }
}

@available(iOS 17.0, *)
#Preview("Multi selection") {
    NavigationStack {
        PhotoLibraryPicker(selection: .constant([]), dates: .constant([]))
    }
}

#endif
