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
    case calendar
    case contacts
    case location
    case notification
    case cloud
    case store
    case lockscreen
    case debug
    case web
}

extension DemoDestinations: NavigationDestination {
    var body: some View {
        switch self {
        case .media:
            MediaKitDemoView()
        case .editor:
            EditorKitDemoView()
        case .calendar:
            CalendarKitDemoView()
        case .contacts:
            ContactsKitDemoView()
        case .location:
            LocationKitDemoView()
        case .notification:
            NotificationKitDemoView()
        case .cloud:
            CloudKitDemoView()
        case .store:
            StoreKitDemoView()
        case .lockscreen:
            LockscreenDemoView()
        case .debug:
            DebugKitDemoView()
        case .web:
            WebKitDemoView()
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
        .appEnvironment()
}
