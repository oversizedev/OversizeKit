//
// Copyright © 2023 Alexander Romanov
// DebugMenuView.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeNavigation
import OversizeServices
import OversizeUI
import SwiftUI

public struct DebugMenuView: View {
    @StateObject private var viewModel = DebugMenuViewModel()

    public init() {}

    public var body: some View {
        NavigationLayoutView("Debug") {
            contentView
        } background: {
            Color.backgroundSecondary
        }
        .toolbarTitleDisplayMode(.inline)
    }

    var contentView: some View {
        LeadingVStack {
            SectionView {
                Row(
                    "Rest onboarding",
                    action: viewModel.onTapRestOnboarding
                )

                Row(
                    "Rest app run count",
                    action: viewModel.onTapRestAppRunCount
                )
            }
            .sectionContentCompactRowMargins()
        }
    }
}

#Preview {
    DebugMenuView()
}
