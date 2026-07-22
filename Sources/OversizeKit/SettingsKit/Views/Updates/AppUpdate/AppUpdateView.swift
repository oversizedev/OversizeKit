//
// Copyright © 2026 Alexander Romanov
// AppUpdateView.swift, created on 04.03.2026
//

import OversizeArchitecture
import OversizeComponents
import OversizeNavigation
import OversizeNetwork
import OversizeUI
import SwiftUI

@View(module: AppUpdate.self)
public struct AppUpdateView: ViewProtocol {
    public var body: some View {
        NavigationLayoutView("Version \(viewState.state.result?.version ?? viewState.versionString ?? "")") {
            content
        } background: {
            Color.backgroundSecondary
        }
        .toolbarTitleDisplayMode(.inline)
        .task { reducer(.onFetch) }
    }

    @ViewBuilder
    var content: some View {
        switch viewState.state {
        case .idle, .loading:
            placeholder
        case let .result(version):
            versionContent(version)
        case let .error(error):
            ErrorView(error: error)
        }
    }

    private var placeholder: some View {
        VStack(spacing: .large) {
            VStack(spacing: .small) {
                Text("What's New")
                    .largeTitle(.bold)
                    .onSurfacePrimary()
                    .multilineTextAlignment(.center)
                Text("Loading version details...")
                    .title3()
                    .onSurfaceSecondary()
                    .multilineTextAlignment(.center)
            }
            ForEach(0 ..< 3, id: \.self) { _ in
                Surface {}
                    .frame(height: 200)
                    .surfaceRadius(.large)
                    .redacted(reason: .placeholder)
            }
        }
        .padding(.horizontal, .medium)
    }

    private func versionContent(_ version: Components.Schemas.Version) -> some View {
        VStack(spacing: .large) {
            VStack(spacing: .small) {
                Text("What's New")
                    .largeTitle(.bold)
                    .onSurfacePrimary()
                    .multilineTextAlignment(.center)

                if let whatsNew = version.whatsNew {
                    Text(whatsNew)
                        .title3()
                        .onSurfaceSecondary()
                        .multilineTextAlignment(.center)
                }
            }

            if let features = version.features, !features.isEmpty {
                ForEach(features) { feature in
                    if !feature.screenshots.isEmpty {
                        featureScreenItem(feature)
                    } else {
                        featureIconItem(feature)
                    }
                }
            }
        }
        .padding(.horizontal, .medium)
    }

    private func featureScreenItem(_ feature: Components.Schemas.Feature) -> some View {
        Surface {
            VStack(spacing: .zero) {
                RoundedRectangle(cornerRadius: .large - 4, style: .continuous)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: feature.screenshots.first?.backgroundColor ?? "637DFA"),
                            Color(hex: feature.screenshots.first?.backgroundColor ?? "872BFF"),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 350)
                    .overlay(alignment: feature.screenshots.first?.alignment == .top ? .top : .bottom) {
                        ZStack {
                            FireworksBubbles()
                            if let urlString = feature.screenshots.first?.url, let url = URL(string: urlString) {
                                ScreenMockup(url: url)
                                    .frame(maxWidth: 204)
                                    .padding(
                                        feature.screenshots.first?.alignment == .top ? .top : .bottom,
                                        feature.screenshots.first?.alignment == .top ? 40 : 70
                                    )
                            }
                        }
                    }
                    .clipped()

                VStack(spacing: .xxSmall) {
                    Text(feature.title)
                        .title2(.bold)
                        .foregroundColor(.onSurfacePrimary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    if let subtitle = feature.subtitle {
                        Text(subtitle)
                            .body(.medium)
                            .foregroundColor(.onSurfaceSecondary)
                    }
                }
                .padding(.vertical, .medium)
                .padding(.horizontal, .xSmall)
            }
            .multilineTextAlignment(.center)
        }
        .surfaceRadius(.large)
        .surfaceContentMargins(.xxxSmall)
        .elevation(.z3)
    }

    private func featureIconItem(_ feature: Components.Schemas.Feature) -> some View {
        VStack(spacing: .zero) {
            if let illustrationUrlString = feature.illustrationUrl,
               let illustrationUrl = URL(string: illustrationUrlString)
            {
                CachedAsyncImage(url: illustrationUrl, urlCache: .imageCache) { image in
                    image.resizable().scaledToFill()
                        .frame(width: 100, height: 100)
                } placeholder: {
                    Circle().fillSurfaceSecondary()
                        .frame(width: 100, height: 100)
                }
                .padding(.bottom, .large)
            } else if let iconUrlString = feature.iconUrl,
                      let iconUrl = URL(string: iconUrlString)
            {
                CachedAsyncImage(url: iconUrl, urlCache: .imageCache) { image in
                    image
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.accent)
                        .frame(width: 54, height: 54)
                        .padding(20)
                        .background {
                            Circle().fill(featureBackgroundColor(feature).opacity(0.2))
                        }
                } placeholder: {
                    Circle().fillSurfaceSecondary()
                        .frame(width: 100, height: 100)
                }
                .padding(.bottom, .large)
            } else {
                Image.Base.Check.square
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.accent)
                    .frame(width: 54, height: 54)
                    .padding(20)
                    .background {
                        Circle().fill(featureBackgroundColor(feature).opacity(0.2))
                    }
                    .padding(.bottom, .large)
            }

            VStack(spacing: .xSmall) {
                Text(feature.title)
                    .title2(.bold)
                    .foregroundColor(.onSurfacePrimary)
                if let subtitle = feature.subtitle {
                    Text(subtitle)
                        .body(.medium)
                        .foregroundColor(.onSurfaceSecondary)
                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(.vertical, .large)
    }

    private func featureBackgroundColor(_ feature: Components.Schemas.Feature) -> Color {
        if let color = feature.screenshots.first?.backgroundColor {
            Color(hex: color)
        } else {
            Color.accent
        }
    }
}

#Preview {
    NavigationStack {
        AppUpdate.build(input: .init(version: .init(
            id: 1,
            version: "2.0.0",
            releasedAt: .now,
            whatsNew: "Improved performance and new features for a better experience.",
            features: [
                .init(
                    id: "1",
                    title: "New Dashboard",
                    subtitle: "Redesigned for clarity",
                    description: nil,
                    textSize: .medium,
                    textAlignment: .leading,
                    iconUrl: nil,
                    illustrationUrl: nil,
                    screenshots: []
                ),
                .init(
                    id: "2",
                    title: "Faster Sync",
                    subtitle: "Up to 3x faster data sync",
                    description: nil,
                    textSize: .medium,
                    textAlignment: .leading,
                    iconUrl: nil,
                    illustrationUrl: nil,
                    screenshots: []
                ),
            ]
        )))
    }
}
