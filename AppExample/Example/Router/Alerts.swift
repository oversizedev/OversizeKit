//
// Copyright © 2023 Alexander Romanov
// Alerts.swift, created on 25.09.2023
//

import OversizeCore
import OversizeLocalizable
import OversizeServices
import SwiftUI

enum RootAlert: Identifiable {
    case dismiss(_ action: () -> Void)
    case delete(_ action: () -> Void)
    case appError(error: Error)

    var id: String {
        switch self {
        case .dismiss:
            "dismiss"
        case .delete:
            "delete"
        case .appError:
            "appError"
        }
    }

    var alert: Alert {
        switch self {
        case let .dismiss(action):
            Alert(
                title: Text("Are you sure you want to dismiss?"),
                primaryButton: .destructive(Text("Dismiss"), action: action),
                secondaryButton: .cancel()
            )
        case let .delete(action):
            Alert(
                title: Text("Are you sure you want to delete?"),
                primaryButton: .destructive(Text("\(L10n.Button.delete)"), action: action),
                secondaryButton: .cancel()
            )
        case let .appError(error):
            Alert(
                title: Text(errorTitle(error)),
                message: errorSubtitle(error).map { Text($0) },
                dismissButton: .cancel()
            )
        }
    }
}

private func errorTitle(_ error: Error) -> String {
    if let localizedError = error as? LocalizedError {
        return localizedError.errorDescription ?? "Error"
    }
    return error.localizedDescription
}

private func errorSubtitle(_ error: Error) -> String? {
    if let localizedError = error as? LocalizedError {
        let subtitle = [
            localizedError.failureReason,
            localizedError.recoverySuggestion,
        ].compactMap { $0 }.joined(separator: "\n")
        return subtitle.isEmpty ? nil : subtitle
    }
    return nil
}
