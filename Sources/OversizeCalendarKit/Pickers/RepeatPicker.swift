//
// Copyright © 2023 Alexander Romanov
// RepeatPicker.swift
//

#if canImport(EventKit)
import EventKit
#endif
import OversizeCalendarService
import OversizeUI
import SwiftUI

#if !os(tvOS)
public struct RepeatPicker: View {
    @Environment(\.dismiss) private var dismiss

    @Binding private var selectionRule: CalendarEventRecurrenceRules
    @Binding private var selectionEndRule: CalendarEventEndRecurrenceRules

    @State private var rule: CalendarEventRecurrenceRules
    @State private var endRule: CalendarEventEndRecurrenceRules

    @State private var endDate: Date = .init()
    @State private var repeatCount: String = "1"
    @FocusState private var isFocusedRepitCount: Bool

    public init(selectionRule: Binding<CalendarEventRecurrenceRules>, selectionEndRule: Binding<CalendarEventEndRecurrenceRules>) {
        _selectionRule = selectionRule
        _selectionEndRule = selectionEndRule
        _rule = State(wrappedValue: selectionRule.wrappedValue)
        _endRule = State(wrappedValue: selectionEndRule.wrappedValue)
    }

    public var body: some View {
        ScrollViewReader { scrollView in
            LayoutView("Repeat") {
                LeadingVStack {
                    SectionView {
                        VStack(spacing: .zero) {
                            ForEach(CalendarEventRecurrenceRules.allCases) { rule in
                                Radio(isOn: self.rule.id == rule.id) {
                                    // withAnimation {
                                    self.rule = rule
                                    // }
                                } label: {
                                    Row(rule.title)
                                }
                            }
                        }
                    }

                    if rule != .never {
                        SectionView("End Repeat") {
                            VStack(spacing: .zero) {
                                ForEach(CalendarEventEndRecurrenceRules.allCases) { rule in
                                    VStack(spacing: .xxSmall) {
                                        Radio(isOn: endRule.id == rule.id) {
                                            endRule = rule
                                            if case .occurrenceCount = endRule {
                                                isFocusedRepitCount = true
                                                scrollView.scrollTo(rule.id)
                                            }

                                            if case .endDate = endRule {
                                                isFocusedRepitCount = true
                                                scrollView.scrollTo(rule.id)
                                            }
                                        } label: {
                                            Row(rule.title)
                                        }

                                        if endRule.id == rule.id {
                                            repartPicker(rules: rule)
                                                .padding(.horizontal, .medium)
                                                .padding(.bottom, .small)
                                        }
                                    }
                                }
                            }
                        }
                        .transition(.move(edge: .top))
                    }
                }
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
                        selectionRule = rule
                        selectionEndRule = endRule
                        dismiss()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarPrimary)
                    .disabled(rule == .never)
                    #if !os(tvOS) && !os(watchOS)
                        .keyboardShortcut(.defaultAction)
                    #endif
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .surfaceContentRowMargins()
        }
        .presentationDetents(rule == .never ? [.height(630), .large] : [.large])
        .presentationDragIndicator(.hidden)
        .animation(.default, value: rule)
    }

    @ViewBuilder
    func repartPicker(rules: CalendarEventEndRecurrenceRules) -> some View {
        switch rules {
        case .never:
            EmptyView()
        case .occurrenceCount:
            TextField("Number of repetitions", text: Binding(get: {
                repeatCount
            }, set: { newValue in
                repeatCount = newValue
                endRule = .occurrenceCount(Int(newValue) ?? 1)
            }))
            #if os(iOS)
            .keyboardType(.numberPad)
            #endif
            .textFieldStyle(.default)
            .focused($isFocusedRepitCount)
        case .endDate:
            #if !os(watchOS)
            DatePicker("Date", selection: Binding(get: {
                endDate
            }, set: { newDate in
                endDate = newDate
                endRule = .endDate(newDate)
            }))
            #if os(iOS)
            .datePickerStyle(.wheel)
            #endif
            .labelsHidden()
            #else
            ProgressView()
            #endif
        }
    }
}
#endif
