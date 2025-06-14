//
// Copyright © 2023 Alexander Romanov
// CreateEventViewModel.swift
//

#if canImport(EventKit)
@preconcurrency import EventKit
#endif
import FactoryKit
import OversizeCalendarService
import OversizeCore
import OversizeLocationService
import OversizeModels
import SwiftUI

#if !os(tvOS)
public enum CreateEventType: Equatable, @unchecked Sendable {
    case new(Date?, calendar: EKCalendar?)
    case update(EKEvent)
}

public class CreateEventViewModel: ObservableObject, @unchecked Sendable {
    @Injected(\.calendarService) private var calendarService: CalendarService
    @Injected(\.locationService) private var locationService: LocationServiceProtocol

    @Published var state = CreateEventViewModelState.initial
    @Published var sheet: CreateEventViewModel.Sheet? = nil
    @Published var isFetchUpdatePositon: Bool = .init(false)

    @Published var title: String = .init()
    @Published var note: String = .init()
    @Published var url: String = .init()
    @Published var dateStart: Date = .init()
    @Published var dateEnd: Date = .init().halfHour
    @Published var isAllDay: Bool = .init(false)
    @Published var calendar: EKCalendar?
    @Published var calendars: [EKCalendar] = .init()
    @Published var sourses: [EKSource] = .init()
    @Published var locationName: String?
    @Published var location: CLLocationCoordinate2D?
    @Published var repitRule: CalendarEventRecurrenceRules = .never
    @Published var repitEndRule: CalendarEventEndRecurrenceRules = .never
    @Published var alarms: [CalendarAlertsTimes] = .init()
    @Published var members: [String] = .init()
    @Published var span: EKSpan?

    let type: CreateEventType

    var isLocationSelected: Bool {
        location != nil
    }

    public init(_ type: CreateEventType) {
        self.type = type
        setEvent(type: type)
    }

    func setEvent(type: CreateEventType) {
        switch type {
        case let .new(date, calendar):
            if let date {
                dateStart = date
                dateEnd = date.halfHour
            }
            if let calendar {
                self.calendar = calendar
            }
        case let .update(event):
            title = event.title
            note = event.notes ?? ""
            url = event.url?.absoluteString ?? ""
            dateStart = event.startDate
            dateEnd = event.endDate
            isAllDay = event.isAllDay
            calendar = event.calendar
            locationName = event.location
            if let coordinate = event.structuredLocation?.geoLocation?.coordinate {
                location = coordinate
            }
            if let rule = event.recurrenceRules?.first {
                repitRule = rule.calendarRecurrenceRule
                repitEndRule = rule.recurrenceEnd?.calendarEndRecurrenceRule ?? .never
            }
            if let eventAlarms = event.alarms {
                alarms = eventAlarms.compactMap { $0.calendarAlert }
            }
            if let attendees = event.attendees {
                members = attendees.compactMap { $0.url.absoluteString }
            }
        }
    }

    func fetchData() async {
        state = .loading
        async let calendarsResult = await calendarService.fetchCalendars()
        switch await calendarsResult {
        case let .success(data):
            log("✅ EKCalendars fetched")
            calendars = data
        case let .failure(error):
            log("❌ EKCalendars not fetched (\(error.title))")
            state = .error(error)
        }
        async let soursesResult = await calendarService.fetchSourses()
        switch await soursesResult {
        case let .success(data):
            log("✅ EKSource fetched")
            sourses = data
        case let .failure(error):
            log("❌ EKSource not fetched (\(error.title))")
            state = .error(error)
        }
        if case let .new(_, calendar) = type, calendar == nil {
            let result = await calendarService.fetchDefaultCalendar()
            switch result {
            case let .success(calendar):
                self.calendar = calendar
            case let .failure(error):
                log("❌ Default calendar not fetched (\(error.title))")
            }
        }
    }

    func save() async -> Result<Bool, AppError> {
        var oldEvent: EKEvent?

        if case let .update(event) = type {
            oldEvent = event
        }

        let result = await calendarService.createEvent(
            event: oldEvent,
            title: title,
            notes: note,
            startDate: dateStart,
            endDate: dateEnd,
            calendar: calendar,
            isAllDay: isAllDay,
            location: locationName,
            structuredLocation: getEKStructuredLocation(),
            alarms: alarms,
            url: URL(string: url),
            memberEmails: members,
            recurrenceRules: repitRule,
            recurrenceEndRules: repitEndRule,
            span: span ?? .thisEvent
        )
        switch result {
        case let .success(data):
            log("✅ EKEvent saved")
            return .success(data)
        case let .failure(error):
            log("❌ EKEvent not saved (\(error.title))")
            return .failure(error)
        }
    }

    func getEKStructuredLocation() -> EKStructuredLocation? {
        if let location {
            let structuredLocation: EKStructuredLocation?
            let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
            structuredLocation = EKStructuredLocation(title: locationName ?? "") // same title with ekEvent.location
            structuredLocation?.geoLocation = location
            return structuredLocation
        } else {
            return nil
        }
    }

    func updateCurrentPosition() async throws {
        isFetchUpdatePositon = true
        let currentPosition = try await locationService.currentLocation()
        guard let newLocation = currentPosition else { return }
        location = newLocation
        log("📍 Location: \(newLocation.latitude), \(newLocation.longitude)")
        isFetchUpdatePositon = false
    }
}

public enum CreateEventViewModelState {
    case initial
    case loading
    case result([EKEvent])
    case error(AppError)
}
#endif
