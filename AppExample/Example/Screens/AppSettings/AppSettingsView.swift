//
// Copyright © 2023 Alexander Romanov
// AppSettingsView.swift, created on 25.09.2023
//

import OversizeUI
import SwiftUI

struct AppSettingsView: View {
    private let openAppSettings: () -> Void

    init(openAppSettings: @escaping () -> Void) {
        self.openAppSettings = openAppSettings
    }

    var body: some View {
        Row("App settings") {
            openAppSettings()
        } leading: {
            Image(systemName: "slider.horizontal.3")
        }
        .rowArrow()
        .buttonStyle(.row)
        .accessibilityIdentifier(AccessibilityIdentifier.appSettingsRow)
    }
}

extension AppSettingsView {
    enum AccessibilityIdentifier {
        static let appSettingsRow = "settings.appSection.row"
    }
}

#Preview {
    AppSettingsView {}
}
