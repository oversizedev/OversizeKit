//
// Copyright © 2026 Alexander Romanov
// BackgroundPickerResult.swift
//

import SwiftUI

#if os(iOS)
public enum BackgroundPickerResult: @unchecked Sendable {
    case image(UIImage)
    case color(Color)
    case gradient(startColor: Color, endColor: Color, direction: GradientDirection)
}

extension BackgroundPickerResult: Equatable {
    public static func == (lhs: BackgroundPickerResult, rhs: BackgroundPickerResult) -> Bool {
        switch (lhs, rhs) {
        case let (.image(l), .image(r)): l === r
        case let (.color(l), .color(r)): l == r
        case let (.gradient(ls, le, ld), .gradient(rs, re, rd)): ls == rs && le == re && ld == rd
        default: false
        }
    }
}
#endif
