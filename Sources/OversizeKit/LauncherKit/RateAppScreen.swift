//
// Copyright © 2022 Alexander Romanov
// RateAppScreen.swift
//

import FactoryKit
import OversizeResources
import OversizeServices
import OversizeUI
import SwiftUI

struct RateAppScreen: View {
    @Injected(\.appStoreReviewService) var reviewService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("If you love, evaluate)")
                .largeTitle(.bold)
                .onSurfacePrimary()

            Spacer()

            Illustration.Characters.rate
                .resizable()
                .aspectRatio(contentMode: .fit)

            Spacer()

            Text((Info.App.name ?? "App") + " is developed only one person, and your assessment would very much drop in")
                .title3()
                .onSurfacePrimary()

            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.xLarge)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) {
                    Task {
                        await reviewService.reviewBannerClosed()
                        dismiss()
                    }
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
                #if !os(tvOS) && !os(watchOS)
                    .keyboardShortcut(.cancelAction)
                #endif
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let reviewUrl = Info.App.appStoreReviewUrl {
                HStack(spacing: .large) {
                    Link(destination: reviewUrl) {
                        Icon("hand.thumbsup").iconColor(.onPrimary)
                    }
                    .buttonStyle(.iconPrimary)
                    .accent()
                    .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            await reviewService.estimate(goodRating: true)
                            dismiss()
                        }
                    })

                    Button {
                        Task {
                            await reviewService.estimate(goodRating: false)
                            dismiss()
                        }
                    } label: {
                        Icon("hand.thumbsdown").iconColor(.onSurfacePrimary)
                    }
                    .buttonStyle(.iconSecondary)
                }
                .elevation(.z3)
                #if !os(tvOS)
                    .controlSize(.large)
                #endif
                    .padding(.bottom, .medium)
            }
        }
    }
}

struct RateAppScreen_Previews: PreviewProvider {
    static var previews: some View {
        RateAppScreen()
    }
}
