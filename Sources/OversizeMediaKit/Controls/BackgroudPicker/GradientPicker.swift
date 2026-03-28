//
// Copyright © 2026 Alexander Romanov
// GradientPicker.swift
//

import OversizeUI
import SwiftUI

#if os(iOS)
@available(iOS 17.0, *)
public struct GradientPicker: View {
    @Environment(\.dismiss) var dismiss

    @Binding public var startColor: Color
    @Binding public var endColor: Color
    @Binding public var direction: GradientDirection

    public init(
        startColor: Binding<Color>,
        endColor: Binding<Color>,
        direction: Binding<GradientDirection>
    ) {
        _startColor = startColor
        _endColor = endColor
        _direction = direction
    }

    public var body: some View {
        ListLayoutView("Custom Gradient") {
            ListSection {
                gradientPreview
                    .listRowInsets(EdgeInsets())
            }

            ListSection("Start Color") {
                ColorSelector(selection: $startColor)
                    .listRowInsets(.init(.zero))
            }

            ListSection("End Color") {
                ColorSelector(selection: $endColor)
                    .listRowInsets(.init(.zero))
            }

            ListSection("Direction") {
                Picker("Direction", selection: $direction) {
                    Label {
                        Text(GradientDirection.topBottom.title)
                    } icon: {
                        gradientCircle(for: .topBottom)
                    }
                    .tag(GradientDirection.topBottom)

                    Label {
                        Text(GradientDirection.leadingTrailing.title)
                    } icon: {
                        gradientCircle(for: .leadingTrailing)
                    }
                    .tag(GradientDirection.leadingTrailing)

                    Label {
                        Text(GradientDirection.topLeadingBottomTrailing.title)
                    } icon: {
                        gradientCircle(for: .topLeadingBottomTrailing)
                    }
                    .tag(GradientDirection.topLeadingBottomTrailing)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        } background: {
            LinearGradient(
                colors: [
                    Color.backgroundPrimary,
                    Color.backgroundSecondary,
                    Color.backgroundSecondary,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .listLayoutStyle(.insetGrouped)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) { dismiss() }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
            }
        }
    }

    private func gradientCircle(for dir: GradientDirection) -> some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [startColor, endColor],
                    startPoint: dir.startPoint,
                    endPoint: dir.endPoint
                )
            )
    }

    private var gradientPreview: some View {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: direction.startPoint,
            endPoint: direction.endPoint
        )
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var start: Color = .blue
    @Previewable @State var end: Color = .purple
    @Previewable @State var direction: GradientDirection = .topBottom
    NavigationStack {
        GradientPicker(startColor: $start, endColor: $end, direction: $direction)
    }
}
#endif
