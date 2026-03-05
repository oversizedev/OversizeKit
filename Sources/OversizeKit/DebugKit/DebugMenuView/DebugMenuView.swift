//
// Copyright © 2023 Alexander Romanov
// DebugMenuView.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeNavigation
import OversizeNetwork
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
            SectionView("API Server") {
                Picker("Server", selection: $viewModel.selectedServer) {
                    ForEach(APIServer.allCases) { server in
                        Text(server.title).tag(server)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, .medium)
                .padding(.vertical, .small)
                .onChange(of: viewModel.selectedServer) { _, new in
                    viewModel.onChangeAPIServer(new)
                }
            }
            .sectionContentCompactRowMargins()

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
