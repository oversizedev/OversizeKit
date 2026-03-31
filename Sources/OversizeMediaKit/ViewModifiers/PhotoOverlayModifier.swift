//
// Copyright © 2022 Alexander Romanov
// PhotoOverlayModifier.swift
//

import OversizeCore
import OversizeUI
import SwiftUI

#if os(iOS)
public extension EnvironmentValues {
    @Entry var photoOverlayNamespace: Namespace.ID?
}

// MARK: - Source Modifier

public struct PhotoOverlaySourceModifier<ID: Hashable>: ViewModifier {
    @Environment(\.photoOverlayNamespace) private var namespace
    let id: ID

    public func body(content: Content) -> some View {
        if #available(iOS 18, *), let namespace {
            content
                .matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
    }
}

public extension View {
    func photoOverlaySource(id: some Hashable) -> some View {
        modifier(PhotoOverlaySourceModifier(id: id))
    }
}

// MARK: - Photo Overlay Modifier

public struct PhotoOverlayModifier<OptionsSheet: View>: ViewModifier {
    @Namespace private var heroNamespace

    @State private var isShowOptions: Bool = true
    @State private var isShowOptionsSheet: Bool = false

    @Binding private var selectionIndex: Int
    private let photos: [Image]

    @Binding private var isShowPhotoDetail: Bool

    private let optionsSheet: (() -> OptionsSheet)?

    public func body(content: Content) -> some View {
        content
            .environment(\.photoOverlayNamespace, heroNamespace)
            .fullScreenCover(isPresented: $isShowPhotoDetail) {
                isShowOptions = true
            } content: {
                photoDetailView
            }
    }

    // MARK: - Photo Detail View

    private var photoDetailView: some View {
        NavigationStack {
            TabView(selection: $selectionIndex) {
                ForEach(0 ..< photos.count, id: \.self) { index in
                    photos[index]
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(index)
                }
            }
            .ignoresSafeArea(.all)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .background(.black)
            .onTapGesture {
                withAnimation {
                    isShowOptions.toggle()
                }
            }
            .safeAreaInset(edge: .top) {
                if isShowOptions {
                    HStack {
                        if #available(iOS 26.0, *) {
                            Button {
                                isShowPhotoDetail = false
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                    .foregroundStyle(Color.white)
                                    .frame(width: 20, height: 30)
                            }
                            .buttonStyle(.glass)
                        } else {
                            Button {
                                isShowPhotoDetail = false
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                    .foregroundStyle(Color.white)
                                    .frame(width: 20, height: 30)
                            }
                        }

                        Spacer(minLength: 0)

                        Text("\(selectionIndex + 1) of \(photos.count)")
                            .foregroundStyle(Color.white)
                            .font(.headline)

                        Spacer(minLength: 0)

                        if optionsSheet != nil {
                            if #available(iOS 26.0, *) {
                                Button {
                                    isShowOptionsSheet = true
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.title3)
                                        .foregroundStyle(Color.white)
                                        .frame(width: 20, height: 30)
                                }
                                .buttonStyle(.glass)
                            } else {
                                Button {
                                    isShowOptionsSheet = true
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.title3)
                                        .foregroundStyle(Color.white)
                                        .frame(width: 20, height: 30)
                                }
                            }
                        } else {
                            Color.clear
                                .frame(width: 20, height: 30)
                        }
                    }
                    .padding(.horizontal, 20)
                    .transition(.opacity)
                }
            }
            .statusBar(hidden: !isShowOptions)
        }
        .sheet(isPresented: $isShowOptionsSheet) {
            optionsSheet?()
        }
        .applyZoomTransition(sourceID: selectionIndex, namespace: heroNamespace)
        .colorScheme(.dark)
    }
}

// MARK: - Initializers

extension PhotoOverlayModifier {
    public init(isPresent: Binding<Bool>, selection: Binding<Int>, photos: [Image], @ViewBuilder optionsSheet: @escaping () -> OptionsSheet) {
        _selectionIndex = selection
        self.photos = photos
        _isShowPhotoDetail = isPresent
        self.optionsSheet = optionsSheet
    }
}

extension PhotoOverlayModifier where OptionsSheet == EmptyView {
    public init(isPresent: Binding<Bool>, selection: Binding<Int>, photos: [Image]) {
        _selectionIndex = selection
        self.photos = photos
        _isShowPhotoDetail = isPresent
        self.optionsSheet = nil
    }
}

// MARK: - Zoom Transition Helper

private extension View {
    @ViewBuilder
    func applyZoomTransition(sourceID: Int, namespace: Namespace.ID) -> some View {
        if #available(iOS 18, *) {
            navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "PhotoOverlayModifier")
public typealias PhotoShowViewModifier = PhotoOverlayModifier<EmptyView>

public extension View {
    func photoOverlay<OptionsSheet: View>(
        isPresent: Binding<Bool>,
        selection: Binding<Int>,
        photos: [Image],
        @ViewBuilder optionsSheet: @escaping () -> OptionsSheet
    ) -> some View {
        modifier(PhotoOverlayModifier(isPresent: isPresent, selection: selection, photos: photos, optionsSheet: optionsSheet))
    }

    func photoOverlay(
        isPresent: Binding<Bool>,
        selection: Binding<Int>,
        photos: [Image]
    ) -> some View {
        modifier(PhotoOverlayModifier<EmptyView>(isPresent: isPresent, selection: selection, photos: photos))
    }
}

#Preview {
    NavigationStack {
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
}
#endif
