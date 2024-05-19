//
// Copyright © 2023 Alexander Romanov
// ContactsListsView.swift
//

#if canImport(Contacts)
    import Contacts
#endif
import OversizeComponents
import OversizeCore
import OversizeKit
import OversizeLocalizable
import OversizeUI
import SwiftUI

#if !os(tvOS)
    public struct ContactsListsView: View {
        @StateObject var viewModel: ContactsListsViewModel
        @Environment(\.dismiss) var dismiss
        @Binding private var emails: [String]

        public init(emails: Binding<[String]>) {
            _viewModel = StateObject(wrappedValue: ContactsListsViewModel())
            _emails = emails
        }

        public var body: some View {
            PageView("") {
                Group {
                    switch viewModel.state {
                    case .initial:
                        placeholder()
                    case .loading:
                        placeholder()
                    case let .result(data):
                        content(data: data)
                    case let .error(error):
                        ErrorView(error)
                    }
                }
            }
            .leadingBar {
                BarButton(.close)
            }
            .task {
                await viewModel.fetchData()
            }
        }

        @ViewBuilder
        private func content(data: [CNContact]) -> some View {
            ForEach(emails, id: \.self) { email in
                if let contact = viewModel.getContactFromEmail(email: email, contacts: data) {
                    let emails = contact.emailAddresses
                    if !emails.isEmpty {
                        ForEach(emails, id: \.identifier) { email in
                            emailRow(email: email, contact: contact)
                        }
                    }
                } else {
                    Row(email) {
                        Avatar(firstName: email)
                    }
                }
            }
        }

        @ViewBuilder
        private func emailRow(email: CNLabeledValue<NSString>, contact: CNContact) -> some View {
            let email = email.value as String
            #if os(iOS)
                if let avatarThumbnailData = contact.thumbnailImageData, let avatarThumbnail = UIImage(data: avatarThumbnailData) {
                    Row(contact.givenName + " " + contact.familyName, subtitle: email) {
                        Avatar(firstName: contact.givenName, lastName: contact.familyName, avatar: Image(uiImage: avatarThumbnail))
                    }
                } else {
                    Row(contact.givenName + " " + contact.familyName, subtitle: email) {
                        Avatar(firstName: contact.givenName, lastName: contact.familyName)
                    }
                }
            #else
                Row(contact.givenName + " " + contact.familyName, subtitle: email) {
                    Avatar(firstName: contact.givenName, lastName: contact.familyName)
                }
            #endif
        }

        @ViewBuilder
        private func placeholder() -> some View {
            ForEach(emails, id: \.self) { email in
                Row(email) {
                    Avatar(firstName: email)
                }
            }
        }
    }
#endif
