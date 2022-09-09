//
// Copyright © 2022 Alexander Romanov
// OnboardingItemPreferenceKey.swift
//

import SwiftUI

struct OnboardingItemPreferenceKey: PreferenceKey {
    static var defaultValue: [OnboardingItem] = []

    static func reduce(value: inout [OnboardingItem], nextValue: () -> [OnboardingItem]) {
        value += nextValue()
    }
}
