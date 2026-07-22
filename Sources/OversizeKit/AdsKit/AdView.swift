//
// Copyright © 2022 Alexander Romanov
// AdView.swift
//

import OversizeCore
import OversizeNetwork
import OversizeServices
import OversizeUI
import SwiftUI

public struct AdView: View {
    @Environment(\.isPremium) var isPremium: Bool

    @State var viewModel = AdViewModel()

    @State var isShowProduct = false
    public init() {}

    public var body: some View {
        if isPremium {
            EmptyView()
        } else {
            switch viewModel.state {
            case .idle:
                placeholder
                    .task {
                        await viewModel.fetchAd()
                    }
            case .loading:
                placeholder
            case let .result(appAd):
                #if os(iOS)
                Surface {
                    isShowProduct.toggle()
                } label: {
                    premiumBanner(appAd: appAd)
                }
                .surfaceContentMargins(.xSmall)
                .appStoreOverlay(isPresent: $isShowProduct, appId: String(appAd.id))
                #else
                EmptyView()
                #endif
            case .error:
                EmptyView()
            }
        }
    }

    var placeholder: some View {
        Surface {
            HStack(spacing: .zero) {
                RoundedRectangle(cornerRadius: .small, style: .continuous)
                    .fillSurfaceSecondary()
                    .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: .xxxSmall) {
                    Text("App Title")
                        .subheadline(.bold)
                        .onSurfacePrimary()

                    Text("App description text here")
                        .subheadline()
                        .onSurfaceSecondary()
                }
                .padding(.leading, .xSmall)

                Spacer()

                Button("Get") {}
                    .buttonStyle(.tertiary)
                    .controlBorderShape(.capsule)
                    .padding(.trailing, .xxxSmall)
                #if !os(tvOS)
                    .controlSize(.small)
                #endif
            }
        }
        .surfaceContentMargins(.xSmall)
        .redacted(reason: .placeholder)
        .disabled(true)
    }

    func premiumBanner(appAd: Components.Schemas.Ad) -> some View {
        HStack(spacing: .zero) {
            if let iconUrl = appAd.iconUrl, let url = URL(string: iconUrl) {
                CachedAsyncImage(url: url, urlCache: .imageCache, content: {
                    $0
                        .resizable()
                        .frame(width: 64, height: 64)
                        .mask(RoundedRectangle(
                            cornerRadius: .small,
                            style: .continuous
                        ))
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: .small,
                                style: .continuous
                            )
                            .stroke(lineWidth: 1)
                            .opacity(0.15)
                        )
                        .onTapGesture {
                            isShowProduct.toggle()
                        }

                }, placeholder: {
                    RoundedRectangle(cornerRadius: .small, style: .continuous)
                        .fillSurfaceSecondary()
                        .frame(width: 64, height: 64)
                })
            }

            VStack(alignment: .leading, spacing: .xxxSmall) {
                HStack {
                    Text(appAd.title)
                        .subheadline(.bold)
                        .onSurfacePrimary()

                    Badge(color: .warning) {
                        Text("Our app")
                            .bold()
                    }
                }

                Text(appAd.description)
                    .subheadline()
                    .onSurfaceSecondary()
                    .hLeading()
            }
            .padding(.leading, .xSmall)

            Button("Get") {
                isShowProduct.toggle()
            }
            .buttonStyle(.tertiary)
            .controlBorderShape(.capsule)
            .padding(.trailing, .xxxSmall)
            .loading(isShowProduct)
            #if !os(tvOS)
                .controlSize(.small)
            #endif
        }
    }
}

#Preview {
    AdView()
}
