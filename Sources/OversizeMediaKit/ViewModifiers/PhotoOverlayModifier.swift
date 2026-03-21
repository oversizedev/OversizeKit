//
// Copyright © 2022 Alexander Romanov
// PhotoOverlayModifier.swift
//

import OversizeCore
import OversizeUI
import SwiftUI

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

#if os(iOS)
public struct PhotoOverlayModifier: ViewModifier {
    @Namespace private var heroNamespace

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
            
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .background(.black)
            .onTapGesture {
                withAnimation {
                    isShowOptions.toggle()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", systemImage: "chevron.left") {
                        isShowPhotoDetail = false
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                }
                ToolbarItem(placement: .principal) {
                    Text("\(selectionIndex + 1) of \(photos.count)")
                        .foregroundStyle(.white)
                        .font(.headline)
                }
                if let action {
                    ToolbarItem(placement: .primaryAction) {
                        Button("More", systemImage: "ellipsis", action: action)
                            .labelStyle(.toolbar)
                            .buttonStyle(.toolbarSecondary)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .statusBar(hidden: !isShowOptions)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar(isShowOptions ? .visible : .hidden, for: .navigationBar)
            .ignoresSafeArea(.all)
        }
        .applyZoomTransition(sourceID: selectionIndex, namespace: heroNamespace)
        .colorScheme(.dark)
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
public typealias PhotoShowViewModifier = PhotoOverlayModifier

public extension View {
    func photoOverlay(isPresent: Binding<Bool>, selection: Binding<Int>, photos: [Image], action: (() -> Void)? = nil) -> some View {
        modifier(PhotoOverlayModifier(isPresent: isPresent, selection: selection, photos: photos, action: action))
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
