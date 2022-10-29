//
// Copyright © 2022 Alexander Romanov
// AdView.swift
//

import OversizeServices
import OversizeStoreKit
import OversizeUI
import SwiftUI

public struct AdView: View {
    @Environment(\.isPremium) var isPremium: Bool

    let app = Info.all?.apps.filter { $0.id != Info.app.appStoreID }.randomElement()
    @State var isShowProduct = false

    public init() {}

    public var body: some View {
        if isPremium { EmptyView() } else {
            #if os(iOS)
            Surface {
                isShowProduct.toggle()
            } label: {
                HStack(spacing: .zero) {
                    AsyncImage(url: URL(string: "https://cdn.oversize.design/assets/apps/\(app?.path ?? "")/icon.png"), content: {
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
                            Text(app?.name ?? "")
                                .subheadline(.bold)
                                .foregroundOnSurfaceHighEmphasis()

                            Bage(color: .warning) {
                                Text("Ad")
                                    .bold()
                            }
                        }

                        Text(app?.title ?? "")
                            .subheadline()
                            .foregroundOnSurfaceMediumEmphasis()
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
            .controlPadding(.xSmall)
            .appStoreOverlay(isPresent: $isShowProduct, appId: app?.id ?? "")
            #else
            EmptyView()
            #endif
        }
    }
}
