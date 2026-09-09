//
// Copyright © 2023 Alexander Romanov
// CalendarPicker.swift
//

#if canImport(EventKit)
import EventKit
#endif
import OversizeUI
import SwiftUI

#if !os(tvOS)
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
        LayoutView("Calendar") {
            LeadingVStack {
                ForEach(sourses, id: \.sourceIdentifier) { source in
                    let filtredCalendar: [EKCalendar] = calendars.filter { $0.source.sourceIdentifier == source.sourceIdentifier && $0.allowsContentModifications }
                    if !filtredCalendar.isEmpty {
                        calendarSection(source: source, calendars: filtredCalendar)
                    }
                }
            }
        } background: {
            Color.backgroundSecondary
        }
        .toolbar {
            if closable {
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
            } else {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back", systemImage: "chevron.left") {
                        dismiss()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", systemImage: "chevron.left") {
                        dismiss()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                }
                #endif
            }
        }
        .toolbarTitleDisplayMode(.inline)
    }

    func calendarSection(source: EKSource, calendars: [EKCalendar]) -> some View {
        SectionView(source.title) {
            VStack(spacing: .zero) {
                ForEach(calendars, id: \.calendarIdentifier) { calendar in
                    Radio(isOn: selection?.calendarIdentifier == calendar.calendarIdentifier) {
                        selection = calendar
                        dismiss()
                    } label: {
                        Row(calendar.title) {
                            Circle()
                                .fill(Color(calendar.cgColor))
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
        }
        .surfaceContentRowMargins()
    }
}

#Preview {
    CalendarPicker(selection: .constant(nil), calendars: [], sourses: [])
}
#endif
