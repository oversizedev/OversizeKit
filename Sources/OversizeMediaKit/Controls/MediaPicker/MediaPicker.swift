//
// Copyright © 2023 Alexander Romanov
// MediaPicker.swift
//

import OversizeComponents
import OversizeUI
import Photos
import SwiftUI

#if os(iOS)
public struct MediaPicker<CustomSection: View>: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isShowCamera: Bool = false
    @State private var isShowGallery: Bool = false
    @State private var isShowDocumentPicker: Bool = false
    @State private var isShowScanner: Bool = false
    @State private var galleryImages: [PHAsset] = []
    @State private var selectedAssets: [PHAsset] = []
    @State private var cameraImage: UIImage = .init()
    @State private var isShimmering: Bool = false
    @State private var isGallerySelectionConfirmed: Bool = false

    @Binding var selectionPhotos: [UIImage]
    @Binding var selectionPhotosDate: [Date]
    @Binding var selectionURL: URL?

    private let onPhotosSelected: (([UIImage], [Date]) -> Void)?
    private var customSection: CustomSection?

    public init(
        photos: Binding<[UIImage]>,
        photosDate: Binding<[Date]>,
        selectionURL: Binding<URL?>,
        onPhotosSelected: (([UIImage], [Date]) -> Void)? = nil,
        @ViewBuilder customSection: () -> CustomSection
    ) {
        _selectionPhotos = photos
        _selectionPhotosDate = photosDate
        _selectionURL = selectionURL
        self.onPhotosSelected = onPhotosSelected
        self.customSection = customSection()
    }

    public var body: some View {
        LayoutView("Select media") {
            LeadingVStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: .small) {
                        Button {
                            cameraImage = UIImage()
                            isShowCamera.toggle()
                        } label: {
                            ZStack {
                                CameraPreviewView()
                                Circle()
                                    .fill(.black.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                Image.Base.camera
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 112, height: 112)
                            .clipped()
                            .cornerRadius(.small)
                        }
                        .buttonStyle(.plain)

                        if galleryImages.isEmpty {
                            ForEach(0 ..< 6, id: \.self) { _ in
                                placeholderCell
                            }
                        } else {
                            ForEach(galleryImages, id: \.self) { asset in
                                galleryCell(asset: asset)
                            }
                        }

                        Button {
                            isShowGallery = true
                        } label: {
                            ZStack {
                                Color.surfacePrimary

                                VStack(spacing: .xSmall) {
                                    Image.Base.category.iconOnSurface()

                                    Text("All photos")
                                        .subheadline(.semibold)
                                        .onSurfacePrimary()
                                }
                            }
                            .frame(width: 112, height: 112)
                            .clipped()
                            .cornerRadius(.small)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, .medium)
                }

                SectionView {
                    LeadingVStack {
                        Row(
                            "Photo library",
                            action: { isShowGallery = true },
                            leading: { Image.Base.picture.iconOnSurface() }
                        )
                        Row(
                            "Document",
                            action: { isShowDocumentPicker = true },
                            leading: { Image.Base.folder.iconOnSurface() }
                        )
                        Row(
                            "Scan document",
                            action: { isShowScanner = true },
                            leading: { Image.Base.scan.iconOnSurface() }
                        )

                        customSection
                    }
                }
                .sectionContentCompactRowMargins()
            }
        } background: {
            Color.backgroundSecondary
        }
        .onAppear {
            loadGalleryImages()
            isShimmering = true
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
            }
            ToolbarItem(placement: .primaryAction) {
                if !selectedAssets.isEmpty {
                    Button("Add (\(selectedAssets.count))", systemImage: "checkmark") {
                        importSelectedAssets()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarPrimary)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowCamera, onDismiss: {
            if cameraImage.size != .zero {
                appendPhotos([cameraImage], dates: [Date()])
                dismiss()
            }
        }) {
            ImagePicker(sourceType: .camera, selectedImage: $cameraImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $isShowGallery, onDismiss: {
            selectedAssets = []
            if isGallerySelectionConfirmed {
                isGallerySelectionConfirmed = false
                dismiss()
            }
        }) {
            NavigationStack {
                PhotoLibraryPicker(
                    selection: $selectionPhotos,
                    dates: $selectionPhotosDate,
                    preselected: selectedAssets,
                    onSelect: { photos, dates in
                        isGallerySelectionConfirmed = true
                        onPhotosSelected?(photos, dates)
                    }
                )
                .hideCamera()
            }
        }
        .fileImporter(
            isPresented: $isShowDocumentPicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let picked = urls.first {
                let accessing = picked.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        picked.stopAccessingSecurityScopedResource()
                    }
                }
                selectionURL = persistentCopy(of: picked)
                dismiss()
            }
        }
        .fullScreenCover(isPresented: $isShowScanner) {
            DocumentScanner(selectedURL: $selectionURL) {
                isShowScanner = false
                dismiss()
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Placeholder

    private var placeholderCell: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.surfaceSecondary)
            .frame(width: 112, height: 112)
            .opacity(isShimmering ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isShimmering)
    }

    // MARK: - Gallery cell

    @ViewBuilder
    private func galleryCell(asset: PHAsset) -> some View {
        let isSelected = selectedAssets.contains(where: { $0.localIdentifier == asset.localIdentifier })
        Button {
            toggleSelection(asset)
        } label: {
            Image(uiImage: getThumbnail(asset: asset))
                .resizable()
                .scaledToFill()
                .frame(width: 112, height: 112)
                .clipped()
                .cornerRadius(.small)
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
                    .padding(.xxSmall)
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selection

    private func toggleSelection(_ asset: PHAsset) {
        if let idx = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            selectedAssets.remove(at: idx)
        } else {
            selectedAssets.append(asset)
        }
    }

    private func importSelectedAssets() {
        let images = selectedAssets.map { getFullImage(asset: $0) }
        let dates = selectedAssets.map { $0.creationDate ?? Date() }
        appendPhotos(images, dates: dates)
        dismiss()
    }

    private func appendPhotos(_ photos: [UIImage], dates: [Date]) {
        selectionPhotos.append(contentsOf: photos)
        selectionPhotosDate.append(contentsOf: dates)
        onPhotosSelected?(photos, dates)
    }

    // MARK: - Helpers

    private func persistentCopy(of url: URL) -> URL {
        let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MediaPickerRecents", isDirectory: true)
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        let destination = supportDir
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(url.pathExtension)
        try? FileManager.default.copyItem(at: url, to: destination)
        return destination
    }

    private func loadGalleryImages() {
        Task {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            guard status == .authorized || status == .limited else { return }
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 20
            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            var images: [PHAsset] = []
            assets.enumerateObjects { object, _, _ in images.append(object) }
            await MainActor.run { galleryImages = images }
        }
    }

    private func getThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        var result = UIImage()
        manager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option) { img, _ in
            if let img {
                result = img
            }
        }
        return result
    }

    private func getFullImage(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        option.resizeMode = .none
        var result = UIImage()
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option) { img, _ in
            if let img {
                result = img
            }
        }
        return result
    }
}

// MARK: - Convenience init

public extension MediaPicker where CustomSection == EmptyView {
    init(photos: Binding<[UIImage]>, photosDate: Binding<[Date]>, selectionURL: Binding<URL?>) {
        self.init(photos: photos, photosDate: photosDate, selectionURL: selectionURL) { EmptyView() }
        customSection = nil
    }
}

#Preview {
    NavigationStack {
        MediaPicker(
            photos: .constant([]),
            photosDate: .constant([]),
            selectionURL: .constant(nil)
        )
    }
}
#endif
