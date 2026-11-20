//
//  Contact.swift
//  App_01
//
//  Created by Nethra Kalaimani on 23/10/26.
//

import Foundation
import SwiftData

@Model
class Contact: Identifiable {
    private(set) var id: UUID
    var firstName: String
    var lastName: String?
    var email: String?

    var phoneEntries: [PhoneEntry] = []

    // Details
    var address: String?
    var note: String?
    var birthday: Date?

    var additionalEmails: [String] = []

    var profileImageData: Data?
    var profileImageFilename: String?

    
    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String? = nil,
        email: String? = nil,
        phoneEntries: [PhoneEntry] = [],
        address: String? = nil,
        note: String? = nil,
        birthday: Date? = nil,
        additionalEmails: [String] = [],
        profileImageData: Data? = nil,
        profileImageFilename: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneEntries = phoneEntries
        self.address = address
        self.note = note
        self.birthday = birthday
        self.additionalEmails = additionalEmails
        self.profileImageData = profileImageData
        self.profileImageFilename = profileImageFilename
    }
    
    // Computed properties
    // First Last or just First if there is no Last name
    var fullName: String {
        if let lastName, !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        }
        return firstName
    }

    var initials: String {
        String.contactInitials(firstName: firstName, lastName: lastName)
    }

    // The main phone number — the first one in the list
    var phoneNumber: String {
        phoneEntries.first?.number ?? ""
    }

    // Every phone number as a plain string
    var phoneNumbers: [String] {
        phoneEntries.map { $0.number }
    }

    var emailAddresses: [String] {
        let trimmedPrimary = (email ?? "").trimmingCharacters(in: .whitespaces)
        let extras = additionalEmails.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return trimmedPrimary.isEmpty ? extras : [trimmedPrimary] + extras
    }

    
}
