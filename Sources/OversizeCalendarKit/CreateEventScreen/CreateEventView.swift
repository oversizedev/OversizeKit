//
// Copyright © 2023 Alexander Romanov
// CreateEventView.swift
//

#if canImport(EventKit)
import EventKit
#endif
import MapKit
import OversizeCalendarService
import OversizeCore
import OversizeLocalizable
import OversizeResources
import OversizeUI
import SwiftUI

#if !os(tvOS)
public struct CreateEventView: View {
    @StateObject var viewModel: CreateEventViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: FocusField?

    @Namespace var unionNamespace

    public init(_ type: CreateEventType = .new(nil, calendar: nil)) {
        _viewModel = StateObject(wrappedValue: CreateEventViewModel(type))
    }

    public var body: some View {
        LayoutView {
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
                #if !os(tvOS)
                    .keyboardShortcut(.cancelAction)
                #endif
            }
            ToolbarItem(placement: .principal) {
                if #available(iOS 26, *) {
                    Button { viewModel.present(.calendar) } label: {
                        HStack(spacing: .xxxSmall) {
                            Circle()
                                .fill(Color(viewModel.calendar?.cgColor ?? CGColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)))
                                .frame(width: 16, height: 16)
                                .padding(.xxxSmall)
                            Text(viewModel.calendar?.title ?? "")
                                .padding(.trailing, .xxSmall)
                        }
                    }
                    .buttonStyle(.tertiary(infinityWidth: false))
                    .controlBorderShape(.capsule)
                } else {
                    Button { viewModel.present(.calendar) } label: {
                        HStack(spacing: .xxxSmall) {
                            Circle()
                                .fill(Color(viewModel.calendar?.cgColor ?? CGColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)))
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
            }
            ToolbarItem(placement: .primaryAction) {
                Button(L10n.Button.save, systemImage: "checkmark") {
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
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarPrimary)
                .disabled(viewModel.title.isEmpty)
                #if !os(tvOS)
                    .keyboardShortcut(.defaultAction)
                #endif
            }
        }
        .safeAreaBarBottom {
            if #available(iOS 26.0, *) {
                glassBottomBar
            } else {
                bottomBar
            }
        }
        .task {
            await viewModel.fetchData()
        }
        .onAppear {
            focusedField = .title
        }
        .sheet(item: $viewModel.sheet) { sheet in
            NavigationStack {
                resolveSheet(sheet: sheet)
            }
        }
        .onChange(of: viewModel.span) { _, _ in
            Task {
                _ = await viewModel.save()
                dismiss()
            }
        }
    }

    private var content: some View {
        VStack(spacing: .small) {
            TextField("Event name", text: $viewModel.title)
                .title(.bold)
                .focused($focusedField, equals: .title)
                .onSurfacePrimary()
                .padding(.bottom, .xxxSmall)
                .padding(.horizontal, .small)

            #if !os(watchOS)
            textEditor
            #endif

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
                    .foregroundColor(.onSurfacePrimary)
                    .padding(.leading, .xxxSmall)

                Spacer()

                Toggle(isOn: $viewModel.isAllDay) {}
                    .labelsHidden()
            }
        }
        .surfaceBorderColor(Color.surfaceSecondary)
        .surfaceBorderWidth(1)
        .surfaceRadius(.regular)
        .surfaceContentMargins(.small)
    }

    #if !os(watchOS)
    var textEditor: some View {
        VStack(spacing: 2) {
            TextEditor(text: $viewModel.note)
                .onSurfacePrimary()
                .padding(.horizontal, .xSmall)
                .padding(.vertical, .xxSmall)
                .focused($focusedField, equals: .note)
                .body(.medium)
                .scrollContentBackground(.hidden)
                .background {
                    #if os(iOS)
                    RoundedRectangleCorner(radius: 4, corners: [.bottomLeft, .bottomRight])
                        .fillSurfaceSecondary()
                        .overlay(alignment: .topLeading) {
                            if viewModel.note.isEmpty {
                                Text("Note")
                                    .body(.medium)
                                    .onSurfaceTertiary()
                                    .padding(.small)
                            }
                        }
                    #else
                    RoundedRectangle(cornerRadius: .small)
                        .fillSurfaceSecondary()
                        .overlay(alignment: .topLeading) {
                            if viewModel.note.isEmpty {
                                Text("Note")
                                    .body(.medium)
                                    .onSurfaceTertiary()
                                    .padding(.small)
                            }
                        }
                    #endif
                }
                .frame(minHeight: 76)

            TextField("URL", text: $viewModel.url)
                .focused($focusedField, equals: .url)
                .onSurfacePrimary()
                .body(.medium)
                .padding(.horizontal, .small)
                .padding(.vertical, 18)
                .background {
                    #if os(iOS)
                    RoundedRectangleCorner(radius: 4, corners: [.topLeft, .topRight])
                        .fillSurfaceSecondary()
                    #else
                    RoundedRectangle(cornerRadius: .small)
                        .fillSurfaceSecondary()
                    #endif
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: .regular, style: .continuous))
    }
    #endif

    var repitView: some View {
        Group {
            if viewModel.repitRule != .never {
                Surface {
                    Row(viewModel.repitRule.title, subtitle: repeatSubtitleText) {
                        viewModel.present(.repeat)
                    } leading: {
                        Image.Arrow.update.icon()
                    }
                    .rowClearButton(style: .onSurface) {
                        viewModel.repitRule = .never
                        viewModel.repitEndRule = .never
                    }
                    .rowContentMargins(.init(horizontal: .small, vertical: .small))
                }
                .surfaceBorderColor(Color.surfaceSecondary)
                .surfaceBorderWidth(1)
                .surfaceContentMargins(.zero)
                .surfaceRadius(.regular)
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
                                Image.Base.profile.icon()
                            }
                            .rowClearButton(style: .onSurface) {
                                viewModel.members.remove(email)
                            }
                            .rowContentMargins(.init(horizontal: .small, vertical: .small))
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
                .surfaceContentMargins(.zero)
                .surfaceRadius(.regular)
            }
        }
    }

    @ViewBuilder
    var alarmView: some View {
        if !viewModel.alarms.isEmpty {
            Surface {
                VStack(spacing: .zero) {
                    ForEach(viewModel.alarms) { alarm in
                        Row(alarm.title) {
                            viewModel.present(.alarm)
                        } leading: {
                            Image.Alert.bell.icon()
                        }
                        .rowClearButton(style: .onSurface) {
                            viewModel.alarms.remove(alarm)
                        }
                        .rowContentMargins(.init(horizontal: .small, vertical: .small))
                        .overlay(alignment: .bottomLeading) {
                            Rectangle()
                                .fillSurfaceSecondary()
                                .padding(.leading, 56)
                                .frame(height: 1)
                                .opacity(alarm.id == viewModel.alarms.last?.id ? 0 : 1)
                        }
                    }
                }
            }
            .surfaceBorderColor(Color.surfaceSecondary)
            .surfaceBorderWidth(1)
            .surfaceContentMargins(.zero)
            .surfaceRadius(.regular)
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
                                Image.Base.location.icon()
                            }
                            .rowClearButton(style: .onSurface) {
                                viewModel.locationName = nil
                                viewModel.location = nil
                            }
                            .rowContentMargins(.init(horizontal: .small, vertical: .small))
                        }
                    }

                    if let location = viewModel.location {
                        let region = MKCoordinateRegion(
                            center: location,
                            latitudinalMeters: 10000,
                            longitudinalMeters: 10000
                        )

                        Map(initialPosition: .region(region), interactionModes: []) {
                            Marker(
                                viewModel.locationName ?? "",
                                coordinate: location
                            )
                        }
                        .frame(height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: .small, style: .continuous))
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
            .surfaceContentMargins(.zero)
            .surfaceRadius(.regular)
        }
    }

    var repeatSubtitleText: String? {
        switch viewModel.repitEndRule {
        case .never:
            nil
        case let .occurrenceCount(count):
            count > 1 ? "With \(count) repetitions" : "With 1 repetition"
        case let .endDate(date):
            "Until \(date.formatted(date: .long, time: .omitted))"
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
                        .onSurfaceSecondary()
                        .subheadline(.semibold)

                    Text(startDateText)
                        .onSurfacePrimary()
                        .headline(.semibold)

                    if !isCurrentYearEvent {
                        Text(viewModel.dateStart.formatted(.dateTime.year()))
                            .onSurfacePrimary()
                            .headline(.semibold)
                    }
                }
                .padding(.small)
                .hLeading()
                .background {
                    RoundedRectangle(cornerRadius: .regular, style: .continuous)
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
                        .onSurfaceSecondary()
                        .subheadline(.semibold)

                    Text(endDateText)
                        .onSurfacePrimary()
                        .headline(.semibold)

                    if !isCurrentYearEvent {
                        Text(viewModel.dateEnd.formatted(.dateTime.year()))
                            .onSurfacePrimary()
                            .headline(.semibold)
                    }
                }
                .padding(.small)
                .hLeading()
                .background {
                    RoundedRectangle(cornerRadius: .regular, style: .continuous)
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
            "Today \(viewModel.dateStart.formatted(date: .omitted, time: .shortened))"
        } else if Calendar.current.isDateInTomorrow(viewModel.dateStart) {
            "Tomorrow \(viewModel.dateStart.formatted(date: .omitted, time: .shortened))"
        } else if Calendar.current.isDateInYesterday(viewModel.dateStart) {
            "Yesterday \(viewModel.dateStart.formatted(date: .omitted, time: .shortened))"
        } else {
            "\(viewModel.dateStart.formatted(.dateTime.day().month())) \(viewModel.dateStart.formatted(date: .omitted, time: .shortened))"
        }
    }

    var endDateText: String {
        if Calendar.current.isDateInToday(viewModel.dateEnd) {
            "Today \(viewModel.dateEnd.formatted(date: .omitted, time: .shortened))"
        } else if Calendar.current.isDateInTomorrow(viewModel.dateEnd) {
            "Tomorrow \(viewModel.dateEnd.formatted(date: .omitted, time: .shortened))"
        } else if Calendar.current.isDateInYesterday(viewModel.dateEnd) {
            "Yesterday \(viewModel.dateEnd.formatted(date: .omitted, time: .shortened))"
        } else {
            "\(viewModel.dateEnd.formatted(.dateTime.day().month())) \(viewModel.dateEnd.formatted(date: .omitted, time: .shortened))"
        }
    }

    @available(iOS 26.0, *)
    var glassBottomBar: some View {
        HStack {
            GlassEffectContainer {
                HStack {
                    Button {
                        Task {
                            focusedField = nil
                            viewModel.present(.location)
                        }
                    } label: {
                        if viewModel.isFetchUpdatePositon {
                            ProgressView()
                        } else {
                            Image.Base.location.icon()
                                .padding(.vertical)
                                .padding(.leading)
                                .padding(.trailing, .xxSmall)
                        }
                    }
                    .glassEffect()
                    .glassEffectUnion(id: "mapOptions", namespace: unionNamespace)
                    .disabled(viewModel.isFetchUpdatePositon)

                    Button { viewModel.present(.alarm) } label: {
                        Image.Alert.bell.icon().padding(.vertical).padding(.horizontal, .xSmall)
                    }
                    .glassEffect()
                    .glassEffectUnion(id: "mapOptions", namespace: unionNamespace)

                    Button { viewModel.present(.repeat) } label: {
                        Image.Arrow.update.icon().padding(.vertical).padding(.trailing).padding(.leading, .xxSmall)
                    }
                    .glassEffect()
                    .glassEffectUnion(id: "mapOptions", namespace: unionNamespace)
                }
            }

            Spacer()

            Button { viewModel.present(.invites) } label: {
                Image.User.addUser.icon()
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
        }
        .padding(.horizontal, .small)
        .padding(.vertical, .xSmall)
        .controlSize(.regular)
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
                    Image.Base.location
                }
            }
            .disabled(viewModel.isFetchUpdatePositon)

            Button { viewModel.present(.alarm) } label: {
                Image.Alert.bell
            }

            Button { viewModel.present(.repeat) } label: {
                Image.Arrow.update
            }

            Spacer()

            Button { viewModel.present(.invites) } label: {
                Image.User.addUser
            }
        }
        .buttonStyle(.scale)
        .padding(.horizontal, .medium)
        .padding(.vertical, 20)
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.onSurfacePrimary.opacity(0.05))
                .frame(height: 1)
        }
    }
}

extension CreateEventView {
    enum FocusField: Hashable {
        case title
        case note
        case url
    }
}

#Preview {
    CreateEventView()
}
#endif
