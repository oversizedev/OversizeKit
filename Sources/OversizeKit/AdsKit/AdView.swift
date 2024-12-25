//
// Copyright © 2022 Alexander Romanov
// AdView.swift
//

import CachedAsyncImage
import OversizeCore
import OversizeModels
import OversizeNetwork
import OversizeServices
import OversizeUI
import SwiftUI

public struct AdView: View {
    @Environment(\.isPremium) var isPremium: Bool

    @StateObject var viewModel: AdViewModel

    @State var isShowProduct = false
    public init() {
        _viewModel = StateObject(wrappedValue: AdViewModel())
    }

    public var body: some View {
        switch viewModel.state {
        case .initial:
            VStack {}
                .task {
                    if !isPremium {
                        await viewModel.fetchAd()
                    }
                }

        case let .result(appAd):
            #if os(iOS)
            Surface {
                isShowProduct.toggle()
            } label: {
                premiumBanner(appAd: appAd)
            }
            .surfaceContentMargins(.xSmall)
            .appStoreOverlay(isPresent: $isShowProduct, appId: appAd.appStoreId)

            #else
            EmptyView()
            #endif

        case .loading, .error:
            EmptyView()
        }
    }

    func premiumBanner(appAd: Components.Schemas.Ad) -> some View {
        HStack(spacing: .zero) {
            if let iconUrl = appAd.iconURL, let url = URL(string: iconUrl) {
                CachedAsyncImage(url: url, urlCache: .imageCache, content: {
                    $0
                        .resizable()
                        .frame(width: 64, height: 64)
                        .mask(RoundedRectangle(
                            cornerRadius: .large,
                            style: .continuous
                        ))
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                            .stroke(lineWidth: 1)
                            .opacity(0.15)
                        )
                        .onTapGesture {
                            isShowProduct.toggle()
                        }

                }, placeholder: {
                    RoundedRectangle(cornerRadius: .large, style: .continuous)
                        .fillSurfaceSecondary()
                        .frame(width: 64, height: 64)
                })
            }

            VStack(alignment: .leading, spacing: .xxxSmall) {
                HStack {
                    Text(appAd.title)
                        .subheadline(.bold)
                        .onSurfacePrimaryForeground()

                    Bage(color: .warning) {
                        Text("Our app")
                            .bold()
                    }
                }

                Text(appAd.description)
                    .subheadline()
                    .onSurfaceSecondaryForeground()
            }
            .padding(.leading, .xSmall)

            Spacer()

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

struct AdView_Previews: PreviewProvider {
    static var previews: some View {
        AdView()
    }
}
