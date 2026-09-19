//
// Copyright © 2026 Alexander Romanov
// DebugKitDemoView.swift, created on 19.09.2026
//

import OversizeKit
import OversizeUI
import SwiftUI

struct DebugKitDemoView: View {
    @State private var isShowDebugMenu = false
    @State private var isShowDebugInfo = false

    var body: some View {
        ScrollView {
            SectionView("Screens") {
                VStack(spacing: .zero) {
                    Row("Debug menu") {
                        isShowDebugMenu = true
                    } leading: {
                        Image(systemName: "ladybug")
                    }
                    .navigatable()
                    .buttonStyle(.row)

                    Row("Information") {
                        isShowDebugInfo = true
                    } leading: {
                        Image(systemName: "info.circle")
                    }
                    .navigatable()
                    .buttonStyle(.row)
                }
            }
            .sectionContentCompactRowMargins()
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Debug")
        .sheet(isPresented: $isShowDebugMenu) {
            NavigationStack {
                DebugMenuView()
            }
        }
        .sheet(isPresented: $isShowDebugInfo) {
            NavigationStack {
                DebugInfoView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        DebugKitDemoView()
    }
    .appEnvironment()
}
