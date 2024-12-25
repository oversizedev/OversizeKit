//
// Copyright © 2024 Alexander Romanov
// LoadingViewState.swift, created on 25.04.2024
//

import Foundation
import OversizeModels

public enum LoadingViewState<Result>: Equatable {
    case idle
    case loading
    case result(Result)
    case error(AppError)
}

public extension LoadingViewState {
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

    static func == (lhs: LoadingViewState<Result>, rhs: LoadingViewState<Result>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            true
        case (.loading, .loading):
            true
        case (.result, .result):
            true
        case (.error, .error):
            true
        default:
            false
        }
    }
}
