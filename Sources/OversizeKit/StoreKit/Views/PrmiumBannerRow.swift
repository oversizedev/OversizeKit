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
    #if os(macOS)
    @Environment(\.openWindow) var openWindow
    #endif

    @Environment(\.platform) var platform

    @State var showModal = false

    public init() {
        _viewModel = StateObject(wrappedValue: StoreViewModel())
    }

    public var body: some View {
        VStack {
            #if os(iOS)
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
            #elseif os(macOS)
            Button {
                openWindow(id: "Window.StoreView")
            } label: {
                if viewModel.isPremium || viewModel.isPremiumActivated {
                    subscriptionRow
                } else {
                    banner
                }
            }
            .buttonStyle(.row)
            #endif
        }
        .task {
            await viewModel.fetchData()
        }
    }

    var subscriptionRow: some View {
        HStack(spacing: Space.small) {
            HStack {
                #if os(iOS) || os(macOS)
                Resource.Store.zap
                    .padding(.horizontal, Space.xxSmall)
                    .padding(.vertical, Space.xxSmall)
                #endif
            }
            .background(
                RoundedRectangle(cornerRadius: Radius.medium.rawValue, style: .continuous)
                    .fill(LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color(hex: "EAAB44"),
                                Color(hex: "D24A44"),
                                Color(hex: "9C5BA2"),
                                Color(hex: "4B5B94"),
                            ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )

            Text(Info.store.subscriptionsName)
                .headline(.semibold)
                .foregroundColor(.onSurfacePrimary)

            Spacer()

            HStack(spacing: .small) {
                Text(viewModel.subsribtionStatusText)
                    .headline(.medium)
                    .foregroundColor(.onSurfaceSecondary)

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
                        #if os(iOS) || os(macOS)
                        Resource.Store.zap
                            .colorMultiply(Color(hex: "B75375"))
                        #endif

                        Text(viewModel.productsState.result?.banner.badge ?? "Pro")
                            .font(.system(size: platform == .macOS ? 16 : 20, weight: platform == .macOS ? .bold : .heavy))
                            .foregroundColor(Color(hex: "B75375"))
                            .redacted(reason: viewModel.productsState.isLoading ? .placeholder : .init())
                    }
                    .padding(.leading, platform == .macOS ? Space.xxSmall : Space.xSmall)
                    .padding(.vertical, platform == .macOS ? Space.xxxSmall : Space.xxSmall)
                    .padding(.trailing, platform == .macOS ? Space.xSmall : Space.small)
                }
                .background(
                    RoundedRectangle(cornerRadius: Radius.small.rawValue, style: .continuous)
                        .fill(Color.onPrimary))

                Text(viewModel.productsState.result?.banner.description ?? "Long text")
                    .headline(.semibold)
                    .onPrimaryForeground()
                    .multilineTextAlignment(.center)
                    .padding(.top, Space.xSmall)
                    .frame(maxWidth: 260)
                    .redacted(reason: viewModel.productsState.isLoading ? .placeholder : .init())
            }

            Spacer()
        }
        .padding(.horizontal, Space.small)
        .padding(.vertical, Space.large)
        .background(
            RoundedRectangle(cornerRadius: Radius.medium.rawValue, style: .continuous)
                .fill(LinearGradient(
                    gradient: Gradient(
                        colors: [Color(hex: "EAAB44"),
                                 Color(hex: "D24A44"),
                                 Color(hex: "9C5BA2"),
                                 Color(hex: "4B5B94")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )))
    }
}

struct PrmiumBannerRow_Previews: PreviewProvider {
    static var previews: some View {
        PrmiumBannerRow()
    }
}
