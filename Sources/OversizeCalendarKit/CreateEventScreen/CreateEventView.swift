//
// Copyright © 2023 Alexander Romanov
// CreateEventView.swift
//

import EventKit
import MapKit
import OversizeCalendarService
import OversizeComponents
import OversizeCore
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeUI
import SwiftUI

public struct CreateEventView: View {
    @StateObject var viewModel: CreateEventViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: FocusField?

    public init(_ type: CreateEventType = .new(nil, calendar: nil)) {
        _viewModel = StateObject(wrappedValue: CreateEventViewModel(type))
    }

    public var body: some View {
        PageView {
            content()
        }
        .leadingBar {
            BarButton(.closeAction {
                dismiss()
            })
        }
        .trailingBar {
            if viewModel.title.isEmpty {
                BarButton(.disabled(L10n.Button.save))
            } else {
                BarButton(.accent(L10n.Button.save, action: {
                    switch viewModel.type {
                    case .new:
                        Task {
                            _ = await viewModel.save()
                            dismiss()
                        }
                    case .update:
                        if viewModel.span == nil, viewModel.repitRule != .never {
                            viewModel.present(.span)
                        } else {
                            Task {
                                _ = await viewModel.save()
                                dismiss()
                            }
                        }
                    }
                }))
            }
        }
        .titleLabel {
            Button { viewModel.present(.calendar) } label: {
                HStack(spacing: .xxxSmall) {
                    Circle()
                        .fill(Color(viewModel.calendar?.cgColor ?? UIColor.gray.cgColor))
                        .frame(width: 16, height: 16)
                        .padding(.xxxSmall)

                    Text(viewModel.calendar?.title ?? "")
                        .padding(.trailing, .xxSmall)
                }
            }
            .buttonStyle(.tertiary)
            .controlBorderShape(.capsule)
            .controlSize(.mini)
        }
        .navigationBarDividerColor(Color.onSurfaceHighEmphasis.opacity(0.1))
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .task {
            await viewModel.fetchData()
        }
        .onAppear {
            focusedField = .title
        }
        .sheet(item: $viewModel.sheet) { sheet in
            resolveSheet(sheet: sheet)
        }
        .onChange(of: viewModel.span) { _ in
            Task {
                _ = await viewModel.save()
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func content() -> some View {
        VStack(spacing: .small) {
            TextField("Event name", text: $viewModel.title)
                .title(.bold)
                .focused($focusedField, equals: .title)
                .onSurfaceHighEmphasisForegroundColor()
                .padding(.bottom, .xxxSmall)
                .padding(.horizontal, .small)

            textEditor

            calendarButtons

            allDayEvent

            locationView

            alarmView

            membersView

            repitView
        }
        .padding(.horizontal, .small)
        .padding(.vertical, .medium)
    }

    var allDayEvent: some View {
        Surface {
            viewModel.isAllDay.toggle()
        } label: {
            HStack {
                Text("All-day event")
                    .headline(.semibold)
                    .foregroundColor(.onSurfaceHighEmphasis)
                    .padding(.leading, .xxxSmall)

                Spacer()

                Toggle(isOn: $viewModel.isAllDay) {}
                    .labelsHidden()
            }
        }
        .surfaceBorderColor(Color.surfaceSecondary)
        .surfaceBorderWidth(1)
        .surfaceContentInsets(.init(horizontal: .xSmall, vertical: .xSmall))
        .controlRadius(.large)
    }

    var textEditor: some View {
        VStack(spacing: 2) {
            TextEditor(text: $viewModel.note)
                .onSurfaceHighEmphasisForegroundColor()
                .padding(.horizontal, .xSmall)
                .padding(.vertical, .xxSmall)
                .focused($focusedField, equals: .note)
                .body(.medium)
                .scrollContentBackground(.hidden)
                .background {
                    RoundedRectangleCorner(radius: 4, corners: [.bottomLeft, .bottomRight])
                        .fillSurfaceSecondary()
                        .overlay(alignment: .topLeading) {
                            if viewModel.note.isEmpty {
                                Text("Note")
                                    .body(.medium)
                                    .onSurfaceDisabledForegroundColor()
                                    .padding(.small)
                            }
                        }
                }
                .frame(minHeight: 76)

            TextField("URL", text: $viewModel.url)
                .focused($focusedField, equals: .url)
                .onSurfaceHighEmphasisForegroundColor()
                .body(.medium)
                .padding(.horizontal, .small)
                .padding(.vertical, 18)
                .background {
                    RoundedRectangleCorner(radius: 4, corners: [.topLeft, .topRight])
                        .fillSurfaceSecondary()
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: .large, style: .continuous))
    }

    var repitView: some View {
        Group {
            if viewModel.repitRule != .never {
                Surface {
                    Row(viewModel.repitRule.title, subtitle: repeatSubtitleText) {
                        viewModel.present(.repeat)
                    } leading: {
                        Icon(.refresh)
                            .iconColor(.onSurfaceHighEmphasis)
                    }
                    .rowClearButton(style: .onSurface) {
                        viewModel.repitRule = .never
                        viewModel.repitEndRule = .never
                    }
                    .surfaceContentInsets(.init(horizontal: .small, vertical: .medium))
                }
                .surfaceBorderColor(Color.surfaceSecondary)
                .surfaceBorderWidth(1)
                .surfaceContentInsets(.zero)
                .controlRadius(.large)
            }
        }
    }

    var membersView: some View {
        Group {
            if !viewModel.members.isEmpty {
                Surface {
                    VStack(spacing: .zero) {
                        ForEach(viewModel.members, id: \.self) { email in
                            Row(email) {
                                viewModel.present(.invites)
                            } leading: {
                                Icon(.user)
                                    .iconColor(.onSurfaceHighEmphasis)
                            }
                            .rowClearButton(style: .onSurface) {
                                viewModel.members.remove(email)
                            }
                            .rowContentInset(.small)
                            .overlay(alignment: .bottomLeading) {
                                Rectangle()
                                    .fillSurfaceSecondary()
                                    .padding(.leading, 56)
                                    .frame(height: 1)
                            }
                        }
                    }
                }
                .surfaceBorderColor(Color.surfaceSecondary)
                .surfaceBorderWidth(1)
                .surfaceContentInsets(.zero)
                .controlRadius(.large)
            }
        }
    }

    @ViewBuilder
    var alarmView: some View {
        Group {
            if let alarms = viewModel.alarms, !alarms.isEmpty {
                Surface {
                    VStack(spacing: .zero) {
                        ForEach(alarms) { alarm in
                            Row(alarm.title) {
                                viewModel.present(.alarm)
                            } leading: {
                                Icon(.bell)
                                    .iconColor(.onSurfaceHighEmphasis)
                            }
                            .rowClearButton(style: .onSurface) {
                                viewModel.alarms.remove(alarm)
                            }
                            .surfaceContentInsets(.init(horizontal: .small, vertical: .medium))
                            .overlay(alignment: .bottomLeading) {
                                Rectangle()
                                    .fillSurfaceSecondary()
                                    .padding(.leading, 56)
                                    .frame(height: 1)
                            }
                        }
                    }
                }
                .surfaceBorderColor(Color.surfaceSecondary)
                .surfaceBorderWidth(1)
                .surfaceContentInsets(.zero)
                .controlRadius(.large)
            }
        }
    }

    @ViewBuilder
    var locationView: some View {
        if viewModel.locationName != nil || viewModel.location != nil {
            Surface {
                VStack(spacing: .zero) {
                    if let locationName = viewModel.locationName {
                        VStack(spacing: .xxSmall) {
                            Row(locationName) {
                                viewModel.present(.location)
                            } leading: {
                                Icon(.mapPin)
                                    .iconColor(.onSurfaceHighEmphasis)
                            }
                            .rowClearButton(style: .onSurface) {
                                viewModel.locationName = nil
                                viewModel.location = nil
                            }
                            .rowContentInset(.init(horizontal: .small, vertical: .xSmall))
                        }
                    }

                    if let location = viewModel.location {
                        let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
                        let annotations = [MapPoint(name: "\(viewModel.locationName ?? "")", coordinate: location)]
                        Map(coordinateRegion: .constant(region), annotationItems: annotations) {
                            MapMarker(coordinate: $0.coordinate)
                        }
                        .frame(height: 130)
                        .cornerRadius(.small)
                        .padding(.horizontal, .xxSmall)
                        .padding(.bottom, .xxSmall)
                        .onTapGesture {
                            focusedField = nil
                            viewModel.present(.location)
                        }
                    }
                }
            }
            .surfaceBorderColor(Color.surfaceSecondary)
            .surfaceBorderWidth(1)
            .surfaceContentInsets(.zero)
            .controlRadius(.large)
        }
    }

    var repeatSubtitleText: String? {
        switch viewModel.repitEndRule {
        case .never:
            return nil
        case let .occurrenceCount(count):
            return count > 1 ? "With \(count) repetitions" : "With 1 repetition"
        case let .endDate(date):
            return "Until \(date.formatted(date: .long, time: .omitted))"
        }
    }

    var calendarButtons: some View {
        HStack(spacing: .small) {
            Button {
                focusedField = nil
                viewModel.present(.startTime)
            } label: {
                VStack(alignment: .leading, spacing: .xxxSmall) {
                    Text("Starts")
                        .onSurfaceMediumEmphasisForegroundColor()
                        .subheadline(.semibold)

                    Text(startDateText)
                        .onSurfaceHighEmphasisForegroundColor()
                        .headline(.semibold)

                    if !isCurrentYearEvent {
                        Text(viewModel.dateStart.formatted(.dateTime.year()))
                            .onSurfaceHighEmphasisForegroundColor()
                            .headline(.semibold)
                    }
                }
                .padding(.small)
                .hLeading()
                .background {
                    RoundedRectangle(cornerRadius: .large, style: .continuous)
                        .fillSurfaceSecondary()
                }
            }
            .buttonStyle(.scale)

            Button {
                focusedField = nil
                viewModel.present(.endTime)
            } label: {
                VStack(alignment: .leading, spacing: .xxxSmall) {
                    Text("Ended")
                        .onSurfaceMediumEmphasisForegroundColor()
                        .subheadline(.semibold)

                    Text(endDateText)
                        .onSurfaceHighEmphasisForegroundColor()
                        .headline(.semibold)

                    if !isCurrentYearEvent {
                        Text(viewModel.dateEnd.formatted(.dateTime.year()))
                            .onSurfaceHighEmphasisForegroundColor()
                            .headline(.semibold)
                    }
                }
                .padding(.small)
                .hLeading()
                .background {
                    RoundedRectangle(cornerRadius: .large, style: .continuous)
                        .fillSurfaceSecondary()
                }
            }
            .buttonStyle(.scale)
        }
    }

    var isCurrentYearEvent: Bool {
        Calendar.current.component(.year, from: viewModel.dateStart) == Calendar.current.component(.year, from: Date()) && Calendar.current.component(.year, from: viewModel.dateEnd) == Calendar.current.component(.year, from: Date())
    }

    var startDateText: String {
        if Calendar.current.isDateInToday(viewModel.dateStart) {
            return "Today \(viewModel.dateStart.formatted(date: .omitted, time: .shortened))"
        } else if Calendar.current.isDateInTomorrow(viewModel.dateStart) {
            return "Tomorrow \(viewModel.dateStart.formatted(date: .omitted, time: .shortened))"
        } else if Calendar.current.isDateInYesterday(viewModel.dateStart) {
            return "Yesterday \(viewModel.dateStart.formatted(date: .omitted, time: .shortened))"
        } else {
            return "\(viewModel.dateStart.formatted(.dateTime.day().month())) \(viewModel.dateStart.formatted(date: .omitted, time: .shortened))"
        }
    }

    var endDateText: String {
        if Calendar.current.isDateInToday(viewModel.dateEnd) {
            return "Today \(viewModel.dateEnd.formatted(date: .omitted, time: .shortened))"
        } else if Calendar.current.isDateInTomorrow(viewModel.dateEnd) {
            return "Tomorrow \(viewModel.dateEnd.formatted(date: .omitted, time: .shortened))"
        } else if Calendar.current.isDateInYesterday(viewModel.dateEnd) {
            return "Yesterday \(viewModel.dateEnd.formatted(date: .omitted, time: .shortened))"
        } else {
            return "\(viewModel.dateEnd.formatted(.dateTime.day().month())) \(viewModel.dateEnd.formatted(date: .omitted, time: .shortened))"
        }
    }

    var bottomBar: some View {
        HStack(spacing: .medium) {
            Button {
                Task {
                    focusedField = nil
                    viewModel.present(.location)
                }
            } label: {
                if viewModel.isFetchUpdatePositon {
                    ProgressView()
                } else {
                    Icon(.mapPin)
//                    Icon.Solid.NavigationandTravel.location
//                        .renderingMode(.template)
                }
            }
            .disabled(viewModel.isFetchUpdatePositon)

            Button { viewModel.present(.alarm) } label: {
                Icon(.bell)
//                Icon.Solid.UserInterface.bell
//                    .renderingMode(.template)
            }

            Button { viewModel.present(.repeat) } label: {
                Icon(.refresh)
            }

            /*
             Button { viewModel.present(.attachment) } label: {
                 Icon(.moreHorizontal)
             }
              */

            Spacer()

            Button { viewModel.present(.invites) } label: {
                Icon(.userPlus)
            }

//            Icon.Solid.UserInterface.plusCrFr
//                .renderingMode(.template)
        }
        .buttonStyle(.scale)
        .padding(.horizontal, .medium)
        .padding(.vertical, 20)
        .onSurfaceMediumEmphasisForegroundColor()
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.onSurfaceHighEmphasis.opacity(0.05))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private func placeholder() -> some View {}
}

extension CreateEventView {
    enum FocusField: Hashable {
        case title
        case note
        case url
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}
