//
// Copyright © 2023 Alexander Romanov
// EmailPickerView.swift
//

import Contacts
import OversizeKit
import OversizeLocalizable
import OversizeServices
import OversizeUI
import SwiftUI

public struct EmailPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EmailPickerViewModel

    @Binding private var selection: [String]
    @State private var selectedEmails: [String] = .init()

    @FocusState private var isFocusSearth

    public init(selection: Binding<[String]>) {
        _viewModel = StateObject(wrappedValue: EmailPickerViewModel())
        _selection = selection
    }

    public var body: some View {
        PageView("Add Invitees") {
            Group {
                switch viewModel.state {
                case .initial, .loading:
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
        .trailingBar {
            if selectedEmails.isEmpty, !viewModel.searchText.isEmail {
                BarButton(.disabled("Done"))
            } else {
                BarButton(.accent("Done", action: {
                    onDoneAction()
                }))
            }
        }
        .topToolbar {
            TextField("Email or name", text: $viewModel.searchText)
                .textFieldStyle(DefaultPlaceholderTextFieldStyle())
                .focused($isFocusSearth)
                .keyboardType(.emailAddress)
        }
        .onAppear {
            isFocusSearth = true
        }
        .task {
            await viewModel.fetchData()
        }
    }

    @ViewBuilder
    private func content(data: [CNContact]) -> some View {
        LazyVStack(spacing: .zero) {
            newEmailView()

            newSelectedContactsRows(data: data)

            contactsRows(data: data)
        }
    }

    @ViewBuilder
    private func newEmailView() -> some View {
        if !viewModel.searchText.isEmpty {
            Row(viewModel.searchText, subtitle: "New member")
                .rowLeading(.avatar(Avatar(firstName: viewModel.searchText)))
                .rowTrailing(.checkbox(isOn: .constant(viewModel.searchText.isEmail)))
                .padding(.bottom, .small)
        }
    }

    @ViewBuilder
    private func newSelectedContactsRows(data: [CNContact]) -> some View {
        if !viewModel.lastSelectedEmails.isEmpty {
            HStack(spacing: .zero) {
                Text("Latest")
                Spacer()
            }
            .title3()
            .foregroundOnSurfaceMediumEmphasis()
            .padding(.vertical, .xxSmall)
            .paddingContent(.horizontal)

            ForEach(viewModel.lastSelectedEmails, id: \.self) { email in
                if let contact = viewModel.getContactFromEmail(email: email, contacts: data) {
                    if let emails = contact.emailAddresses, !emails.isEmpty {
                        ForEach(emails, id: \.identifier) { email in
                            emailRow(email: email, contact: contact)
                        }
                    }
                } else {
                    let isSelected = selectedEmails.contains(email)
                    Row(email) {
                        onContactClick(email: email)
                    }
                    .rowLeading(.avatar(Avatar(firstName: email)))
                    .rowTrailing(.checkbox(isOn: .constant(isSelected)))
                }
            }
        }
    }

    @ViewBuilder
    private func contactsRows(data: [CNContact]) -> some View {
        if !data.isEmpty {
            HStack(spacing: .zero) {
                Text("Contacts")
                Spacer()
            }
            .title3()
            .onSurfaceMediumEmphasisForegroundColor()
            .padding(.vertical, .xxSmall)
            .paddingContent(.horizontal)
            .padding(.top, viewModel.lastSelectedEmails.isEmpty ? .zero : .small)

            ForEach(data, id: \.identifier) { contact in
                if let emails = contact.emailAddresses, !emails.isEmpty {
                    ForEach(emails, id: \.identifier) { email in
                        emailRow(email: email, contact: contact)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func emailRow(email: CNLabeledValue<NSString>, contact: CNContact) -> some View {
        let email = email.value as String
        let isSelected = selectedEmails.contains(email)
        if let avatarThumbnailData = contact.thumbnailImageData, let avatarThumbnail = UIImage(data: avatarThumbnailData) {
            Row(contact.givenName + " " + contact.familyName, subtitle: email) {
                onContactClick(email: email)
            }
            .rowLeading(.avatar(Avatar(firstName: contact.givenName, lastName: contact.familyName, avatar: Image(uiImage: avatarThumbnail))))
            .rowTrailing(.checkbox(isOn: .constant(isSelected)))
        } else {
            Row(contact.givenName + " " + contact.familyName, subtitle: email) {
                onContactClick(email: email)
            }
            .rowLeading(.avatar(Avatar(firstName: contact.givenName, lastName: contact.familyName)))
            .rowTrailing(.checkbox(isOn: .constant(isSelected)))
        }
    }

    private func onDoneAction() {
        if viewModel.searchText.isEmail {
            if !selection.contains(viewModel.searchText) {
                selection.append(viewModel.searchText)
            }

            if !viewModel.lastSelectedEmails.contains(viewModel.searchText) {
                viewModel.lastSelectedEmails.append(viewModel.searchText)
            }
        }

        if !selectedEmails.isEmpty {
            for email in selectedEmails where !selection.contains(email) {
                selection.append(email)
            }

            for email in selectedEmails where !viewModel.lastSelectedEmails.contains(email) {
                viewModel.lastSelectedEmails.append(email)
            }
        }

        dismiss()
    }

    private func onContactClick(email: String) {
        let isSelected = selectedEmails.contains(email)
        if isSelected {
            selectedEmails.remove(email)
        } else {
            selectedEmails.append(email)
        }
    }

    @ViewBuilder
    private func placeholder() -> some View {
        LoaderOverlayView()
    }
}

// struct ContactsPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        EmailPickerView()
//    }
// }
