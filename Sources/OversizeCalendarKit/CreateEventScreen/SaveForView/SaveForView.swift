//
// Copyright © 2023 Alexander Romanov
// SaveForView.swift
//

#if canImport(EventKit)
import EventKit
#endif
import OversizeUI
import SwiftUI

#if !os(tvOS)
public struct SaveForView: View {
    @Environment(\.dismiss) var dismiss
    @Binding private var span: EKSpan?

    public init(selection: Binding<EKSpan?>) {
        _span = selection
    }

    public var body: some View {
        NavigationStack {
            LayoutView("This is repeating event") {
                SectionView {
                    VStack(spacing: .zero) {
                        Row("Save for this event only") {
                            span = .thisEvent
                            dismiss()
                        } leading: {
                            Image.Base.calendar
                                .renderingMode(.template)
                                .foregroundStyle(Color.onSurfacePrimary)
                        }

                        Row("Save for feature events") {
                            span = .futureEvents
                            dismiss()
                        } leading: {
                            Image.Base.calendar
                                .renderingMode(.template)
                                .foregroundStyle(Color.onSurfacePrimary)
                        }
                    }
                }
                .surfaceContentRowMargins()
            } background: {
                Color.backgroundSecondary
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                    #if !os(tvOS)
                        .keyboardShortcut(.cancelAction)
                    #endif
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}
#endif
