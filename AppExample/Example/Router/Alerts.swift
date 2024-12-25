//
// Copyright © 2023 Alexander Romanov
// Alerts.swift, created on 25.09.2023
//

import OversizeLocalizable
import OversizeModels
import OversizeServices
import SwiftUI

enum RootAlert: Identifiable {
    case dismiss(_ action: () -> Void)
    case delete(_ action: () -> Void)
    case appError(error: AppError)

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
        case let .appError(error: error):
            Alert(
                title: Text(error.title),
                message: Text(error.subtitle.valueOrEmpty),
                dismissButton: .cancel()
            )
        }
    }
}
