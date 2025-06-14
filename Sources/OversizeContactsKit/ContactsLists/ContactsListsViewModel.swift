//
// Copyright © 2022 Alexander Romanov
// ContactsListsViewModel.swift
//

#if canImport(Contacts)
@preconcurrency import Contacts
#endif
import FactoryKit
import OversizeContactsService
import OversizeCore
import OversizeModels
import SwiftUI

#if !os(tvOS)
@MainActor
public class ContactsListsViewModel: ObservableObject {
    @Injected(\.contactsService) private var contactsService: ContactsService
    @Published var state = ContactsPickerViewModelState.initial
    @Published var searchText: String = .init()

    public init() {}

    func fetchData() async {
        state = .loading
        let _ = await contactsService.requestAccess()

        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactThumbnailImageDataKey]
        let result = await contactsService.fetchContacts(keysToFetch: keys as [CNKeyDescriptor])
        switch result {
        case let .success(data):
            log("✅ CNContact fetched")
            state = .result(data)
        case let .failure(error):
            log("❌ CNContact not fetched (\(error.title))")
            state = .error(error)
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

enum ContactsListsViewModelState {
    case initial
    case loading
    case result([CNContact])
    case error(AppError)
}
#endif
