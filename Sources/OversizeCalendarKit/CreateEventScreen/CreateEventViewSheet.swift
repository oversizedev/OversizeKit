//
// Copyright © 2023 Alexander Romanov
// CreateEventViewSheet.swift
//

import EventKit
import OversizeComponents
import OversizeContactsKit
import OversizeLocationKit
import OversizeUI
import SwiftUI

public extension CreateEventViewModel {
    func present(_ sheet: CreateEventViewModel.Sheet) {
        self.sheet = sheet
    }

    func close() {
        sheet = nil
    }
}

public extension CreateEventViewModel {
    enum Sheet {
        case startTime
        case endTime
        case attachment
        case calendar
        case location
        case `repeat`
        case alarm
        case invites
        case span
    } // attachment, alert, invitees
}

extension CreateEventViewModel.Sheet: Identifiable {
    public var id: String {
        switch self {
        case .startTime:
            return "startTime"
        case .endTime:
            return "endTime"
        case .attachment:
            return "attachment"
        case .calendar:
            return "calendar"
        case .location:
            return "location"
        case .repeat:
            return "repeat"
        case .alarm:
            return "alarm"
        case .invites:
            return "alarm"
        case .span:
            return "span"
        }
    }
}

public extension CreateEventView {
    func resolveSheet(sheet: CreateEventViewModel.Sheet) -> some View {
        Group {
            switch sheet {
            case .startTime:
                #if os(iOS)
                    DatePickerSheet(title: "Starts time", selection: $viewModel.dateStart)
                        .onDisappear {
                            if viewModel.dateStart > viewModel.dateEnd {
                                viewModel.dateEnd = viewModel.dateStart.halfHour
                            }
                        }
                        .presentationDetents([.height(500)])
                #else
                    EmptyView()
                #endif
            case .endTime:
                #if os(iOS)
                    DatePickerSheet(title: "Ends time", selection: $viewModel.dateEnd)
                        .datePickerMinimumDate(viewModel.dateStart.minute)
                        .presentationDetents([.height(500)])
                #else
                    EmptyView()
                #endif
            case .attachment:
                AttachmentView()
                    .presentationDetents([.height(270)])
            case .calendar:
                CalendarPicker(selection: $viewModel.calendar, calendars: viewModel.calendars, sourses: viewModel.sourses)
                    .presentationDetents([.large])
            case .location:
                AddressPicker(address: $viewModel.locationName, location: $viewModel.location)
                    .interactiveDismissDisabled(true)
                    .presentationDetents([.large])
            case .repeat:
                RepeatPicker(selectionRule: $viewModel.repitRule, selectionEndRule: $viewModel.repitEndRule)

            case .alarm:
                AlarmPicker(selection: $viewModel.alarms)
                    .presentationDetents([.height(630), .large])
                    .presentationDragIndicator(.hidden)
            case .invites:
                EmailPickerView(selection: $viewModel.members)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled(true)
            case .span:
                SaveForView(selection: $viewModel.span)
                    .presentationDetents([.height(270)])
            }
        }
        .systemServices()
    }
}
