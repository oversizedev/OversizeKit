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
            return true
        default:
            return false
        }
    }

    var result: Result? {
        switch self {
        case let .result(result):
            return result
        default:
            return nil
        }
    }

    static func == (lhs: LoadingViewState<Result>, rhs: LoadingViewState<Result>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.result, .result):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
