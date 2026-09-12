//
// Copyright © 2026 Alexander Romanov
// StoreInstructionsErrorView.swift
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

struct StoreInstructionsErrorView: View {
    let error: Error
    let retryAction: () async -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: .medium) {
            OversizeUI.ErrorView(error: error)

            Button(L10n.Button.tryAgain) {
                Task {
                    await retryAction()
                }
            }
            .buttonStyle(.primary)
            .accessibilityIdentifier("store.error.tryAgain")

            Button("Continue without Pro") {
                continueAction()
            }
            .buttonStyle(.quaternary)
            .accessibilityIdentifier("store.error.continueWithoutPro")
        }
    }
}

#Preview {
    StoreInstructionsErrorView(
        error: NSError(
            domain: "OversizeKit",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unknown network error"]
        ),
        retryAction: {},
        continueAction: {}
    )
}
