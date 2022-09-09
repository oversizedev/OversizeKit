//
// Copyright © 2022 Alexander Romanov
// OnboardingItem.swift
//

import SwiftUI

public struct OnboardingItem: Identifiable, Equatable {
    public var id = UUID()
    public var image: Image?
    public var title: String?
    public var subtitle: String?

    public init(id: UUID = UUID(), image: Image? = nil, title: String? = nil, subtitle: String? = nil) {
        self.id = id
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }
}
