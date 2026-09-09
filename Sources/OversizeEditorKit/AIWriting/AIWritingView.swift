// Copyright © 2026 Alexander Romanov
// AIWritingView.swift

import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
struct AIWritingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AIWritingViewModel()
    @State private var showDiscardConfirmation = false
    private let onInsert: (String) -> Void

    init(onInsert: @escaping (String) -> Void) {
        self.onInsert = onInsert
    }

    var body: some View {
        ListLayoutView("AI Writing") {
            // MARK: - Prompt

            ListSection {
                TextField("Describe what to write...", text: $viewModel.prompt, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .autocorrectionDisabled()
            }

            // MARK: - Result

            if let generatedText = viewModel.state.result {
                ListSection("Generated") {
                    Text(generatedText)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Error

            if let error = viewModel.state.error {
                ListSection {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .toolbarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(!viewModel.prompt.isEmpty)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", role: .cancel) {
                    if viewModel.prompt.isEmpty {
                        dismiss()
                    } else {
                        showDiscardConfirmation = true
                    }
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
                .confirmationDialog(
                    "Do you want to discard?",
                    isPresented: $showDiscardConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Discard Changes", role: .destructive) { dismiss() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("You have unsaved changes")
                }
            }
        }
        .safeAreaBarBottom {
            if !viewModel.prompt.isEmpty {
                HStack(spacing: .xSmall) {
                    if let generatedText = viewModel.state.result {
                        Button("Regenerate") {
                            Task { await viewModel.generate() }
                        }
                        .buttonStyle(.secondary)
                        .loading(viewModel.state == .loading)

                        Button("Insert") {
                            onInsert(generatedText)
                        }
                        .buttonStyle(.primary)
                        .accent()
                    } else {
                        Button("Generate") {
                            Task { await viewModel.generate() }
                        }
                        .buttonStyle(.primary)
                        .accent()
                        .loading(viewModel.state == .loading)
                    }
                }
                .paddingContent()
            }
        }
    }
}

// MARK: - Preview

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview {
    AIWritingView { _ in }
}
