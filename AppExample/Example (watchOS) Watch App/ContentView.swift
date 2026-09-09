//
// Copyright © 2024 Alexander Romanov
// ContentView.swift, created on 19.05.2024
//

import FactoryKit
import OversizeKit
import OversizeOnboardingKit
import OversizeServices
import OversizeUI
import SwiftUI

struct ContentView: View {
    @Injected(\.appStateService) private var appStateService: AppStateService

    var body: some View {
        if appStateService.isCompletedOnboarding {
            VStack(spacing: .xxSmall) {
                Text("Example")
                    .headline(.bold)

                Text("OversizeKit on watchOS")
                    .caption()
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        } else {
            onboarding
        }
    }

    private var onboarding: some View {
        OnboardView {
            VStack(spacing: .xxSmall) {
                Text("Welcome")
                    .headline(.bold)

                Text("A working integration of OversizeKit")
                    .caption()
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        } actions: {
            Button("Continue") {
                appStateService.completedOnboarding()
            }
            .buttonStyle(.primary)
            .accent()
        }
    }
}

#Preview {
    ContentView()
}
