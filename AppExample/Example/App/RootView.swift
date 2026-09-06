//
// Copyright © 2026 Alexander Romanov
// RootView.swift, created on 06.09.2026
//

import NavigatorUI
import OversizeKit
import SwiftUI

struct RootView: View {
    @State private var navigator: Navigator = .init(configuration: .init())

    var body: some View {
        RootTabView()
            .coreServices()
            .navigationRoot(navigator)
    }
}

#Preview {
    RootView()
}
