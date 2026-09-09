//
// Copyright © 2023 Alexander Romanov
// OnboardingView.swift, created on 25.09.2023
//

import FactoryKit
import OversizeOnboardingKit
import OversizeServices
import OversizeUI
import SwiftUI

struct OnboardingView: View {
    @Injected(\.appStateService) private var appStateService: AppStateService

    var body: some View {
        OnboardView {
            content
        } actions: {
            Button("Continue") {
                appStateService.completedOnboarding()
            }
            .buttonStyle(.primary)
            .accent()
            .accessibilityIdentifier(AccessibilityIdentifier.continueButton)
        }
    }

    private var content: some View {
        VStack(spacing: .large) {
            Spacer()

            Image("OnbardingBackground", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(spacing: .small) {
                Text("Welcome to\nExample")
                    .largeTitle()
                    .accessibilityIdentifier(AccessibilityIdentifier.title)

                Text("A working integration of OversizeKit")
                    .title2(.semibold)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            Spacer()
        }
        .paddingContent(.horizontal)
    }
}

extension OnboardingView {
    enum AccessibilityIdentifier {
        static let title = "onboarding.title"
        static let continueButton = "onboarding.continue"
    }
}

#Preview {
    OnboardingView()
        .coreServices()
}
