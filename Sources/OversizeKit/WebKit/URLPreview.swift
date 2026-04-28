//
// Copyright © 2026 Alexander Romanov
// LinkView.swift, created on 17.03.2026
//

#if canImport(LinkPresentation) && canImport(UIKit) && !os(watchOS)
@preconcurrency import LinkPresentation
import SwiftUI
import UIKit

@available(iOS 16.0, tvOS 16.0, *)
public struct URLPreview: UIViewRepresentable {
    private let url: URL
    @Binding private var size: CGSize

    public init(url: URL, size: Binding<CGSize>) {
        self.url = url
        _size = size
    }

    public func makeUIView(context _: Context) -> LPLinkView {
        let view = LPLinkView(url: url)
        let provider = LPMetadataProvider()
        Task { @MainActor in
            let metadata = try? await provider.startFetchingMetadata(for: url)
            if let metadata {
                view.metadata = metadata
                view.sizeToFit()
                size = view.frame.size
            }
        }
        return view
    }

    public func updateUIView(_: LPLinkView, context _: Context) {}
}

#Preview {
    @Previewable @State var size: CGSize = .zero
    let url = URL(string: "https://apple.com")!
    URLPreview(url: url, size: $size)
        .frame(width: size.width, height: size.height)
}
#endif
