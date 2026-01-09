//
// Copyright © 2024 Alexander Romanov
// OnboardView.swift, created on 16.09.2024
//

import OversizeUI
import SwiftUI

public struct OnboardView<C, A>: View where A: View, C: View {
    private let content: C
    private let actions: Group<A>
    private let backAction: (() -> Void)?
    private let skipAction: (() -> Void)?
    private let helpAction: (() -> Void)?

    public init(
        @ViewBuilder content: () -> C,
        @ViewBuilder actions: () -> A,
        backAction: (() -> Void)? = nil,
        skipAction: (() -> Void)? = nil,
        helpAction: (() -> Void)? = nil
    ) {
        self.content = content()
        self.actions = Group { actions() }
        self.backAction = backAction
        self.skipAction = skipAction
        self.helpAction = helpAction
    }

    public var body: some View {
        content
            .ignoresSafeArea(.all)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .safeAreaInset(edge: .top, content: topButtons)
            .safeAreaInset(edge: .bottom, content: bottomButtons)
    }

    private func topButtons() -> some View {
        HStack {
            #if os(iOS)
            if helpAction != nil {
                Button {
                    helpAction?()
                } label: {
                    Text("Help")
                }
                .buttonStyle(.tertiary)
                .controlBorderShape(.capsule)
                .accent()
                .controlSize(.mini)
            }
            #endif

            Spacer()

            if skipAction != nil {
                Button {
                    skipAction?()
                } label: {
                    Text("Skip")
                }
                .buttonStyle(.tertiary)
                .controlBorderShape(.capsule)
                .accent()
                #if !os(tvOS)
                    .controlSize(.mini)
                #endif
            }
        }
        .padding(.medium)
    }

    private func bottomButtons() -> some View {
        #if os(iOS)
        HStack(spacing: .small) {
            if let backAction {
                Button {
                    backAction()
                } label: {
                    Image.Base.arrowLeft.icon()
                }
                .buttonStyle(.quaternary)
                .accentColor(.secondary)
            }

            VStack(spacing: .xxxSmall) {
                actions
            }
        }
        .padding(.medium)
        #else
        HStack(spacing: .xSmall) {
            if let helpAction {
                Button("Help", action: helpAction)
                    .help("Help")
                #if !os(tvOS)
                    .controlSize(.extraLarge)
                    .buttonStyle(.bordered)
                #endif
            }

            Spacer()

            if let backAction {
                Button(
                    "Back",
                    action: backAction
                )
                #if !os(tvOS)
                .controlSize(.extraLarge)
                #endif
                .buttonStyle(.bordered)
            }

            actions
            #if !os(tvOS)
            .controlSize(.extraLarge)
            #endif
            .buttonStyle(.borderedProminent)
        }
        .padding(.small)
        .background(Color.surfacePrimary)
        .overlay(alignment: .top) {
            Separator()
        }
        #endif
    }
}
