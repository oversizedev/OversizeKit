//
// Copyright © 2026 Alexander Romanov
// AppUpdatesView.swift, created on 04.03.2026
//

import OversizeArchitecture
import OversizeNavigation
import OversizeNetwork
import OversizeUI
import SwiftUI

@View(module: AppUpdates.self)
public struct AppUpdatesView: ViewProtocol {
    @Environment(\.navigator) var navigator

    public var body: some View {
        NavigationLayoutView("What's New") {
            content
        } background: {
            Color.backgroundSecondary
        }
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
        SectionView {
            VStack(spacing: .zero) {
                ForEach(0 ..< 3, id: \.self) { _ in
                    AppUpdatesPlaceholderRow()
                        .redacted(reason: .placeholder)
                        .disabled(true)
                }
            }
        }
        .surfaceContentRowMargins()
    }

    private func versionsList(_ stateModel: AppUpdatesViewState.StateModel) -> some View {
        VStack(spacing: .medium) {
            if let lastVersion = stateModel.lastVersion {
                SectionView {
                    AppUpdatesLatestVersionCard(version: lastVersion)
                }
            }

            SectionView {
                VStack(spacing: .small) {
                    ForEach(stateModel.versions) { version in
                        AppUpdatesVersionRow(version: version)
                    }

                    AppUpdatesVersionRow(
                        version: stateModel.firstVersion,
                        showsConnector: false
                    )
                }
                .padding(.vertical, .xSmall)
            }
        }
        .surfaceContentRowMargins()
    }
}

#Preview {
    NavigationStack {
        AppUpdates.build()
    }
}
