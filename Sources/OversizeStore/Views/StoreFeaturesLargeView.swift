//
// Copyright © 2022 Alexander Romanov
// StoreFeaturesLargeView.swift
//

import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeUI
import SwiftUI
import OversizeComponents

struct StoreFeaturesLargeView: View {
    @EnvironmentObject var viewModel: StoreViewModel
    let features = AppInfo.store.features

    var body: some View {
        VStack {
            ForEach(features) { feature in
                if feature.screenURL != nil {
                    fetureScreenItem(feature)
                } else {
                    fetureItem(feature)
                }
            }
        }
    }

    func fetureScreenItem(_ feature: StoreFeature) -> some View {
        Surface {
            VStack(spacing: .zero) {
                RoundedRectangle(cornerRadius: .medium, style: .continuous)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "637DFA"), Color(hex: "872BFF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(height: 310)
                    .overlay(alignment: feature.topScreenAlignment ?? true ? .top : .bottom) {
                        ZStack {
                            Fireworks()

                            if let urlString = feature.screenURL, let url = URL(string: urlString) {
                                ScreenMockup(url: url)
                                    .frame(maxWidth: 204)
                                    .padding(feature.topScreenAlignment ?? true ? .top : .bottom,
                                             feature.topScreenAlignment ?? true ? 40 : 70)
                            }
                        }
                    }
                    .clipped()

                VStack(spacing: .xxSmall) {
                    Text(feature.title.valueOrEmpty)
                        .title2(.bold)
                        .foregroundColor(.onSurfaceHighEmphasis)

                    Text(feature.subtitle.valueOrEmpty)
                        .body(.medium)
                        .foregroundColor(.onSurfaceMediumEmphasis)
                }
                .padding(.vertical, .medium)
            }
        }
        .controlRadius(.large)
        .controlPadding(.xxxSmall)
        .padding(.vertical, .large)
        .elevation(.z3)
    }

    func fetureItem(_ feature: StoreFeature) -> some View {

        VStack(spacing: .zero) {
            if let IllustrationURLPath = feature.illustrationURL {
                AsyncImage(url: URL(string: IllustrationURLPath)) { image in
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

            } else if let image = feature.image {
                Image(resourceImage: image)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.accent)
                    .frame(width: 54, height: 54)
                    .padding(20)
                    .background {
                        Circle()
                            .fill(Color.accent.opacity(0.2))
                    }
                    .padding(.bottom, .large)

            } else {
                Icon.Solid.UserInterface.checkCrFr
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.accent)
                    .frame(width: 54, height: 54)
                    .padding(20)
                    .background {
                        Circle()
                            .fill(Color.accent.opacity(0.2))
                    }
                    .padding(.bottom, .large)
            }
            
            
            
//            Image(resourceImage: feature.image ?? "")
//                .resizable()
//                .renderingMode(.template)
//                .foregroundAccent()
//                .frame(width: 48, height: 48)
//                .padding(20)
//                .background {
//                    Circle()
//                        .fillAccent()
//                        .opacity(0.2)
//                }
//                .padding(.bottom, .large)

            VStack(spacing: .xSmall) {
                Text(feature.title.valueOrEmpty)
                    .title2(.bold)
                    .foregroundColor(.onSurfaceHighEmphasis)

                Text(feature.subtitle.valueOrEmpty)
                    .body(.medium)
                    .foregroundColor(.onSurfaceMediumEmphasis)
            }
        }
        .padding(.vertical, .large)
    }
}

struct StoreFeaturesLargeView_Previews: PreviewProvider {
    static var previews: some View {
        StoreFeaturesLargeView()
    }
}
