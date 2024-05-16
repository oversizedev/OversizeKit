//
// Copyright © 2024 Alexander Romanov
// Router.swift, created on 13.04.2024
//

import SwiftUI

@available(iOS 16.0, *)
public final class Router<Destination: Routable>: ObservableObject {
    // Path
    @Published public var path = NavigationPath()
    @Published public var sheetPath = NavigationPath()
    @Published public var fullScreenCoverPath = NavigationPath()

    // Sheets
    @Published public var sheet: Destination?
    @Published public var fullScreenCover: Destination?
    @Published public var menu: Destination?
    @Published public var sheetDetents: Set<PresentationDetent> = []
    @Published public var dragIndicator: Visibility = .hidden
    @Published public var dismissDisabled: Bool = false

    public init() {}
}

@available(iOS 16.0, *)
public extension Router {
    func changeMenu(_ screen: Destination) {
        menu = screen
    }
}

@available(iOS 16.0, *)
public extension Router {
    func move(_ screen: Destination) {
        path.append(screen)
    }

    func backToRoot() {
        path.removeLast(path.count)
    }

    func back(_ count: Int = 1) {
        let pathCount = path.count - count
        if pathCount > -1 {
            path.removeLast(count)
        }
    }
}

// MARK: - Sheets

@available(iOS 16.0, *)
public extension Router {
    func present(_ sheet: Destination, fullScreen: Bool = false) {
        if fullScreen {
            if fullScreenCover != nil {
                fullScreenCover = nil
            }
            fullScreenCover = sheet
        } else {
            restSheet()
            self.sheet = sheet
        }
    }

    func present(_ sheet: Destination, detents: Set<PresentationDetent> = [.large], indicator: Visibility = .hidden, dismissDisabled: Bool = false) {
        restSheet()
        sheetDetents = detents
        dragIndicator = indicator
        self.dismissDisabled = dismissDisabled
        self.sheet = sheet
    }

    func backOrDismiss() {
        if sheet != nil || fullScreenCover != nil {
            sheet = nil
            fullScreenCover = nil
        } else {
            back()
        }
    }

    func dismiss() {
        sheet = nil
        fullScreenCover = nil
    }

    func dismissSheet() {
        sheet = nil
    }

    func dismissFullScreenCover() {
        fullScreenCover = nil
    }

    func dismissDisabled(_ isDismissDisabled: Bool = true) {
        dismissDisabled = isDismissDisabled
    }

    private func restSheet() {
        if sheet != nil {
            sheet = nil
        }
        if fullScreenCover != nil {
            fullScreenCover = nil
        }
        if dragIndicator != .hidden {
            dragIndicator = .hidden
        }
        if dismissDisabled {
            dismissDisabled = false
        }
        if sheetDetents.isEmpty == false {
            sheetDetents = []
        }
    }
}
