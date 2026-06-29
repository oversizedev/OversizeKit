//
// Copyright © 2024 Alexander Romanov
// RepeatingButton.swift, created on 23.05.2026
//

import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public struct RepeatingButton<Label: View>: View {
    private let action: () -> Void
    private let label: () -> Label

    @State private var repeatTask: Task<Void, Never>?
    @State private var isInRepeatMode = false
    @GestureState private var isHolding = false

    public init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    private var holdGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.45)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .updating($isHolding) { value, state, _ in
                if case .second(true, _) = value { state = true }
            }
            .onEnded { _ in cancelRepeat() }
    }

    public var body: some View {
        Button {
            guard !isInRepeatMode else {
                isInRepeatMode = false
                return
            }
            action()
        } label: {
            label()
        }
        .simultaneousGesture(holdGesture)
        .onChange(of: isHolding) { _, pressing in
            if pressing {
                isInRepeatMode = true
                action()
                startRepeatTask()
            } else {
                isInRepeatMode = false
                cancelRepeat()
            }
        }
        .onDisappear { cancelRepeat() }
    }

    private func startRepeatTask() {
        guard repeatTask == nil else { return }
        repeatTask = Task {
            var interval: UInt64 = 250
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .milliseconds(interval))
                } catch {
                    return
                }
                action()
                interval = max(50, UInt64(Double(interval) * 0.75))
            }
        }
    }

    private func cancelRepeat() {
        repeatTask?.cancel()
        repeatTask = nil
    }
}
