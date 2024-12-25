//
// Copyright © 2023 Alexander Romanov
// EmailPickerView.swift
//

#if canImport(Contacts)
import Contacts
#endif
import OversizeKit
import OversizeLocalizable
import OversizeUI
import SwiftUI

#if !os(tvOS)
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
            BarButton(.accent("Done", action: {
                onDoneAction()
            }))
            .disabled(selectedEmails.isEmpty && !viewModel.searchText.isEmail)
        }
        .topToolbar {
            TextField("Email or name", text: $viewModel.searchText)
                .textFieldStyle(.default)
                .focused($isFocusSearth)
            #if os(iOS)
                .keyboardType(.emailAddress)
            #endif
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
            Checkbox(
                isOn: .constant(viewModel.searchText.isEmail),
                label: {
                    Row(viewModel.searchText, subtitle: "New member") {
                        Avatar(firstName: viewModel.searchText)
                    }
                }
            )
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
            .onSurfaceSecondaryForeground()
            .padding(.vertical, .xxSmall)
            .paddingContent(.horizontal)

            ForEach(viewModel.lastSelectedEmails, id: \.self) { email in
                if let contact = viewModel.getContactFromEmail(email: email, contacts: data) {
                    let emails = contact.emailAddresses
                    if !emails.isEmpty {
                        ForEach(emails, id: \.identifier) { email in
                            emailRow(email: email, contact: contact)
                        }
                    }
                } else {
                    let isSelected = selectedEmails.contains(email)
                    Checkbox(
                        isOn: Binding(
                            get: { isSelected },
                            set: { _ in onContactClick(email: email) }
                        ),
                        label: {
                            Row(email) {
                                Avatar(firstName: email)
                            }
                        }
                    )
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
            .onSurfaceSecondaryForeground()
            .padding(.vertical, .xxSmall)
            .paddingContent(.horizontal)
            .padding(.top, viewModel.lastSelectedEmails.isEmpty ? .zero : .small)

            ForEach(data, id: \.identifier) { contact in
                let emails = contact.emailAddresses
                if !emails.isEmpty {
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
        #if os(iOS)
        if let avatarThumbnailData = contact.thumbnailImageData, let avatarThumbnail = UIImage(data: avatarThumbnailData) {
            Checkbox(isOn: Binding(
                get: { isSelected },
                set: { _ in onContactClick(email: email) }
            ), label: {
                Row(contact.givenName + " " + contact.familyName, subtitle: email) {
                    Avatar(firstName: contact.givenName, lastName: contact.familyName, avatar: Image(uiImage: avatarThumbnail))
                }

            })
        } else {
            Checkbox(isOn: Binding(
                get: { isSelected },
                set: { _ in onContactClick(email: email) }
            ), label: {
                Row(contact.givenName + " " + contact.familyName, subtitle: email) {
                    Avatar(firstName: contact.givenName, lastName: contact.familyName)
                }

            })
        }
        #else
        Checkbox(isOn: Binding(
            get: { isSelected },
            set: { _ in onContactClick(email: email) }
        ), label: {
            Row(contact.givenName + " " + contact.familyName, subtitle: email) {
                Avatar(firstName: contact.givenName, lastName: contact.familyName)
            }

        })
        #endif
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
        #if os(watchOS)
        ProgressView()
        #else
        LoaderOverlayView()
        #endif
    }
}
#endif
// struct ContactsPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        EmailPickerView()
//    }
// }
