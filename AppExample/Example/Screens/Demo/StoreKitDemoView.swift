//
// Copyright © 2026 Alexander Romanov
// StoreKitDemoView.swift, created on 19.09.2026
//

import OversizeKit
import OversizeUI
import SwiftUI

struct StoreKitDemoView: View {
    @State private var isShowStore = false
    @State private var isShowInstructions = false

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                SectionView("Banner") {
                    PremiumBannerRow()
                }

                SectionView("Screens") {
                    VStack(spacing: .zero) {
                        Row("Paywall") {
                            isShowStore = true
                        } leading: {
                            Image(systemName: "creditcard")
                        }
                        .navigatable()
                        .buttonStyle(.row)

                        Row("Trial instructions") {
                            isShowInstructions = true
                        } leading: {
                            Image(systemName: "list.number")
                        }
                        .navigatable()
                        .buttonStyle(.row)
                    }
                }
                .sectionContentCompactRowMargins()

                SectionView("Premium content") {
                    VStack(spacing: .zero) {
                        Row("Locked feature", subtitle: "Wrapped in premiumContent") {
                            Image(systemName: "lock")
                        }
                    }
                    .premiumContent("Premium feature", subtitle: "Subscribe to unlock this section")
                }
                .sectionContentCompactRowMargins()

                SectionView("Premium tap") {
                    Row("Opens the paywall on tap", subtitle: "Wrapped in onPremiumTap") {
                        Image(systemName: "hand.tap")
                    }
                    .onPremiumTap()
                }
                .sectionContentCompactRowMargins()
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Store")
        .sheet(isPresented: $isShowStore) {
            StoreView()
        }
        .sheet(isPresented: $isShowInstructions) {
            StoreInstructionsView()
        }
    }
}

#Preview {
    NavigationStack {
        StoreKitDemoView()
    }
    .appEnvironment()
}
