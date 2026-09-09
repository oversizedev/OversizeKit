//
// Copyright © 2022 Alexander Romanov
// StoreFeaturesView.swift
//

import OversizeCore
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
                    placeholder
                case let .result(features):
                    ForEach(features) { feature in
                        Row(feature.title, subtitle: feature.subtitle) {
                            selection = feature
                        } leading: {
                            Group {
                                if let iconUrlString = feature.iconUrl, let iconUrl = URL(string: iconUrlString) {
                                    CachedAsyncImage(url: iconUrl) { phase in
                                        switch phase {
                                        case .empty:
                                            Circle()
                                                .fillOnPrimaryTertiary()
                                                .frame(width: 24, height: 24)
                                        case let .success(image):
                                            image
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundColor(Color.onPrimary)
                                                .frame(width: 24, height: 24)
                                        case .failure:
                                            Image.Base.check
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundColor(Color.onPrimary)
                                                .frame(width: 24, height: 24)
                                        @unknown default:
                                            Image.Base.Check.square
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundColor(Color.accent)
                                                .frame(width: 24, height: 24)
                                        }
                                    }

                                } else {
                                    Image.Base.Check.square
                                        .renderingMode(.template)
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .onPrimary()
                            .iconOnSurface(surfaceSolor: backgroundColor(feature: feature))
                        }
                        .rowIconBackgroundColor(backgroundColor(feature: feature))
                        .navigatable()
                    }
                case let .error(appError):
                    OversizeUI.ErrorView(error: appError)
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
                    .coreServices()
                    .frame(width: 440, height: 500)
            }
            .frame(width: 440, height: 500, alignment: .center)
            #else
            NavigationStack {
                StoreFeatureDetailView(selection: feature)
                    .environmentObject(viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationContentInteraction(.scrolls)
                    .coreServices()
            }
            #endif
        }
    }

    private var placeholder: some View {
        VStack(spacing: .zero) {
            ForEach(0 ..< 3, id: \.self) { _ in
                Row("Feature", subtitle: "Description") {} leading: {
                    Circle()
                        .fillSurfaceSecondary()
                        .frame(width: 24, height: 24)
                }
                .navigatable()
                .redacted(reason: .placeholder)
                .disabled(true)
            }
        }
    }

    func backgroundColor(feature: Components.Schemas.Feature) -> Color {
        if let color = feature.screenshots.first?.backgroundColor {
            Color(hex: color)
        } else {
            Color.accent
        }
    }
}

#Preview {
    StoreFeaturesView()
}
