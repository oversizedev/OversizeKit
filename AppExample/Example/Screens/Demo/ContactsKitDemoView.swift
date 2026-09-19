//
// Copyright © 2026 Alexander Romanov
// ContactsKitDemoView.swift, created on 19.09.2026
//

import EventKit
import OversizeContactsKit
import OversizeUI
import SwiftUI

struct ContactsKitDemoView: View {
    @State private var emails: [String] = []
    @State private var isShowContactsList = false
    @State private var isShowEmailPicker = false
    @State private var isShowAttendees = false

    private let eventStore = EKEventStore()

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                SectionView("Screens") {
                    VStack(spacing: .zero) {
                        Row("Contacts") {
                            isShowContactsList = true
                        } leading: {
                            Image(systemName: "person.crop.circle")
                        }
                        .navigatable()
                        .buttonStyle(.row)

                        Row("Add invitees") {
                            isShowEmailPicker = true
                        } leading: {
                            Image(systemName: "envelope")
                        }
                        .navigatable()
                        .buttonStyle(.row)

                        Row("Invitees") {
                            isShowAttendees = true
                        } leading: {
                            Image(systemName: "person.2")
                        }
                        .navigatable()
                        .buttonStyle(.row)
                    }
                }
                .sectionContentCompactRowMargins()

                if !emails.isEmpty {
                    SectionView("Selected") {
                        VStack(spacing: .zero) {
                            ForEach(emails, id: \.self) { email in
                                Row(email)
                            }
                        }
                    }
                    .sectionContentCompactRowMargins()
                }
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Contacts")
        .sheet(isPresented: $isShowContactsList) {
            NavigationStack {
                ContactsListsView(emails: $emails)
            }
        }
        .sheet(isPresented: $isShowEmailPicker) {
            NavigationStack {
                EmailPickerView(selection: $emails)
            }
        }
        .sheet(isPresented: $isShowAttendees) {
            NavigationStack {
                AttendeesView(event: EKEvent(eventStore: eventStore))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactsKitDemoView()
    }
    .appEnvironment()
}
