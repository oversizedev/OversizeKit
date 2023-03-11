//
// Copyright © 2022 Alexander Romanov
// AlertPicker.swift
//

import EventKit
import OversizeCalendarService
import OversizeUI
import SwiftUI

public struct AlarmPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding private var selection: [CalendarAlertsTimes]
    @State private var selectedAlerts: [CalendarAlertsTimes] = []

    public init(selection: Binding<[CalendarAlertsTimes]>) {
        _selection = selection
        _selectedAlerts = State(wrappedValue: selection.wrappedValue)
    }

    public var body: some View {
        PageView("Alarm") {
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
            .surfaceContentRowInsets()
        }
        .backgroundSecondary()
        .leadingBar {
            BarButton(.close)
        }
        .trailingBar {
            BarButton(.accent("Done", action: {
                selection = selectedAlerts
                dismiss()
            }))
            .disabled(selectedAlerts.isEmpty)
        }
    }
}

// struct AlertPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        AlertPicker()
//    }
// }
