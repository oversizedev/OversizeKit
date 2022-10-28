//
// Copyright © 2022 Alexander Romanov
// PremiumBlockOverlay.swift
//

import OversizeUI
import SwiftUI
import OversizeLocalizable

public struct PremiumBlockOverlay: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @State var isShowPremium = false
    @Environment(\.isPremium) var premiumStatus

    let title: String
    let subtitle: String?

    private let closeAction: (() -> Void)?

    public init(title: String, subtitle: String?, closeAction: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.closeAction = closeAction
    }

    public func body(content: Content) -> some View {
        if premiumStatus {
            content
        } else {
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

                        VStack(spacing: .medium) {
                            Text(title)
                                .title()
                                .foregroundColor(.onSurfaceHighEmphasis)

                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .headline()
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
        }
    }
}

public extension View {
    func premiumContent(title: String, subtitle: String?, closeAction: (() -> Void)? = nil) -> some View {
        modifier(PremiumBlockOverlay(title: title, subtitle: subtitle, closeAction: closeAction))
    }
}
