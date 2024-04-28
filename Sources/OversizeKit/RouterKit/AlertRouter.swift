//
// Copyright © 2024 Alexander Romanov
// AlertRouter.swift, created on 11.04.2024
//

import Foundation

public class AlertRouter<RootAlert: Alertable>: ObservableObject {
    // Alert
    @Published public var alert: RootAlert? = nil

    public init() {}
}

public extension AlertRouter {
    func present(_ alert: RootAlert) {
        self.alert = alert
    }

    func dismiss() {
        alert = nil
    }
}
