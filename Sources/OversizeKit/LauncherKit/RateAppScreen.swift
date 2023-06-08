//
// Copyright © 2022 Alexander Romanov
// RateAppScreen.swift
//

import Factory
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
                .onSurfaceHighEmphasisForegroundColor()

            Spacer()

            Illustration.Characters.rate
                .resizable()
                .aspectRatio(contentMode: .fit)

            Spacer()

            Text((Info.app.name ?? "App") + " is developed only one person, and your assessment would very much drop in")
                .title3()
                .onSurfaceHighEmphasisForegroundColor()

            Spacer()

            if let reviewUrl = Info.url.appStoreReview {
                HStack(spacing: .large) {
                    Link(destination: reviewUrl) {
                        IconDeprecated(.thumbsUp, color: .onPrimaryHighEmphasis)
                    }
                    .buttonStyle(.primary(infinityWidth: false))
                    .accent()
                    .simultaneousGesture(TapGesture().onEnded {
                        reviewService.estimate(goodRating: true)
                        dismiss()
                    })

                    Button {
                        reviewService.estimate(goodRating: false)
                        dismiss()
                    } label: {
                        IconDeprecated(.thumbsDown, color: .onSurfaceHighEmphasis)
                    }
                    .buttonStyle(.secondary(infinityWidth: false))
                }
                .controlBorderShape(.capsule)
                .elevation(.z3)
                .controlSize(.large)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.xLarge)
        .overlay(alignment: .topTrailing) {
            Button {
                reviewService.rewiewBunnerClosed()
                dismiss()
            } label: {
                IconDeprecated(.xMini, color: .onSurfaceHighEmphasis)
            }
            .buttonStyle(.tertiary(infinityWidth: false))
            .controlSize(.mini)
            .controlBorderShape(.capsule)
            .padding(.medium)
        }
        // reviewService.rewiewBunnerClosed()
    }
}

struct RateAppScreen_Previews: PreviewProvider {
    static var previews: some View {
        RateAppScreen()
    }
}
