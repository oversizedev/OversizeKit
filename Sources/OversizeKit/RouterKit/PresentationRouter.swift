//
// Copyright © 2024 Alexander Romanov
// PresentationRouter.swift, created on 16.05.2024
//  

import Foundation

public enum HUDMessageType {
    case `default`
    case success
    case destructive
    case deleted
    case archived
}

public class PresentationRouter<RootAlert: Alertable>: ObservableObject {
    // Alert
    @Published public var alert: RootAlert? = nil
    @Published public var isShowHud: Bool = false
    @Published public var hudText: String = ""
    @Published public var type: HUDMessageType = .default

    public init() {}
}

public extension PresentationRouter {
    func present(_ alert: RootAlert) {
        self.alert = alert
    }

    func dismiss() {
        alert = nil
    }
}

public extension PresentationRouter {
    func present(_ text: String, type: HUDMessageType = .default) {
        hudText = text
        self.type = type
        isShowHud = true
    }
}
