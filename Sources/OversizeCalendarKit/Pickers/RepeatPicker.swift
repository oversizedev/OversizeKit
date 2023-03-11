//
// Copyright © 2022 Alexander Romanov
// RepeatPicker.swift
//

import EventKit
import OversizeCalendarService
import OversizeUI
import SwiftUI

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
            PageView("Repeat") {
                SectionView {
                    VStack(spacing: .zero) {
                        ForEach(CalendarEventRecurrenceRules.allCases) { rule in
                            Radio(isOn: self.rule.id == rule.id) {
                                withAnimation {
                                    self.rule = rule
                                }
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
            .backgroundSecondary()
            .leadingBar {
                BarButton(.close)
            }
            .trailingBar {
                if rule == .never {
                    BarButton(.disabled("Done"))
                } else {
                    BarButton(.accent("Done", action: {
                        selectionRule = rule
                        selectionEndRule = endRule
                        dismiss()
                    }))
                }
            }
            .surfaceContentRowInsets()
        }
        .presentationDetents(rule == .never ? [.height(630), .large] : [.large])
        .presentationDragIndicator(.hidden)
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
            .keyboardType(.numberPad)
            .textFieldStyle(DefaultPlaceholderTextFieldStyle())
            .focused($isFocusedRepitCount)
        case .endDate:
            DatePicker("Date", selection: Binding(get: {
                endDate
            }, set: { newDate in
                endDate = newDate
                endRule = .endDate(newDate)
            }))
            .datePickerStyle(.wheel)
            .labelsHidden()
        }
    }
}

// struct RepeatPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        RepeatPicker()
//    }
// }
