//
// Copyright © 2023 Alexander Romanov
// AppSettingsPageView.swift, created on 25.09.2023
//

import OversizeUI
import SwiftUI

struct AppSettingsPageView: View {
    @AppStorage("AppState.Option") private var option: String = "Default option"

    var body: some View {
        ScrollView {
            SectionView {
                VStack(spacing: .zero) {
                    Row(option) {
                        Image(systemName: "checkmark.circle")
                    }
                }
            }
            .sectionContentCompactRowMargins()
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Option")
        .accessibilityIdentifier(AccessibilityIdentifier.screen)
    }
}

extension AppSettingsPageView {
    enum AccessibilityIdentifier {
        static let screen = "settings.appSettingsPage.screen"
    }
}

#Preview {
    NavigationStack {
        AppSettingsPageView()
    }
}
