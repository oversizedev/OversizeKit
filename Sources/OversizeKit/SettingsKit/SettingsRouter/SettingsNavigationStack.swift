//
// Copyright © 2024 Alexander Romanov
// SettingsRouting.swift, created on 10.05.2024
//

import NavigatorUI
import SwiftUI

public struct SettingsNavigationStack<AppSection: View, HeadSection: View>: View {
    private let appSection: AppSection
    private let headSection: HeadSection

    public init(
        @ViewBuilder appSection: () -> AppSection,
        @ViewBuilder headSection: () -> HeadSection
    ) {
        self.appSection = appSection()
        self.headSection = headSection()
    }

    public var body: some View {
        ManagedNavigationStack {
            SettingsView(
                appSection: { appSection },
                headSection: { headSection }
            )
            .navigationDestinationAutoReceive(SettingsDestinations.self)
        }
    }
}

public extension SettingsNavigationStack where HeadSection == EmptyView {
    init(@ViewBuilder appSection: () -> AppSection) {
        self.init(
            appSection: appSection,
            headSection: { EmptyView() }
        )
    }
}
