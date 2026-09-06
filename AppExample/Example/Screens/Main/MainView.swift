//
// Copyright © 2023 Alexander Romanov
// MainView.swift, created on 25.09.2023
//

import OversizeKit
import OversizeNoticeKit
import OversizeUI
import SwiftUI

struct MainView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                NoticeListView()

                AdView()

                SectionView("Launcher") {
                    VStack(spacing: .zero) {
                        Row("Onboarding, lockscreen, paywall and rate prompts are presented by Launcher before this screen becomes reachable")
                            .multilineTextAlignment(.leading)
                    }
                }
                .sectionContentCompactRowMargins()
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle(RootTab.main.title)
        .accessibilityIdentifier(AccessibilityIdentifier.screen)
    }
}

extension MainView {
    enum AccessibilityIdentifier {
        static let screen = "main.screen"
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
    .coreServices()
}
