//
// Copyright © 2024 Alexander Romanov
// SettingsRouting.swift, created on 10.05.2024
//

import OversizeRouter
import SwiftUI

public struct SettingsRoutingView: View {
    public init() {}

    public var body: some View {
        RoutingView<SettingsView, SettingsScreen> {
            SettingsView {
                EmptyView()
            }
        }
        .systemServices()
    }
}
