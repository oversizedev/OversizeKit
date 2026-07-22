//
// Copyright © 2026 Alexander Romanov
// URLPreview.swift, created on 16.03.2026
//

#if canImport(LinkPresentation)
import OversizeUI
import OversizeWebService
import SwiftUI

@available(macOS 13.0, iOS 16.0, tvOS 18.0, *)
public struct URLFieldPreview: View {
    @Environment(\.fieldPosition) private var fieldPosition: VerticalAlignment?

    private let url: URL
    @State private var metadata: LinkMetadata?
    @State private var isLoading: Bool = false

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        LeadingVStack(spacing: .xxxSmall) {
            if isLoading {
                Text("Apple")
                    .caption()
                    .onSurfaceSecondary()
                    .padding(.small)
                    .redacted(reason: .placeholder)
                    .hLeading()

            } else if let title = metadata?.title {
                Text(title)
                    .headline()
                    .onSurfacePrimary()
                    .padding(.small)
                    .hLeading()
            }

            #if canImport(UIKit)
            if let image = metadata?.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            #else
            if let image = metadata?.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            }
            #endif
        }
        .background {
            Color.surfaceSecondary
        }
        .clipShape(RoundedRectangleCorner(radius: 4, corners: shapeCorners))
        .task(id: url) {
            metadata = nil
            isLoading = true
            let service = LinkMetadataService()
            let result = await service.extractMetadata(from: url)
            guard !Task.isCancelled else { return }
            if case let .success(data) = result {
                metadata = data
            }
            isLoading = false
        }
    }

    #if canImport(UIKit)
    private var shapeCorners: UIRectCorner {
        switch fieldPosition {
        case .top: [.topLeft, .topRight]
        case .bottom: [.bottomLeft, .bottomRight]
        case .center: []
        default: .allCorners
        }
    }
    #else
    private var shapeCorners: RectCorner {
        switch fieldPosition {
        case .top: [.topLeft, .topRight]
        case .bottom: [.bottomLeft, .bottomRight]
        case .center: []
        default: .allCorners
        }
    }
    #endif

    @ViewBuilder
    private var iconView: some View {
        #if canImport(UIKit)
        if let icon = metadata?.icon {
            Image(uiImage: icon)
                .resizable()
                .frame(width: .medium, height: .medium)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            Image(systemName: "link")
                .frame(width: .medium, height: .medium)
                .foregroundStyle(.secondary)
        }
        #else
        if let icon = metadata?.icon {
            Image(nsImage: icon)
                .resizable()
                .frame(width: .medium, height: .medium)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            Image(systemName: "link")
                .frame(width: .medium, height: .medium)
                .foregroundStyle(.secondary)
        }
        #endif
    }
}

#Preview {
    URLFieldPreview(url: URL(string: "https://apple.com")!)
        .padding()
}
#endif
