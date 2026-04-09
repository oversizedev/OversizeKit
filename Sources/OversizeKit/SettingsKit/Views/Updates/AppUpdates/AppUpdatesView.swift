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

    private func versionsList(_ stateModel: AppUpdatesViewState.StateModel) -> some View {
        VStack(spacing: .zero) {
            if let lastVersion = stateModel.lastVersion {
                SectionView {
                    HStack(spacing: .small) {
                        Icon(Image.Base.Check.Circle.fill)
                            .iconColor(Color.success)
                            .iconOnSurface()

                        VStack(alignment: .leading, spacing: .xxxSmall) {
                            HStack {
                                Text(lastVersion.version)
                                    .headline()
                                    .onSurfacePrimary()

                                Badge {
                                    Text("Latest")
                                }
                            }
                            if let whatsNew = lastVersion.whatsNew {
                                Text(whatsNew)
                                    .body()
                                    .onSurfaceSecondary()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, .small)
                    .padding(.vertical, .xxSmall)
                }
            }

            SectionView {
                LazyVStack(spacing: .zero) {
                    ForEach(stateModel.versions) { version in
                        HStack(alignment: .top, spacing: .medium) {
                            VStack {
                                Icon(Image.Base.Clock.fill)
                                    .iconColor(Color.onSurfaceTertiary)

                                Separator(.vertical)
                            }

                            VStack(alignment: .leading, spacing: .xxxSmall) {
                                Text(version.version)
                                    .headline()
                                    .onSurfacePrimary()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if let whatsNew = version.whatsNew {
                                    Text(whatsNew)
                                        .body()
                                        .onSurfaceSecondary()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(.bottom, .xSmall)
                        }
                        .padding(
                            .init(
                                top: .zero,
                                leading: .medium,
                                bottom: .xxSmall,
                                trailing: .xxSmall
                            )
                        )
                    }

                    HStack(alignment: .top, spacing: .medium) {
                        VStack {
                            Icon(Image.Base.Clock.fill)
                                .iconColor(Color.onSurfaceTertiary)
                        }

                        VStack(alignment: .leading, spacing: .xxxSmall) {
                            Text(stateModel.firstVersion.version)
                                .headline()
                                .onSurfacePrimary()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(
                        .init(
                            top: .zero,
                            leading: .medium,
                            bottom: .xxSmall,
                            trailing: .xxSmall
                        )
                    )
                }
                .padding(.vertical, .small)
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
