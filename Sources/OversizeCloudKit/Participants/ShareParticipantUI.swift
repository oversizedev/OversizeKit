// Copyright © 2026 Alexander Romanov
// ShareParticipantUI.swift

import OversizeCloudService
import OversizeUI
import SwiftUI

extension ShareParticipant {
    var badgeColor: Color {
        switch badgeColorRole {
        case .warning: Color.warning
        case .error: Color.error
        case .accent: Color.accent
        case .secondary: Color.onSurfaceSecondary
        }
    }
}
