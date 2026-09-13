//
// Copyright © 2026 Alexander Romanov
// AppUpdatesView.swift, created on 04.03.2026
//

import NavigatorUI
import OversizeArchitecture
import OversizeNavigation
import OversizeNetwork
import OversizeUI
import SwiftUI

@View(module: AppUpdates.self)
public struct AppUpdatesView: ViewProtocol {
    @Environment(\.navigator) var navigator

    public var body: some View {
        NavigationListLayoutView("What's New") {
            content
        } background: {
            Color.backgroundSecondary
        }
        .listLayoutStyle(.insetGrouped)
        .toolbarTitleDisplayMode(.inline)
        .task { reducer(.onFetch) }
        .navigationBack($viewState.isNavigationBack)
    }

    @ViewBuilder
    var content: some View {
        switch viewState.state {
        case .idle, .loading:
            placeholder
        case let .result(versions):
            versionsList(versions)
        case let .error(error):
            ErrorView(error: error)
        }
    }

    private var placeholder: some View {
        ListSection {
            VStack(spacing: .zero) {
                ForEach(0 ..< 3, id: \.self) { _ in
                    AppUpdatesPlaceholderRow()
                        .redacted(reason: .placeholder)
                        .disabled(true)
                }
            }
        }
    }

    @ViewBuilder
    private func versionsList(_ stateModel: AppUpdatesViewState.StateModel) -> some View {
        if let lastVersion = stateModel.lastVersion {
            AppUpdatesLatestVersionCard(version: lastVersion)
        }

        ListSection {
            ForEach(stateModel.versions) { version in
                AppUpdatesVersionRow(version: version)
            }

            AppUpdatesVersionRow(
                version: stateModel.firstVersion,
                showsConnector: false
            )
        }
        #if !os(watchOS) && !os(tvOS)
        .listRowSeparator(.hidden)
        #endif
    }
}

#Preview {
    NavigationStack {
        AppUpdates.build()
    }
}
