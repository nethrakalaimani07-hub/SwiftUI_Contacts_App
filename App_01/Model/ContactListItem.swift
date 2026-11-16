//
//  ContactListItem.swift
//  App_01
//
//  Created by Nethra Kalaimani on 29/10/26.
//

// model for the row items in ContactsView and FavoritesView list
import Foundation

struct ContactListItem: Identifiable {
    let id: UUID
    let fullName: String
    let phoneEntries: [PhoneEntry]
    let email: String?
    let additionalEmails: [String]
    let isFavourite: Bool
    let initials: String
    let profileImageData: Data?
    let profileImageFilename: String?

    var phone: String {
        phoneEntries.first?.number ?? ""
    }

    var phoneNumbers: [String] {
        phoneEntries.map { $0.number }
    }

    var emailAddresses: [String] {
        let trimmedPrimary = (email ?? "").trimmingCharacters(in: .whitespaces)
        let extras = additionalEmails.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return trimmedPrimary.isEmpty ? extras : [trimmedPrimary] + extras
    }
}

extension Contact {
    
    func listItem(isFavourite: Bool) -> ContactListItem {
        ContactListItem(
            id: id,
            fullName: fullName,
            phoneEntries: phoneEntries,
            email: email,
            additionalEmails: additionalEmails,
            isFavourite: isFavourite,
            initials: initials,
            profileImageData: profileImageData,
            profileImageFilename: profileImageFilename
        )
    }
}
