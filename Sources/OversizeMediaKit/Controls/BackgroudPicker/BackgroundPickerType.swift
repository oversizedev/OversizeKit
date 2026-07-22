//
// Copyright © 2026 Alexander Romanov
// BackgroundPickerType.swift
//

import SwiftUI

#if os(iOS)
public enum BackgroundPickerType: @unchecked Sendable {
    case image(UIImage)
    case color(Color)
    case gradient(startColor: Color, endColor: Color, direction: GradientDirection)
}

extension BackgroundPickerType: Equatable {
    public static func == (lhs: BackgroundPickerType, rhs: BackgroundPickerType) -> Bool {
        switch (lhs, rhs) {
        case let (.image(l), .image(r)): l === r
        case let (.color(l), .color(r)): l == r
        case let (.gradient(ls, le, ld), .gradient(rs, re, rd)): ls == rs && le == re && ld == rd
        default: false
        }
    }
}
#endif
