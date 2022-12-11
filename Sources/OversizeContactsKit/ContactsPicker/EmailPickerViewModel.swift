//
// Copyright © 2022 Alexander Romanov
// ContactsPickerViewModel.swift
//

import Contacts
import OversizeContactsService
import OversizeCore
import OversizeServices
import SwiftUI

@MainActor
class EmailPickerViewModel: ObservableObject {
    @Injected(Container.contactsService) private var contactsService: ContactsService
    @Published var state = ContactsPickerViewModelState.initial
    @Published var searchText: String = .init()

    @AppStorage("AppState.LastSelectedEmails") var lastSelectedEmails: [String] = .init()

    func fetchData() async {
        state = .loading
        let _ = await contactsService.requestAccess()
        do {
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactThumbnailImageDataKey]
            let result = try await contactsService.fetchContacts(keysToFetch: keys as [CNKeyDescriptor])
            switch result {
            case let .success(data):
                log("✅ CNContact fetched")
                state = .result(data)
            case let .failure(error):
                log("❌ CNContact not fetched (\(error.title))")
                state = .error(error)
            }
        } catch {
            state = .error(.custom(title: "Not contacts"))
        }
    }

    func getContactFromEmail(email: String, contacts: [CNContact]) -> CNContact? {
        for contact in contacts where !contact.emailAddresses.isEmpty {
            for emailAddress in contact.emailAddresses {
                let emailAddressString = emailAddress.value as String
                if emailAddressString == email {
                    return contact
                }
            }
        }
        return nil
    }
}

enum ContactsPickerViewModelState {
    case initial
    case loading
    case result([CNContact])
    case error(AppError)
}
