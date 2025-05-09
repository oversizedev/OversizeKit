//
// Copyright © 2023 Alexander Romanov
// Screens.swift, created on 25.09.2023
//

import OversizeComponents
import OversizeKit
import SwiftUI

enum Screen {
    case settings
    case premium
}

extension Screen: Identifiable {
    var id: String {
        switch self {
        case .settings:
            "settings"
        case .premium:
            "premium"
        }
    }
}

extension Router {
    @ViewBuilder
    func resolve(pathItem: Screen) -> some View {
        switch pathItem {
        case .settings:
            SettingsView {
                AppSettingsView()
            }
        case .premium:
            StoreView()
        }
    }

    func resolveSheet(
        pathItem: Screen,
        detents: Set<PresentationDetent>,
        dragIndicator: Visibility = .automatic,
        dismissDisabled: Bool
    ) -> some View {
        resolve(pathItem: pathItem)
            .presentationDetents(detents)
            .presentationDragIndicator(dragIndicator)
            .interactiveDismissDisabled(dismissDisabled)
    }
}
