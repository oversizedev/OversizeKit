//
// Copyright © 2022 Alexander Romanov
// StoreFeaturesView.swift
//

import CachedAsyncImage
import OversizeCore
import OversizeModels
import OversizeNetwork
import OversizeServices
import OversizeUI
import SwiftUI

struct StoreFeaturesView: View {
    @EnvironmentObject var viewModel: StoreViewModel
    @State var selection: Components.Schemas.Feature?
    @Environment(\.platform) private var platform

    var body: some View {
        Surface {
            VStack {
                switch viewModel.featuresState {
                case .idle, .loading:
                    ProgressView()
                case let .result(features):
                    ForEach(features) { feature in
                        Row(feature.title, subtitle: feature.subtitle) {
                            selection = feature
                        } leading: {
                            Group {
                                if let iconUrlString = feature.iconUrl, let iconUrl = URL(string: iconUrlString) {
                                    CachedAsyncImage(url: iconUrl, urlCache: .imageCache) {
                                        $0
                                            .resizable()
                                            .frame(width: 24, height: 24)

                                    } placeholder: {
                                        Circle()
                                            .fillOnPrimaryTertiary()
                                            .frame(width: 24, height: 24)
                                    }

                                } else {
                                    Image.Base.Check.square
                                        .renderingMode(.template)
                                }
                            }
                            .onPrimaryForeground()
                            .iconOnSurface(surfaceSolor: backgroundColor(feature: feature))
                        }
                        .rowArrow()
                        .rowIconBackgroundColor(backgroundColor(feature: feature))
                    }
                case let .error(appError):
                    ErrorView(appError)
                }
            }
        }
        .surfaceBorderColor(Color.surfaceSecondary)
        .surfaceBorderWidth(platform == .macOS ? 1 : 2)
        .surfaceContentRowMargins()
        .sheet(item: $selection) {
            selection = nil
        } content: { feature in
            #if os(macOS)
            VStack {
                StoreFeatureDetailView(selection: feature)
                    .environmentObject(viewModel)
                    .systemServices()
                    .frame(width: 440, height: 500)
            }
            .frame(width: 440, height: 500, alignment: .center)
            #else
            StoreFeatureDetailView(selection: feature)
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .systemServices()
            #endif
        }
    }

    func backgroundColor(feature: Components.Schemas.Feature) -> Color {
        if let color = feature.backgroundColor {
            Color(hex: color)
        } else {
            Color.accent
        }
    }
}

struct StoreFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        StoreFeaturesView()
    }
}
