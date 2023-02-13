//
// Copyright © 2022 Alexander Romanov
// CalendarPicker.swift
//

import EventKit
import OversizeUI
import SwiftUI

public struct CalendarPicker: View {
    @Environment(\.dismiss) var dismiss

    @Binding private var selection: EKCalendar?

    private let calendars: [EKCalendar]

    private let sourses: [EKSource]

    private let closable: Bool

    public init(selection: Binding<EKCalendar?>, calendars: [EKCalendar], sourses: [EKSource], closable: Bool = true) {
        _selection = selection
        self.calendars = calendars
        self.sourses = sourses
        self.closable = closable
    }

    public var body: some View {
        PageView("Calendar") {
            ForEach(sourses, id: \.sourceIdentifier) { source in
                let filtredCalendar: [EKCalendar] = calendars.filter { $0.source.sourceIdentifier == source.sourceIdentifier && $0.allowsContentModifications }
                if !filtredCalendar.isEmpty {
                    calendarSection(source: source, calendars: filtredCalendar)
                }
            }
        }
        .backgroundSecondary()
        .leadingBar {
            BarButton(closable ? .close : .back)
        }
    }

    func calendarSection(source: EKSource, calendars: [EKCalendar]) -> some View {
        SectionView(source.title) {
            VStack(spacing: .zero) {
                ForEach(calendars, id: \.calendarIdentifier) { calendar in
                    Row(calendar.title) {
                        selection = calendar
                        dismiss()
                    }
                    .rowLeading(.view(AnyView(
                        Circle()
                            .fill(Color(calendar.cgColor))
                            .frame(width: 16, height: 16)
                    )))
                    .rowTrailing(.radio(isOn: .constant(selection?.calendarIdentifier == calendar.calendarIdentifier)))
                }
            }
        }
    }
}

struct CalendarPicker_Previews: PreviewProvider {
    static var previews: some View {
        CalendarPicker(selection: .constant(nil), calendars: [], sourses: [])
    }
}
