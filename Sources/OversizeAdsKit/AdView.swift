//
// Copyright © 2022 Alexander Romanov
// AdView.swift
//

import CachedAsyncImage
import OversizeCore
import OversizeKit
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
        if isPremium { EmptyView() } else {
            #if os(iOS)
                Surface {
                    isShowProduct.toggle()
                } label: {
                    premiumBanner
                }
                .surfaceContentInsets(.xSmall)
                .appStoreOverlay(isPresent: $isShowProduct, appId: viewModel.appAd?.id ?? "")
            #else
                EmptyView()
            #endif
        }
    }

    var premiumBanner: some View {
        HStack(spacing: .zero) {
            CachedAsyncImage(url: URL(string: "\(Info.links?.company.cdnString ?? "")/assets/apps/\(viewModel.appAd?.path ?? "")/icon.png"), urlCache: .imageCache, content: {
                $0
                    .resizable()
                    .frame(width: 64, height: 64)
                    .mask(RoundedRectangle(cornerRadius: .large,
                                           style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16,
                                         style: .continuous)
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

            VStack(alignment: .leading, spacing: .xxxSmall) {
                HStack {
                    Text(viewModel.appAd?.name ?? "")
                        .subheadline(.bold)
                        .onSurfaceHighEmphasisForegroundColor()

                    Bage(color: .warning) {
                        Text("Our app")
                            .bold()
                    }
                }

                Text(viewModel.appAd?.title ?? "")
                    .subheadline()
                    .onSurfaceMediumEmphasisForegroundColor()
            }
            .padding(.leading, .xSmall)

            Spacer()

            Button("Get") {
                isShowProduct.toggle()
            }
            .buttonStyle(.tertiary)
            .controlBorderShape(.capsule)
            .controlSize(.small)
            .padding(.trailing, .xxxSmall)
            .loading(isShowProduct)
        }
    }
}

struct AdView_Previews: PreviewProvider {
    static var previews: some View {
        AdView()
    }
}
