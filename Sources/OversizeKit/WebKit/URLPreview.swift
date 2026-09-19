//
// Copyright © 2026 Alexander Romanov
// LinkView.swift, created on 17.03.2026
//

#if canImport(LinkPresentation) && canImport(UIKit) && !os(watchOS)
@preconcurrency import LinkPresentation
import SwiftUI
import UIKit

@available(iOS 16.0, tvOS 18.0, *)
public struct URLPreview: UIViewRepresentable {
    private let url: URL
    @Binding private var size: CGSize

    public init(url: URL, size: Binding<CGSize>) {
        self.url = url
        _size = size
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIView(context: Context) -> LPLinkView {
        let view = LPLinkView(url: url)
        fetchMetadata(into: view, coordinator: context.coordinator)
        return view
    }

    public func updateUIView(_ view: LPLinkView, context: Context) {
        guard context.coordinator.url != url else { return }
        let placeholder = LPLinkMetadata()
        placeholder.originalURL = url
        view.metadata = placeholder
        fetchMetadata(into: view, coordinator: context.coordinator)
    }

    @MainActor
    private func fetchMetadata(into view: LPLinkView, coordinator: Coordinator) {
        coordinator.provider?.cancel()
        coordinator.url = url
        let provider = LPMetadataProvider()
        coordinator.provider = provider
        let requestedURL = url
        Task { @MainActor in
            let metadata = try? await provider.startFetchingMetadata(for: requestedURL)
            guard coordinator.url == requestedURL else { return }
            coordinator.provider = nil
            if let metadata {
                view.metadata = metadata
            }
            view.sizeToFit()
            size = view.frame.size
        }
    }

    @MainActor
    public final class Coordinator {
        var url: URL?
        var provider: LPMetadataProvider?

        public init() {}
    }
}

#Preview {
    if #available(iOS 16.0, tvOS 18.0, *) {
        PreviewURLPreview()
    }
}

@available(iOS 16.0, tvOS 18.0, *)
private struct PreviewURLPreview: View {
    @State private var size: CGSize = .zero

    var body: some View {
        let url = URL(string: "https://apple.com")!
        URLPreview(url: url, size: $size)
            .frame(width: size.width, height: size.height)
    }
}
#endif
