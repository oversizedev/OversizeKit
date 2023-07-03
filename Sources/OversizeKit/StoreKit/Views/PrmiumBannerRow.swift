//
// Copyright © 2023 Alexander Romanov
// PrmiumBannerRow.swift
//

import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

// swiftlint:disable all
public struct PrmiumBannerRow: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: StoreViewModel

    @State var showModal = false

    public init() {
        _viewModel = StateObject(wrappedValue: StoreViewModel())
    }

    public var body: some View {
        VStack {
            NavigationLink {
                StoreView()
                    .closable(false)
            } label: {
                if viewModel.isPremium || viewModel.isPremiumActivated {
                    subscriptionRow
                } else {
                    banner
                }
            }
            .buttonStyle(.row)
        }
        .task {
            await viewModel.fetchData()
            if case let .result(products) = viewModel.state {
                await viewModel.updateState(products: products)
            }
        }
    }

    var subscriptionRow: some View {
        HStack(spacing: Space.small) {
            HStack {
                #if os(iOS)
                    Resource.Store.zap
                        .padding(.horizontal, Space.xxSmall)
                        .padding(.vertical, Space.xxSmall)
                #endif

                #if os(macOS)
                    Resource.Store.zap
                        .padding(.horizontal, Space.xxSmall)
                        .padding(.vertical, Space.xxSmall)
                #endif
            }
            .background(
                RoundedRectangle(cornerRadius: Radius.medium.rawValue, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(
                            colors: [Color(hex: "EAAB44"),
                                     Color(hex: "D24A44"),
                                     Color(hex: "9C5BA2"),
                                     Color(hex: "4B5B94")]),
                        startPoint: .topLeading, endPoint: .bottomTrailing))
            )

            Text(Info.store.subscriptionsName)
                .headline(.semibold)
                .foregroundColor(.onSurfaceHighEmphasis)

            Spacer()

            HStack(spacing: .small) {
                Text(viewModel.subsribtionStatusText)
                    .headline(.medium)
                    .foregroundColor(.onSurfaceMediumEmphasis)

                Circle()
                    .foregroundColor(viewModel.subsribtionStatusColor)
                    .frame(width: 8, height: 8)
            }

        }.padding(.vertical, Space.small)
            .padding(.leading, .small)
            .padding(.leading, .xxxSmall)
            .padding(.trailing, 26)
    }
}

public extension PrmiumBannerRow {
    var banner: some View {
        HStack {
            Spacer()

            VStack {
                /* PremiumLabel(text: AppInfo.store.subscriptionsName, size: .medium)
                 .monochrom() */
                HStack {
                    HStack(alignment: .center, spacing: Space.xxSmall) {
                        #if os(iOS)
                            Resource.Store.zap
                                .colorMultiply(Color(hex: "B75375"))
                        #endif

                        #if os(macOS)
                            Resource.Store.zap
                        #endif

                        Text(Info.store.subscriptionsName)
                            .font(.system(size: 20, weight: .heavy))
                            .title3()
                            .foregroundColor(Color(hex: "B75375"))
                    }
                    .padding(.leading, Space.xSmall)
                    .padding(.vertical, Space.xxSmall)
                    .padding(.trailing, Space.small)
                }
                .background(
                    RoundedRectangle(cornerRadius: Radius.small.rawValue, style: .continuous)
                        .fill(Color.onPrimaryHighEmphasis

                        ))

                Text(Info.store.subscriptionsDescription)
                    .headline(.semibold)
                    .onPrimaryHighEmphasisForegroundColor()
                    .multilineTextAlignment(.center)
                    .padding(.top, Space.xSmall)
                    .frame(maxWidth: 260)
            }

            Spacer()
        }
        .padding(.horizontal, Space.small)
        .padding(.vertical, Space.large)
        .background(
            RoundedRectangle(cornerRadius: Radius.medium.rawValue, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(
                        colors: [Color(hex: "EAAB44"),
                                 Color(hex: "D24A44"),
                                 Color(hex: "9C5BA2"),
                                 Color(hex: "4B5B94")]),
                    startPoint: .topLeading, endPoint: .bottomTrailing)))
    }
}

struct PrmiumBannerRow_Previews: PreviewProvider {
    static var previews: some View {
        PrmiumBannerRow()
    }
}
