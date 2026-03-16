//
// Copyright © 2022 Alexander Romanov
// PhotoOverlayModifier.swift
//

import OversizeCore
import OversizeUI
import SwiftUI

#if os(iOS)
public struct PhotoOverlayModifier: ViewModifier {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.theme) private var theme

    @State private var currentScale: CGFloat = 1.0
    @State private var previousScale: CGFloat = 1.0

    @State private var currentOffset = CGSize.zero
    @State private var previousOffset = CGSize.zero

    @State private var isShowOptions: Bool = true

    @Binding private var selectionIndex: Int
    private let photos: [Image]

    @Binding private var isShowPhotoDetail: Bool

    private let action: (() -> Void)?

    public init(isPresent: Binding<Bool>, selection: Binding<Int>, photos: [Image], action: (() -> Void)? = nil) {
        _selectionIndex = selection
        self.photos = photos
        _isShowPhotoDetail = isPresent
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isShowPhotoDetail ? 0.95 : 1)
            .overlay {
                TabView(selection: $selectionIndex) {
                    ForEach(0 ..< photos.count, id: \.self) { index in
                        photoWithOptions(image: photos[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .ignoresSafeArea(.all)
                .background(.black.opacity(backgroundOpacity))
                .opacity(isShowPhotoDetail ? 1 : 0)
                .safeAreaInset(edge: .top) {
                    HStack {
                        Button {
                            withAnimation {
                                isShowPhotoDetail = false
                            }
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .labelStyle(.toolbar)
                        .buttonStyle(.toolbarSecondary)

                        Spacer()

                        Text("\(selectionIndex + 1) of \(photos.count)")
                            .foregroundStyle(.white)
                            .font(.headline)

                        Spacer()

                        if let action {
                            Button(action: action) {
                                Label("More", systemImage: "ellipsis")
                            }
                            .labelStyle(.toolbar)
                            .buttonStyle(.toolbarSecondary)
                        } else {
                            Spacer().frame(width: 44)
                        }
                    }
                    .padding()
                    .opacity(isShowOptions ? 1 : 0)
                    .background(.black.opacity(isShowOptions ? 0.1 : 0))
                    .opacity(optionsOpacity)
                }
                .statusBar(hidden: isShowPhotoDetail)
                .colorScheme(.dark)
            }
    }

    func photoWithOptions(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .offset(x: currentOffset.width, y: currentOffset.height)
            .scaleEffect(max(currentScale, 0.01))
            .gesture(tapGestue.sequenced(before: doubleTapGestue))
            .simultaneousGesture(dragGestue)
            .gesture(magnificationGesture)
    }

    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / previousScale
                previousScale = value
                currentScale = currentScale * delta
            }
            .onEnded { value in
                if value < 0.2 {
                    currentScale = 1.0
                    hide()
                } else if value < 1 {
                    withAnimation {
                        currentScale = 1.0
                        currentOffset = CGSize.zero
                    }
                }
                previousScale = 1.0
            }
    }

    var doubleTapGestue: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    currentScale = 1.0
                    previousScale = 1.0
                    currentOffset = CGSize.zero
                    previousOffset = CGSize.zero
                }
            }
    }

    var tapGestue: some Gesture {
        TapGesture()
            .onEnded {
                isShowOptions.toggle()
            }
    }

    var dragGestue: some Gesture {
        DragGesture(minimumDistance: currentScale > 1.2 ? 0 : 20, coordinateSpace: .local)
            .onChanged { value in
                let deltaX = value.translation.width - previousOffset.width
                let deltaY = value.translation.height - previousOffset.height
                previousOffset.width = value.translation.width
                previousOffset.height = value.translation.height

                let newOffsetWidth = currentOffset.width + deltaX / currentScale
                if newOffsetWidth <= screenSize.width - 150.0, newOffsetWidth > -150.0, currentScale > 1 {
                    currentOffset.width = currentOffset.width + deltaX / currentScale
                }

                currentOffset.height = currentOffset.height + deltaY / currentScale
            }
            .onEnded { _ in
                previousOffset = CGSize.zero
                if currentOffset.height > screenSize.height / 5 ||
                    currentOffset.height < -(screenSize.height / 5)
                {
                    hide()
                } else {
                    if currentScale < 1.2 {
                        withAnimation {
                            currentOffset.height = 0
                        }
                    }
                }
            }
    }

    func hide() {
        withAnimation {
            currentScale = 1.0
            previousScale = 1.0
            currentOffset = CGSize.zero
            previousOffset = CGSize.zero
            isShowPhotoDetail = false
        }
    }

    var backgroundOpacity: CGFloat {
        if isShowPhotoDetail {
            if currentOffset.height == 0 {
                1
            } else if currentOffset.height > 0 {
                1 / (currentOffset.height * 0.01)
            } else {
                1 / (-currentOffset.height * 0.01)
            }
        } else {
            0
        }
    }

    var optionsOpacity: CGFloat {
        if isShowPhotoDetail {
            if currentScale > 1.2 {
                return 1
            }

            if currentOffset.height == 0 {
                return 1
            } else if currentOffset.height > 0 {
                return 1 / (currentOffset.height * 0.3)
            } else {
                return 1 / (-currentOffset.height * 0.3)
            }
        } else {
            return 0
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "PhotoOverlayModifier")
public typealias PhotoShowViewModifier = PhotoOverlayModifier

public extension View {
    func photoOverlay(isPresent: Binding<Bool>, selection: Binding<Int>, photos: [Image], action: (() -> Void)? = nil) -> some View {
        modifier(PhotoOverlayModifier(isPresent: isPresent, selection: selection, photos: photos, action: action))
    }
}

#Preview {
    Color.surfaceSecondary
        .ignoresSafeArea()
        .photoOverlay(
            isPresent: .constant(true),
            selection: .constant(0),
            photos: [
                Image(systemName: "photo"),
                Image(systemName: "photo.fill"),
                Image(systemName: "photo.on.rectangle"),
            ]
        )
}
#endif
