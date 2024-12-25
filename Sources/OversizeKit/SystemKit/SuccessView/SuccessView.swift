//
// Copyright © 2024 Alexander Romanov
// ErrorButtnType.swift, created on 15.11.2024
//

import OversizeLocalizable
import OversizeModels
import OversizeResources
import OversizeUI
import SwiftUI

public struct SuccessView<C, A>: View where C: View, A: View {
    private let image: Image?
    private let title: String
    private let subtitle: String?
    private let closeAction: (() -> Void)?
    private let actions: Group<A>?
    private let content: C?

    public init(
        image: Image? = nil,
        title: String,
        subtitle: String? = nil,
        closeAction: (() -> Void)? = nil,
        @ViewBuilder actions: @escaping () -> A,
        @ViewBuilder content: () -> C
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.closeAction = closeAction
        self.actions = Group { actions() }
        self.content = content()
    }

    public var body: some View {
        #if os(macOS)
        HStack(spacing: .medium) {
            VStack(alignment: .center, spacing: .large) {
                Spacer()
                if let image {
                    image
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .bottom)
                } else {
                    Image.Illustration.Status.success
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .bottom)
                }
                TextBox(
                    title: title,
                    subtitle: subtitle,
                    spacing: .xxSmall
                )
                .multilineTextAlignment(.center)

                if actions != nil {
                    VStack(spacing: .small) {
                        actions
                            .controlSize(.large)
                    }
                    .frame(width: 200)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)

            if let content {
                Surface {
                    content
                }
                .surfaceClip(true)
                .surfaceStyle(.secondary)
                .surfaceContentMargins(.zero)
            }
        }
        .paddingContent()
        #else
        VStack(alignment: .center, spacing: .large) {
            Spacer()
            if let image {
                image
                    .frame(width: 218, height: 218, alignment: .bottom)
            } else {
                Illustration.Objects.Check.medium
                    .frame(width: 218, height: 218, alignment: .bottom)
            }
            TextBox(
                title: title,
                subtitle: subtitle,
                spacing: .xxSmall
            )
            .multilineTextAlignment(.center)
            Spacer()

            if let content {
                VStack {
                    content

                    Spacer()
                }
            }

            if actions != nil {
                VStack(spacing: .small) {
                    actions
                        .controlSize(.large)
                }
                .padding(.top, .xxSmall)
            }
        }
        .paddingContent()

        #endif
    }
}
