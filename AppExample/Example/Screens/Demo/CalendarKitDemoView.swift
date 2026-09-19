//
// Copyright © 2026 Alexander Romanov
// CalendarKitDemoView.swift, created on 19.09.2026
//

import EventKit
import OversizeCalendarKit
import OversizeCalendarService
import OversizeUI
import SwiftUI

struct CalendarKitDemoView: View {
    @State private var isShowCreateEvent = false
    @State private var isShowCalendarPicker = false
    @State private var isShowRepeatPicker = false
    @State private var isShowAlarmPicker = false

    @State private var calendar: EKCalendar?
    @State private var calendars: [EKCalendar] = []
    @State private var sources: [EKSource] = []
    @State private var repeatRule: CalendarEventRecurrenceRules = .never
    @State private var repeatEndRule: CalendarEventEndRecurrenceRules = .never
    @State private var alarms: [CalendarAlertsTimes] = []

    private let eventStore = EKEventStore()

    var body: some View {
        ScrollView {
            SectionView("Screens") {
                VStack(spacing: .zero) {
                    Row("Create event") {
                        isShowCreateEvent = true
                    } leading: {
                        Image(systemName: "calendar.badge.plus")
                    }
                    .navigatable()
                    .buttonStyle(.row)

                    Row("Calendar", subtitle: calendar?.title) {
                        isShowCalendarPicker = true
                    } leading: {
                        Image(systemName: "calendar")
                    }
                    .navigatable()
                    .buttonStyle(.row)

                    Row("Repeat", subtitle: repeatRule.title) {
                        isShowRepeatPicker = true
                    } leading: {
                        Image(systemName: "repeat")
                    }
                    .navigatable()
                    .buttonStyle(.row)

                    Row("Alarm", subtitle: alarms.first?.title) {
                        isShowAlarmPicker = true
                    } leading: {
                        Image(systemName: "bell")
                    }
                    .navigatable()
                    .buttonStyle(.row)
                }
            }
            .sectionContentCompactRowMargins()
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Calendar")
        .task {
            await loadCalendars()
        }
        .sheet(isPresented: $isShowCreateEvent) {
            NavigationStack {
                CreateEventView()
            }
        }
        .sheet(isPresented: $isShowCalendarPicker) {
            NavigationStack {
                CalendarPicker(selection: $calendar, calendars: calendars, sourses: sources)
            }
        }
        .sheet(isPresented: $isShowRepeatPicker) {
            NavigationStack {
                RepeatPicker(selectionRule: $repeatRule, selectionEndRule: $repeatEndRule)
            }
        }
        .sheet(isPresented: $isShowAlarmPicker) {
            NavigationStack {
                AlarmPicker(selection: $alarms)
            }
        }
    }

    private func loadCalendars() async {
        guard (try? await eventStore.requestFullAccessToEvents()) == true else { return }
        calendars = eventStore.calendars(for: .event)
        sources = eventStore.sources
    }
}

#Preview {
    NavigationStack {
        CalendarKitDemoView()
    }
    .appEnvironment()
}
