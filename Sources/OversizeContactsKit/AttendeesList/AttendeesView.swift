//
// Copyright © 2023 Alexander Romanov
// AttendeesView.swift
//

#if canImport(Contacts) && canImport(EventKit)
    import Contacts
    import EventKit
#endif
import OversizeCalendarService
import OversizeContactsService
import OversizeCore
import OversizeKit
import OversizeLocalizable
import OversizeUI
import SwiftUI

#if !os(tvOS)
    public struct AttendeesView: View {
        @StateObject var viewModel: AttendeesViewModel
        @Environment(\.dismiss) var dismiss

        public init(event: EKEvent) {
            _viewModel = StateObject(wrappedValue: AttendeesViewModel(event: event))
        }

        public var body: some View {
            PageView("Invitees") {
                Group {
                    switch viewModel.state {
                    case .initial:
                        placeholder()
                            .onAppear {
                                Task {
                                    await viewModel.fetchData()
                                }
                            }
                    case .loading:
                        placeholder()
                    case let .result(data):
                        content(data)
                    case let .error(error):
                        ErrorView(error)
                    }
                }
            }
            .leadingBar {
                BarButton(.close)
            }
        }

        @ViewBuilder
        private func content(_: [CNContact]) -> some View {
            if let attendees = viewModel.event.attendees {
                VStack(spacing: .zero) {
                    if let organizer = viewModel.event.organizer {
                        Row(organizer.name ?? organizer.url.absoluteString, subtitle: "Organizer") {
                            userAvatarView(participant: organizer)
                        }
                    }

                    ForEach(attendees, id: \.self) { attender in
                        Row(attender.name ?? attender.url.absoluteString, subtitle: attender.participantRole.title) {
                            userAvatarView(participant: attender)
                        }
                    }
                }
            }
        }

        func userAvatarView(participant: EKParticipant) -> some View {
            ZStack(alignment: .bottomTrailing) {
                Avatar(firstName: participant.name ?? participant.url.absoluteString)
                    .controlSize(.regular)

                ZStack {
                    Circle()
                        .fill(participant.color)
                        .frame(width: 16, height: 16)
                        .background {
                            Circle()
                                .stroke(lineWidth: 4)
                                .fillBackgroundPrimary()
                        }
                    Image(systemName: participant.symbolName)
                        .onPrimaryForeground()
                        .font(.system(size: 9, weight: .black))
                }
            }
        }

        @ViewBuilder
        private func placeholder() -> some View {
            #if os(watchOS)
                ProgressView()
            #else
                LoaderOverlayView()
            #endif
        }
    }
#endif
