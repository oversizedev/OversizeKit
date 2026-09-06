//
// Copyright © 2026 Alexander Romanov
// DemoDestinations.swift, created on 06.09.2026
//

import NavigatorUI
import OversizeKit
import SwiftUI

enum DemoDestinations: Hashable {
    case media
    case editor
}

extension DemoDestinations: NavigationDestination {
    var body: some View {
        switch self {
        case .media:
            MediaKitDemoView()
        case .editor:
            EditorKitDemoView()
        }
    }
}

struct DemoNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTab.demo.id) {
            DemoListView()
                .navigationDestination(DemoDestinations.self)
                .navigationAutoReceive(DemoDestinations.self)
        }
    }
}

#Preview {
    DemoNavigationStack()
        .coreServices()
}
