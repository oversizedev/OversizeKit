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

    @State private var isRetrying = false

    var body: some View {
        VStack(spacing: .medium) {
            OversizeUI.ErrorView(error: error)

            Button(L10n.Button.tryAgain) {
                isRetrying = true
                Task {
                    await retryAction()
                    isRetrying = false
                }
            }
            .buttonStyle(.primary)
            .loading(isRetrying)
            .disabled(isRetrying)
            .accessibilityIdentifier("store.error.tryAgain")

            Button(L10n.Button.later) {
                continueAction()
            }
            .buttonStyle(.quaternary)
            .accessibilityIdentifier("store.error.continueFree")
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
