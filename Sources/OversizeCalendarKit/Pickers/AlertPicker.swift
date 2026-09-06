//
// Copyright © 2023 Alexander Romanov
// AlertPicker.swift
//

#if canImport(EventKit)
import EventKit
#endif
import OversizeCalendarService
import OversizeUI
import SwiftUI

#if !os(tvOS)
public struct AlarmPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding private var selection: [CalendarAlertsTimes]
    @State private var selectedAlerts: [CalendarAlertsTimes] = []

    public init(selection: Binding<[CalendarAlertsTimes]>) {
        _selection = selection
        _selectedAlerts = State(wrappedValue: selection.wrappedValue)
    }

    public var body: some View {
        LayoutView("Alarm") {
            SectionView {
                VStack(spacing: .zero) {
                    ForEach(CalendarAlertsTimes.allCases) { alert in
                        Checkbox(alert.title, isOn: .constant((selectedAlerts.first { $0.id == alert.id } != nil) ? true : false)) {
                            if !selectedAlerts.isEmpty, let _ = selectedAlerts.first(where: { $0.id == alert.id }) {
                                selectedAlerts.remove(alert)
                            } else {
                                selectedAlerts.append(alert)
                            }
                        }
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
                #if !os(tvOS) && !os(watchOS)
                .keyboardShortcut(.cancelAction)
                #endif
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Done", systemImage: "checkmark") {
                    selection = selectedAlerts
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarPrimary)
                .disabled(selectedAlerts.isEmpty)
                #if !os(tvOS) && !os(watchOS)
                .keyboardShortcut(.defaultAction)
                #endif
            }
        }
        .toolbarTitleDisplayMode(.inline)
    }
}
#endif
