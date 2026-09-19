//
// Copyright © 2026 Alexander Romanov
// MediaKitDemoView.swift, created on 06.09.2026
//

import OversizeMediaKit
import OversizeUI
import SwiftUI

struct MediaKitDemoView: View {
    @State private var emoji: String = "🚀"
    @State private var isShowEmojiPicker = false
    @State private var isShowGallery = false
    @State private var isShowSlider = false
    @State private var isShowPhotoOverlay = false
    @State private var sliderSelection: Int = 0
    @State private var overlaySelection: Int = 0
    @State private var gridColumnCount: Int = 3

    #if os(iOS)
    @State private var photo: UIImage?
    @State private var photos: [UIImage] = []
    @State private var photosDates: [Date] = []
    @State private var avatar: UIImage?
    @State private var icon: UIImage?
    @State private var background: BackgroundPickerType = .color(.accent)
    @State private var gradientStartColor: Color = .accent
    @State private var gradientEndColor: Color = .surfacePrimary
    @State private var gradientDirection: GradientDirection = .topBottom
    @State private var file: URL?
    @State private var mediaURL: URL?
    @State private var isShowPhotoLibraryPicker = false
    @State private var isShowIconPicker = false
    @State private var isShowGradientPicker = false
    @State private var isShowFilePicker = false
    @State private var isShowMediaPicker = false
    #endif

    private let emojis: [String] = ["🚀", "📦", "🎨", "🧭", "🔔", "📸"]

    private let demoImages: [Image] = [
        Image(systemName: "photo"),
        Image(systemName: "camera"),
        Image(systemName: "paintpalette"),
        Image(systemName: "sparkles"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                fields

                screens

                SectionView("Grid") {
                    ImageGridView(demoImages, columnCount: $gridColumnCount, itemOverlay: { _, _ in
                        EmptyView()
                    }, tapAction: { index in
                        overlaySelection = index
                        isShowPhotoOverlay = true
                    })
                }
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Media")
        .photoOverlay(isPresent: $isShowPhotoOverlay, selection: $overlaySelection, photos: demoImages)
        .sheet(isPresented: $isShowEmojiPicker) {
            NavigationStack {
                EmojiPicker("Emoji", emojis: emojis, selection: $emoji)
            }
        }
        .sheet(isPresented: $isShowGallery) {
            NavigationStack {
                ImageGallery(images: demoImages)
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $isShowSlider) {
            ImageSlider(selection: $sliderSelection, photos: demoImages) {
                isShowSlider = false
            }
        }
        .sheet(isPresented: $isShowPhotoLibraryPicker) {
            NavigationStack {
                PhotoLibraryPicker(selection: $photo)
            }
        }
        .sheet(isPresented: $isShowIconPicker) {
            NavigationStack {
                IconPicker(selection: $icon)
            }
        }
        .sheet(isPresented: $isShowGradientPicker) {
            NavigationStack {
                GradientPicker(
                    startColor: $gradientStartColor,
                    endColor: $gradientEndColor,
                    direction: $gradientDirection
                )
            }
        }
        .sheet(isPresented: $isShowFilePicker) {
            NavigationStack {
                FilePicker(url: $file)
            }
        }
        .sheet(isPresented: $isShowMediaPicker) {
            NavigationStack {
                MediaPicker(photos: $photos, photosDate: $photosDates, selectionURL: $mediaURL) {
                    EmptyView()
                }
            }
        }
        #endif
    }

    private var fields: some View {
        SectionView("Fields") {
            VStack(spacing: .small) {
                EmojiField("Icon", emojis: emojis, selection: $emoji)
                    .iconPickerStyle(.circle)

                #if os(iOS)
                PhotoField($photo)

                PhotosField($photos, selectionDate: $photosDates)

                IconField("Icon image", selection: $icon)

                BackgroundField($background)

                TabbedMediaPickerField(photos: $photos, photosDate: $photosDates, selectionURL: $mediaURL)

                AvatarPicker(avatar: $avatar)
                #endif
            }
        }
    }

    private var screens: some View {
        SectionView("Screens") {
            VStack(spacing: .zero) {
                Row("Emoji picker", subtitle: emoji) {
                    isShowEmojiPicker = true
                } leading: {
                    Image(systemName: "face.smiling")
                }
                .navigatable()
                .buttonStyle(.row)

                Row("Gallery") {
                    isShowGallery = true
                } leading: {
                    Image(systemName: "square.grid.2x2")
                }
                .navigatable()
                .buttonStyle(.row)

                #if os(iOS)
                Row("Slider") {
                    sliderSelection = 0
                    isShowSlider = true
                } leading: {
                    Image(systemName: "rectangle.stack")
                }
                .navigatable()
                .buttonStyle(.row)

                Row("Photo library") {
                    isShowPhotoLibraryPicker = true
                } leading: {
                    Image(systemName: "photo.on.rectangle")
                }
                .navigatable()
                .buttonStyle(.row)

                Row("Icon picker") {
                    isShowIconPicker = true
                } leading: {
                    Image(systemName: "app")
                }
                .navigatable()
                .buttonStyle(.row)

                Row("Gradient picker") {
                    isShowGradientPicker = true
                } leading: {
                    Image(systemName: "paintbrush")
                }
                .navigatable()
                .buttonStyle(.row)

                Row("File picker", subtitle: file?.lastPathComponent) {
                    isShowFilePicker = true
                } leading: {
                    Image(systemName: "folder")
                }
                .navigatable()
                .buttonStyle(.row)

                Row("Media picker") {
                    isShowMediaPicker = true
                } leading: {
                    Image(systemName: "photo.badge.plus")
                }
                .navigatable()
                .buttonStyle(.row)
                #endif
            }
        }
        .sectionContentCompactRowMargins()
    }
}

#Preview {
    NavigationStack {
        MediaKitDemoView()
    }
    .appEnvironment()
}
