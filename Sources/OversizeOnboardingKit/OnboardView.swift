//
// Copyright © 2024 Alexander Romanov
// OnboardView.swift, created on 16.09.2024
//

import OversizeUI
import SwiftUI

public struct OnboardView<C: View, A: View>: View {
    private let content: C
    private let actions: Group<A>
    private let backAction: (() -> Void)?
    private let skipAction: (() -> Void)?
    private let helpAction: (() -> Void)?
    private var isIgnoresSafeArea: Bool = true

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
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .safeAreaBarTop(content: topButtons)
            .safeAreaBarBottom(content: bottomButtons)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
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

            if helpAction != nil || skipAction != nil {
                Spacer()
            }

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
        .padding(helpAction != nil || skipAction != nil ? .medium : .zero)
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

#Preview {
    NavigationStack {
        OnboardView(
            content: {
                VStack(spacing: .large) {
                    Spacer()

                    Image(systemName: "star.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)

                    VStack(spacing: .small) {
                        Text("Welcome")
                            .title()

                        Text("Start your journey with our app")
                            .body()
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
                .padding(.horizontal, .large)
            },
            actions: {
                Button("Continue") {
                    print("Continue tapped")
                }
            },
            backAction: {
                print("Back tapped")
            },
            skipAction: {
                print("Skip tapped")
            },
            helpAction: {
                print("Help tapped")
            }
        )
    }
}

#Preview("Multiple Actions") {
    NavigationStack {
        OnboardView(
            content: {
                VStack(spacing: .large) {
                    Spacer()

                    Image(systemName: "bell.badge.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.blue)

                    VStack(spacing: .small) {
                        Text("Enable Notifications")
                            .title2()

                        Text("Get notified about important updates")
                            .subheadline()
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, .large)

                    Spacer()
                }
            },
            actions: {
                Button("Enable") {
                    print("Enable tapped")
                }

                Button("Maybe Later") {
                    print("Later tapped")
                }
                .buttonStyle(.secondary)
            },
            backAction: {
                print("Back")
            },
            skipAction: {
                print("Skip")
            }
        )
    }
}

#Preview("No Back Button") {
    NavigationStack {
        OnboardView(
            content: {
                VStack(spacing: .large) {
                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(.green)

                    VStack(spacing: .small) {
                        Text("All Set!")
                            .largeTitle()

                        Text("You're ready to get started")
                            .body()
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            },
            actions: {
                Button("Get Started") {
                    print("Get started")
                }
            }
        )
    }
}
