// Copyright © 2026 Alexander Romanov
// AIWritingViewModel.swift

import FactoryKit
import Observation
import OversizeCore
import OversizeIntelligenceService

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
@MainActor
@Observable
final class AIWritingViewModel {
    @ObservationIgnored
    @Injected(\.intelligenceService) private var service: IntelligenceService

    var prompt: String = ""
    var state: LoadingState<String> = .idle

    var canGenerate: Bool {
        !prompt.isEmpty && state != .loading
    }

    func generate() async {
        guard canGenerate else { return }
        state = .loading
        do {
            let result = try await service.generate(prompt)
            state = .result(result)
        } catch {
            state = .error(error)
        }
    }
}
