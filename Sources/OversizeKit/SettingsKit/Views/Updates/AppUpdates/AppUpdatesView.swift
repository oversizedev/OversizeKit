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
                    Row("Version 1.0.0", subtitle: "What's new in this version") {}
                        .rowArrow()
                        .buttonStyle(.row)
                        .redacted(reason: .placeholder)
                        .disabled(true)
                }
            }
        }
        .surfaceContentRowMargins()
    }

    private func versionsList(_ versions: [Components.Schemas.Version]) -> some View {
        SectionView {
            VStack(spacing: .zero) {
                ForEach(versions) { version in
                    if versions.first == version {
                        Row(version.version, subtitle: version.whatsNew)
                    } else {
                        Row(version.version, subtitle: version.whatsNew) {
                            navigator.navigate(to: SettingsDestinations.appUpdate(version: version))
                        }
                        .rowArrow()
                        .buttonStyle(.row)
                    }
                }
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
