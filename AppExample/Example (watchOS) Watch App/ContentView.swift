//
// Copyright © 2024 Alexander Romanov
// ContentView.swift, created on 19.05.2024
//

import OversizeKit
import OversizeOnboardingKit
import OversizeUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        OnboardView {
            VStack(spacing: .xxSmall) {
                Text("Example")
                    .headline(.bold)

                Text("OversizeKit on watchOS")
                    .caption()
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        } actions: {
            Button("Continue") {}
                .buttonStyle(.primary)
                .accent()
        }
    }
}

#Preview {
    ContentView()
}
