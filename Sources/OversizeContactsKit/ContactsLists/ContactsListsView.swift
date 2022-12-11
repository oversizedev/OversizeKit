// 
//  ContactsListsView.swift
//  
//
//  Created by Aleksandr Romanov on 11.12.2022.
//

import OversizeComponents
import OversizeCore
import OversizeLocalizable
import OversizeServices
import OversizeUI
import SwiftUI
import Contacts
import OversizeKit

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
            BarButton(type: .close)
        }
        .task {
            await viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    private func content(data: [CNContact]) -> some View {
        ForEach(emails, id: \.self) { email in
            if let contact = viewModel.getContactFromEmail(email: email, contacts: data) {
                if let emails = contact.emailAddresses, !emails.isEmpty {
                    ForEach(emails, id: \.identifier) { email in
                        emailRow(email: email, contact: contact)
                    }
                }
            } else {
                Row(email)
                .rowLeading(.avatar(AvatarView(firstName: email)))
            }
        }
    }
    
    @ViewBuilder
    private func emailRow(email: CNLabeledValue<NSString>, contact: CNContact) -> some View {
        let email = email.value as String
        if let avatarThumbnailData = contact.thumbnailImageData, let avatarThumbnail = UIImage(data: avatarThumbnailData) {
            Row(contact.givenName + " " + contact.familyName, subtitle: email)
                .rowLeading(.avatar(AvatarView(firstName: contact.givenName, lastName: contact.familyName, avatar: Image(uiImage: avatarThumbnail))))
        } else {
            Row(contact.givenName + " " + contact.familyName, subtitle: email)
                .rowLeading(.avatar(AvatarView(firstName: contact.givenName, lastName: contact.familyName)))
            
        }
    }
    
    @ViewBuilder
    private func placeholder() -> some View {
        ForEach(emails, id: \.self) { email in
            Row(email)
                .rowLeading(.avatar(AvatarView(firstName: email)))
        }
    }
}
