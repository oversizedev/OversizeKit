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
                    if feature.screenshotUrl != nil {
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
                                    Color(hex: feature.backgroundColor != nil ? feature.backgroundColor : "637DFA"),
                                    Color(hex: feature.backgroundColor != nil ? feature.backgroundColor : "872BFF"),
                                ]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 310)
                    .overlay(alignment: feature.screenshotAlignment == .top ? .top : .bottom) {
                        ZStack {
                            FireworksBubbles()

                            if let urlString = feature.screenshotUrl, let url = URL(string: urlString) {
                                ScreenMockup(url: url)
                                    .frame(maxWidth: 204)
                                    .padding(
                                        feature.screenshotAlignment == .top ? .top : .bottom,
                                        feature.screenshotAlignment == .top ? 40 : 70
                                    )
                            }
                        }
                    }
                    .clipped()

                VStack(spacing: .xxSmall) {
                    Text(feature.title)
                        .title2(.bold)
                        .foregroundColor(.onSurfacePrimary)

                    Text(feature.subtitle.valueOrEmpty)
                        .body(.medium)
                        .foregroundColor(.onSurfaceSecondary)
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
            if let IllustrationURLPath = feature.illustrationUrl {
                CachedAsyncImage(url: URL(string: IllustrationURLPath), urlCache: .imageCache) { image in
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

                Text(feature.subtitle.valueOrEmpty)
                    .body(.medium)
                    .foregroundColor(.onSurfaceSecondary)
            }
        }
        .padding(.vertical, .large)
    }

    func backgroundColor(feature: Components.Schemas.Feature) -> Color {
        if let color = feature.backgroundColor {
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
