//
// Copyright © 2024 Alexander Romanov
// File.swift, created on 27.11.2024
//

import Foundation
import OversizeModels

public extension Result {
    var failureError: Failure? {
        switch self {
        case let .failure(error): error
        case .success: nil
        }
    }

    var successResult: Success? {
        switch self {
        case .failure: nil
        case let .success(value): value
        }
    }
}

public extension Result {
    var isFailure: Bool { !isSuccess }

    var isSuccess: Bool {
        switch self {
        case .failure: false
        case .success: true
        }
    }
}
