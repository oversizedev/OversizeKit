//
// Copyright © 2023 Alexander Romanov
// DebugInfoView.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeNavigation
import OversizeServices
import OversizeUI
import SwiftUI

public struct DebugInfoView: View {
    @StateObject private var viewModel = DebugInfoViewModel()

    public init() {}

    public var body: some View {
        NavigationPageView("Information") {
            contentView
        } background: {
            Color.backgroundSecondary
        }
        .toolbarTitleDisplayMode(.inline)
    }

    var contentView: some View {
        LeadingVStack {
            SectionView("App State") {
                Row(
                    "App Run Count",
                    subtitle: "\(viewModel.appStateService.appRunCount) runs"
                )
                Separator()
                Row(
                    "First Run Date",
                    subtitle: viewModel.appStateService.firstRunDate.formatted(date: .abbreviated, time: .standard)
                )
                Separator()
                Row("Last Run Date",
                    subtitle: viewModel.appStateService.lastRunDate.formatted(date: .abbreviated, time: .standard))
                Separator()
                Row(
                    "App last Run Version",
                    subtitle: viewModel.appStateService.lastRunVersion
                )
            }
            .sectionContentCompactRowMargins()
            .rowContentMargins(.init(horizontal: .medium, vertical: .xxxSmall))
            
            SectionView("Review") {
                Row(
                    "App Store review request count",
                    subtitle: "\(viewModel.reviewService.appStoreReviewRequestCount)"
                )
                Separator()
                Row(
                    "App Review banner closed date",
                    subtitle: viewModel.reviewService.appReviewBannerClosedDate.formatted(date: .abbreviated, time: .standard)
                )
                Separator()
                Row(
                    "App Review estimate date",
                    subtitle: viewModel.reviewService.appReviewEstimateDate.formatted(date: .abbreviated, time: .standard)
                )
            }
            .sectionContentCompactRowMargins()
            .rowContentMargins(.init(horizontal: .medium, vertical: .xxxSmall))
        }
    }
}

#Preview {
    DebugInfoView()
}
