//
// Copyright © 2022 Alexander Romanov
// PremiumBlockOverlay.swift
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

public struct PremiumBlockOverlay: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @State var isShowPremium = false
    @Environment(\.isPremium) var isPremium
    @Binding var isShow: Bool

    let title: String
    let subtitle: String?

    private let closeAction: (() -> Void)?

    public init(isShow: Binding<Bool> = .constant(true), title: String, subtitle: String?, closeAction: (() -> Void)? = nil) {
        _isShow = isShow
        self.title = title
        self.subtitle = subtitle
        self.closeAction = closeAction
    }

    public func body(content: Content) -> some View {
        if !isPremium, isShow {
            ZStack {
                content

                LinearGradient(colors: [.surfacePrimary.opacity(0), .surfacePrimary, .surfacePrimary],
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: .xxSmall) {
                    VStack(spacing: .xxSmall) {
                        Spacer()

                        PremiumLabel(size: .medium)
                            .padding(.bottom, .medium)

                        VStack(spacing: .small) {
                            Text(title)
                                .title()
                                .foregroundColor(.onSurfaceHighEmphasis)

                            if let subtitle {
                                Text(subtitle)
                                    .headline(.medium)
                                    .foregroundColor(.onSurfaceMediumEmphasis)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.bottom, .small)
                    }
                    .paddingContent()

                    Button {
                        isShowPremium.toggle()
                    } label: {
                        Text(L10n.Button.continue)
                    }
                    .buttonStyle(.primary)
                    .accent()

                    if closeAction != nil {
                        Button {
                            closeAction?()
                        } label: {
                            Text(L10n.Button.close)
                        }
                        .buttonStyle(.quaternary)
                    }
                }
                .paddingContent()
            }
            .sheet(isPresented: $isShowPremium) {
                StoreView()
                    .colorScheme(colorScheme)
            }
        } else {
            content
        }
    }
}

public extension View {
    func premiumContent(_ title: String, subtitle: String?, closeAction: (() -> Void)? = nil) -> some View {
        modifier(PremiumBlockOverlay(title: title, subtitle: subtitle, closeAction: closeAction))
    }

    @available(*, deprecated, renamed: "premiumContent", message: "Renamed")
    func premiumContent(title: String, subtitle: String?, closeAction: (() -> Void)? = nil) -> some View {
        modifier(PremiumBlockOverlay(title: title, subtitle: subtitle, closeAction: closeAction))
    }

    func premiumContent(isShow: Binding<Bool> = .constant(true), title: String, subtitle: String?, closeAction: (() -> Void)? = nil) -> some View {
        modifier(PremiumBlockOverlay(isShow: isShow, title: title, subtitle: subtitle, closeAction: closeAction))
    }
}
