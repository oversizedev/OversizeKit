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
        NavigationLayoutView("Information") {
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
                    "App launches for review",
                    subtitle: "Current: \(viewModel.appStateService.appRunCount), next request after \(viewModel.nextLaunchReviewCount) launches"
                )
                Separator()
                Row(
                    "Events to show review request count",
                    subtitle: "Current: \(viewModel.eventCount), next request after \(viewModel.nextEventReviewCount) events",
                    action: viewModel.onTapAddEvent
                )
                Separator()
                Row(
                    "App Review banner closed date",
                    subtitle: viewModel.reviewBannerClosedDate.formatted(date: .abbreviated, time: .standard)
                )
                Separator()
                Row(
                    "App Review estimate date",
                    subtitle: viewModel.reviewEstimateDate.formatted(date: .abbreviated, time: .standard)
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
