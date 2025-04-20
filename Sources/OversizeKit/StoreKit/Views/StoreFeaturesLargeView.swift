//
// Copyright © 2022 Alexander Romanov
// StoreFeaturesLargeView.swift
//

import CachedAsyncImage
import OversizeComponents
import OversizeModels
import OversizeNetwork
import OversizeServices
import OversizeUI
import SwiftUI

struct StoreFeaturesLargeView: View {
    @EnvironmentObject var viewModel: StoreViewModel

    var body: some View {
        switch viewModel.featuresState {
        case .idle, .loading:
            ProgressView()

        case let .result(features):
            VStack {
                ForEach(features) { feature in
                    if !feature.screenshots.isEmpty {
                        fetureScreenItem(feature)
                    } else {
                        fetureItem(feature)
                    }
                }
            }

        case let .error(appError):
            ErrorView(appError)
        }
    }

    func fetureScreenItem(_ feature: Components.Schemas.Feature) -> some View {
        Surface {
            VStack(spacing: .zero) {
                RoundedRectangle(cornerRadius: .medium, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color(hex: feature.screenshots.first?.backgroundColor ?? "637DFA"),
                                    Color(hex: feature.screenshots.first?.backgroundColor ?? "872BFF"),
                                ]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 310)
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
        .controlRadius(.large)
        .surfaceContentMargins(.xxxSmall)
        .padding(.vertical, .large)
        .elevation(.z3)
    }

    func fetureItem(_ feature: Components.Schemas.Feature) -> some View {
        VStack(spacing: .zero) {
            if let iconUrlString = feature.iconUrl, let iconUrl = URL(string: iconUrlString) {
                CachedAsyncImage(url: iconUrl, urlCache: .imageCache) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)

                } placeholder: {
                    Circle()
                        .fillSurfaceSecondary()
                        .frame(width: 100, height: 100)
                }
                .padding(.bottom, .large)
            } else if let illustrationUrlString = feature.illustrationUrl, let illustrationUrl = URL(string: illustrationUrlString) {
                CachedAsyncImage(url: illustrationUrl, urlCache: .imageCache) { image in
                    image
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.accent)
                        .frame(width: 54, height: 54)
                        .padding(20)
                        .background {
                            Circle()
                                .fill(backgroundColor(feature: feature).opacity(0.2))
                        }
                        .padding(.bottom, .large)
                } placeholder: {
                    Circle()
                        .fillSurfaceSecondary()
                        .frame(width: 100, height: 100)
                }
                .padding(.bottom, .large)
            } else {
                Image.Base.Check.square
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.accent)
                    .frame(width: 54, height: 54)
                    .padding(20)
                    .background {
                        Circle()
                            .fill(backgroundColor(feature: feature).opacity(0.2))
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
        }
        .padding(.vertical, .large)
    }

    func backgroundColor(feature: Components.Schemas.Feature) -> Color {
        if let color = feature.screenshots.first?.backgroundColor {
            Color(hex: color)
        } else {
            Color.accent
        }
    }
}

struct StoreFeaturesLargeView_Previews: PreviewProvider {
    static var previews: some View {
        StoreFeaturesLargeView()
    }
}
