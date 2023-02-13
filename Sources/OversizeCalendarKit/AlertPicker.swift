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
                        Row(alert.title) {
                            if !selectedAlerts.isEmpty, let _ = selectedAlerts.first(where: { $0.id == alert.id }) {
                                selectedAlerts.remove(alert)
                            } else {
                                selectedAlerts.append(alert)
                            }
                        }
                        .rowTrailing(.checkbox(isOn: .constant((selectedAlerts.first { $0.id == alert.id } != nil) ? true : false)))
                    }
                }
            }
        }
        .backgroundSecondary()
        .leadingBar {
            BarButton(.close)
        }
        .trailingBar {
            if selectedAlerts.isEmpty {
                BarButton(.disabled("Done"))
            } else {
                BarButton(.accent("Done", action: {
                    selection = selectedAlerts
                    dismiss()
                }))
            }
        }
    }
}

// struct AlertPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        AlertPicker()
//    }
// }
