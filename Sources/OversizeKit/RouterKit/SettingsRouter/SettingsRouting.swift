//
// Copyright © 2024 Alexander Romanov
// SettingsRouting.swift, created on 10.05.2024
//

import OversizeRouter
import SwiftUI

public struct SettingsRoutingView<Root>: View where Root: View {
    @StateObject private var router: Router<SettingsScreen> = .init()
    @StateObject private var hudRouter: HUDRouter = .init()
    private let root: () -> Root

    public init(@ViewBuilder root: @escaping () -> Root) {
        self.root = root
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .navigationDestination(for: SettingsScreen.self) { destination in
                    destination.view()
                }
        }
        .onSettingsNavigate(routerNavigate)
        .sheet(
            item: $router.sheet,
            content: { sheet in
                NavigationStack(path: $router.sheetPath) {
                    sheet.view()
                        .navigationDestination(for: SettingsScreen.self) { destination in
                            destination.view()
                        }
                }
                .presentationDetents(router.sheetDetents)
                .presentationDragIndicator(router.dragIndicator)
                .interactiveDismissDisabled(router.dismissDisabled)
                .systemServices()
                .onSettingsNavigate(routerNavigate)
            }
        )
        #if os(iOS)
        .fullScreenCover(item: $router.fullScreenCover) { fullScreenCover in
            fullScreenCover.view()
                .systemServices()
                .onSettingsNavigate(routerNavigate)
        }
        #endif
    }

    func routerNavigate(navigationType: SettingsNavigationType) {
        switch navigationType {
        case let .move(screen):
            router.move(screen)
        case .backToRoot:
            router.backToRoot()
        case let .back(count):
            router.back(count)
        case let .present(sheet, detents: detents, indicator: indicator, dismissDisabled: dismissDisabled):
            router.present(sheet, detents: detents, indicator: indicator, dismissDisabled: dismissDisabled)
        case .dismiss:
            router.dismiss()
        case .dismissSheet:
            router.dismissSheet()
        case .dismissFullScreenCover:
            router.dismissFullScreenCover()
        case let .dismissDisabled(isDismissDisabled):
            router.dismissDisabled(isDismissDisabled)
        case let .presentHUD(text, type):
            hudRouter.present(text, type: type)
        }
    }
}
