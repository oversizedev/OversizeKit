//
// Copyright © 2022 Alexander Romanov
// OnboardingItemViewModifier.swift
//

import SwiftUI

struct OnboardingItemViewModifier: ViewModifier {
    let onboardingItem: OnboardingItem

    func body(content: Content) -> some View {
        content
            .preference(key: OnboardingItemPreferenceKey.self, value: [onboardingItem])
    }
}

public extension View {
    func onboardingItem(_ label: () -> OnboardingItem) -> some View {
        modifier(OnboardingItemViewModifier(onboardingItem: label()))
    }
}
