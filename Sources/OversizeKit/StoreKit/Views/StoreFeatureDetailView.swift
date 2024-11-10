//
// Copyright © 2022 Alexander Romanov
// StoreFeatureDetailView.swift
//

import CachedAsyncImage
import OversizeComponents
import OversizeCore
import OversizeModels
import OversizeServices
import OversizeUI
import SwiftUI

public struct StoreFeatureDetailView: View {
    @EnvironmentObject var viewModel: StoreViewModel
    @State var selection: PlistConfiguration.Store.StoreFeature
    @Environment(\.screenSize) var screenSize
    @Environment(\.dismiss) var dismiss
    @Environment(\.isPremium) var isPremium

    public init(selection: PlistConfiguration.Store.StoreFeature) {
        _selection = State(initialValue: selection)
    }

    public var body: some View {
        GeometryReader { geometry in
            #if os(iOS)
                VStack(spacing: .zero) {
                    TabView(selection: $selection) {
                        ForEach(Info.store.features) { feature in
                            fetureItem(feature, geometry: geometry)
                                .padding(.bottom, isPremium ? .large : .zero)
                                .tag(feature)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: isPremium ? .always : .never))
                    .indexViewStyle(.page(backgroundDisplayMode: isPremium ? .always : .never))

                    if !isPremium {
                        StorePaymentButtonBar()
                            .environmentObject(viewModel)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        IconDeprecated(
                            .xMini,
                            color: selection.screenURL != nil ? .onPrimary : .onSurfaceTertiary
                        )
                        .padding(.xxSmall)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                        }
                        .padding(.small)
                    }
                }
            #endif
        }
    }

    func fetureItem(_ feature: PlistConfiguration.Store.StoreFeature, geometry: GeometryProxy) -> some View {
        Group {
            if let _ = feature.screenURL {
                screenFetureItem(feature, geometry: geometry)
            } else {
                iconFetureItem(feature, geometry: geometry)
            }
        }
    }

    func screenFetureItem(_ feature: PlistConfiguration.Store.StoreFeature, geometry: GeometryProxy) -> some View {
        VStack(spacing: .zero) {
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color(hex: feature.backgroundColor != nil ? feature.backgroundColor : "637DFA"),
                                                               Color(hex: feature.backgroundColor != nil ? feature.backgroundColor : "872BFF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(alignment: feature.topScreenAlignment ?? true ? .top : .bottom) {
                    ZStack {
                        FireworksBubbles()

                        if let urlString = feature.screenURL, let url = URL(string: urlString) {
                            ScreenMockup(url: url)
                                .frame(maxWidth: 60 + (geometry.size.height * 0.2))
                                .padding(feature.topScreenAlignment ?? true ? .top : .bottom,
                                         feature.topScreenAlignment ?? true
                                             ? (geometry.size.height * 0.1) - 24
                                             : (geometry.size.height * 0.1) + 12)
                        }
                    }
                }
                .clipped()
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.black.opacity(0.1))
                        .frame(height: 0.5)
                        .vBottom()
                }

            TextBox(title: feature.title.valueOrEmpty, subtitle: feature.subtitle, spacing: .xxSmall)
                .multilineTextAlignment(.center)
                .paddingContent(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, (geometry.size.height * 0.1) - 20)
        }
    }

    func iconFetureItem(_ feature: PlistConfiguration.Store.StoreFeature, geometry: GeometryProxy) -> some View {
        VStack(spacing: .xxxSmall) {
            if let IllustrationURLPath = feature.illustrationURL {
                CachedAsyncImage(url: URL(string: IllustrationURLPath), urlCache: .imageCache) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 75 + (geometry.size.height * 0.02), height: 75 + (geometry.size.height * 0.02))

                } placeholder: {
                    Circle()
                        .fillSurfaceSecondary()
                        .frame(width: 100, height: 100)
                }
                .padding(.bottom, geometry.size.height * 0.07)

            } else if let image = feature.image {
                Image(resourceImage: image)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.accent)
                    .frame(width: 54 + (geometry.size.height * 0.02), height: 54 + (geometry.size.height * 0.02))
                    .padding(12 + (geometry.size.height * 0.02))
                    .background {
                        Circle()
                            .fill(backgroundColor(feature: feature).opacity(0.2))
                    }
                    .padding(.bottom, geometry.size.height * 0.07)

            } else {
                Image.Base.Check.square
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.accent)
                    .frame(width: 54 + (geometry.size.height * 0.02), height: 54 + (geometry.size.height * 0.02))
                    .padding(12 + (geometry.size.height * 0.02))
                    .background {
                        Circle()
                            .fill(backgroundColor(feature: feature).opacity(0.2))
                    }
                    .padding(.bottom, geometry.size.height * 0.07)
            }

            TextBox(title: feature.title.valueOrEmpty, subtitle: feature.subtitle, spacing: .xxSmall)
                .multilineTextAlignment(.center)
                .paddingContent(.horizontal)
        }
    }

    func backgroundColor(feature: PlistConfiguration.Store.StoreFeature) -> Color {
        if let color = feature.backgroundColor {
            return Color(hex: color)
        } else {
            return Color.accent
        }
    }
}
