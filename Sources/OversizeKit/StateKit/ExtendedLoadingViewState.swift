//
// Copyright © 2025 Alexander Romanov
// ExtendedLoadingViewState.swift, created on 01.02.2025
//

import Foundation
import OversizeModels

public enum ExtendedLoadingViewState<Result>: Equatable {
    case idle
    case loading
    case empty
    case result(Result)
    case error(AppError)
}

public extension ExtendedLoadingViewState {
    var isLoading: Bool {
        switch self {
        case .loading, .idle:
            true
        default:
            false
        }
    }

    var result: Result? {
        switch self {
        case .empty:
            nil
        case let .result(result):
            result
        default:
            nil
        }
    }

    var error: AppError? {
        switch self {
        case let .error(error):
            error
        default:
            nil
        }
    }

    static func == (lhs: ExtendedLoadingViewState<Result>, rhs: ExtendedLoadingViewState<Result>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            true
        case (.loading, .loading):
            true
        case (.result, .result):
            true
        case (.error, .error):
            true
        case (.empty, .empty):
            true
        default:
            false
        }
    }
}
