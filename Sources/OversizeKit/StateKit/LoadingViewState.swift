//
// Copyright © 2024 Alexander Romanov
// LoadingViewState.swift, created on 25.04.2024
//

import Foundation
import OversizeModels

public enum LoadingViewState<Result> {
    case loading
    case result(Result)
    case empty(String)
    case error(AppError)
}
