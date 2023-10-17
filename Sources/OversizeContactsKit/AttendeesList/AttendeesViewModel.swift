//
// Copyright © 2022 Alexander Romanov
// AttendeesViewModel.swift
//

import Contacts
import EventKit
import Factory
import OversizeContactsService
import OversizeCore
import OversizeModels
import SwiftUI

@MainActor
class AttendeesViewModel: ObservableObject {
    @Injected(\.contactsService) private var contactsService: ContactsService
    @Published var state = AttendeesViewModelState.initial
    @Published var searchText: String = .init()

    let event: EKEvent

    init(event: EKEvent) {
        self.event = event
    }

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

enum AttendeesViewModelState {
    case initial
    case loading
    case result([CNContact])
    case error(AppError)
}
