//
// Copyright © 2022 Alexander Romanov
// StoreFeatureDetailView.swift
//

import CachedAsyncImage
import OversizeComponents
import OversizeCore
import OversizeModels
import OversizeNetwork
import OversizeServices
import OversizeUI
import SwiftUI

public struct StoreFeatureDetailView: View {
    @EnvironmentObject var viewModel: StoreViewModel
    @State var selection: Components.Schemas.Feature
    @Environment(\.screenSize) var screenSize
    @Environment(\.dismiss) var dismiss
    @Environment(\.isPremium) var isPremium

    public init(selection: Components.Schemas.Feature) {
        _selection = State(initialValue: selection)
    }

    public var body: some View {
        GeometryReader { geometry in
            #if os(iOS) || os(macOS)
            VStack(spacing: .zero) {
                #if os(macOS)
                feature(geometry: geometry)

                #else
                if let features = viewModel.featuresState.result {
                    tabsFeatures(features, geometry: geometry)
                }
                #endif

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
                        color: selection.screenshots.first?.url != nil ? .onPrimary : .onSurfaceTertiary
                    )
                    .padding(.xxSmall)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
                    .padding(.small)
                }
                .buttonStyle(.plain)
            }
            #endif
        }
    }

    func feature(geometry: GeometryProxy) -> some View {
        fetureItem(selection, geometry: geometry)
            .padding(.bottom, isPremium ? .large : .zero)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func tabsFeatures(_ features: [Components.Schemas.Feature], geometry: GeometryProxy) -> some View {
        TabView(selection: $selection) {
            ForEach(features, id: \.id) { feature in
                fetureItem(feature, geometry: geometry)
                    .padding(.bottom, isPremium ? .large : .zero)
                    .tag(feature)
            }
        }
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: isPremium ? .always : .never))
        .indexViewStyle(.page(backgroundDisplayMode: isPremium ? .always : .never))
        #endif
    }

    func fetureItem(_ feature: Components.Schemas.Feature, geometry: GeometryProxy) -> some View {
        Group {
            if let _ = feature.screenshots.first {
                screenFetureItem(feature, geometry: geometry)
            } else {
                iconFetureItem(feature, geometry: geometry)
            }
        }
    }

    func screenFetureItem(_ feature: Components.Schemas.Feature, geometry: GeometryProxy) -> some View {
        VStack(spacing: .zero) {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: feature.screenshots.first?.backgroundColor ?? "637DFA"),
                            Color(hex: feature.screenshots.first?.backgroundColor ?? "872BFF"),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: feature.screenshots.first?.alignment == .top ? .top : .bottom) {
                    ZStack {
                        FireworksBubbles()

                        if let urlString = feature.screenshots.first?.url, let url = URL(string: urlString) {
                            ScreenMockup(url: url)
                                .frame(maxWidth: 60 + (geometry.size.height * 0.2))
                                .padding(
                                    feature.screenshots.first?.alignment == .top ? .top : .bottom,
                                    feature.screenshots.first?.alignment == .top
                                        ? (geometry.size.height * 0.1) - 24
                                        : (geometry.size.height * 0.1) + 12
                                )
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

            TextBox(title: feature.title, subtitle: feature.subtitle, spacing: .xxSmall)
                .multilineTextAlignment(.center)
                .paddingContent(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, (geometry.size.height * 0.1) - 20)
        }
    }

    func iconFetureItem(_ feature: Components.Schemas.Feature, geometry: GeometryProxy) -> some View {
        VStack(spacing: .xxxSmall) {
            if let IllustrationURLPath = feature.iconUrl {
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

            } else if let illustrationUrlString = feature.illustrationUrl, let illustrationUrl = URL(string: illustrationUrlString) {
                CachedAsyncImage(url: illustrationUrl, urlCache: .imageCache) { image in
                    image
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

                } placeholder: {
                    Circle()
                        .fillSurfaceSecondary()
                        .frame(width: 100, height: 100)
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

            TextBox(title: feature.title, subtitle: feature.subtitle, spacing: .xxSmall)
                .multilineTextAlignment(.center)
                .paddingContent(.horizontal)
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
