//
// Copyright © 2024 Alexander Romanov
// DeeplinkModifier.swift, created on 12.11.2024
//

import SwiftUI

public struct DeeplinkModifier: ViewModifier {
    private let pub = NotificationCenter.default.publisher(for: NSNotification.Name("Deeplink"))
    private var onReceive: (URL) -> Void

    public init(onReceive: @escaping (URL) -> Void) {
        self.onReceive = onReceive
    }

    public func body(content: Content) -> some View {
        content
            .onReceive(pub) { output in
                if let userInfo = output.userInfo, let info = userInfo["link"] as? String, let url = URL(string: info) {
                    onReceive(url)
                }
            }
    }
}

public extension View {
    func onDeeplink(perform action: @escaping (URL) -> Void) -> some View {
        modifier(DeeplinkModifier(onReceive: action))
    }
}
