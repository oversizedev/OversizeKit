//
// Copyright © 2023 Alexander Romanov
// StoreInstructionsErrorView.swift
//

import OversizeUI
import SwiftUI

struct StoreInstructionsErrorView: View {
    let error: Error
    let retryAction: () async -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: .medium) {
            OversizeUI.ErrorView(error: error)

            Button("Try Again") {
                Task {
                    await retryAction()
                }
            }
            .buttonStyle(.primary)

            Button("Maybe Later") {
                continueAction()
            }
            .buttonStyle(.quaternary)
        }
        .paddingContent(.horizontal)
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
