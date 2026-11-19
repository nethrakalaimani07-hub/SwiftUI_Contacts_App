//
//  ContactViewModel.swift
//  App_01
//
//  Created by Nethra Kalaimani on 23/10/26.
//

import Foundation
import Observation
import SwiftUI
import SwiftData


@Observable
class ContactViewModel {

    private let tagViewModel = ContactTagViewModel()
    
    // The contacts list in the whole app
    private var _contacts: [Contact] = []
    private var _favouriteIDs: [UUID] = []

    init() {
        _contacts.append(contentsOf: [Contact(
            firstName: "Nethra",
            lastName: "K",
            email: "nethra.k@example.com",
            phoneEntries: [
                PhoneEntry(number: "+91 8428497598", tagID: ContactTagViewModel.mobileTag.id),
                PhoneEntry(number: "+91 9876500011", tagID: ContactTagViewModel.workTag.id)
            ],
            address: "12 MG Road, Chennai",
            note: "College friend, loves hiking.",
            birthday: ContactViewModel.date(year: 1998, month: 5, day: 14),
            additionalEmails: ["nethra.k@work.com"]
        ),

        Contact(
            firstName: "Surya",
            phoneEntries: [PhoneEntry(number: "+91 1234567890", tagID: ContactTagViewModel.mobileTag.id)]
        ),

        Contact(
            firstName: "Sree",
            lastName: "Y",
            phoneEntries: [PhoneEntry(number: "+91 1234567890", tagID: ContactTagViewModel.mobileTag.id)]
        ),

        Contact(
            firstName: "Dharshana",
            lastName: "I",
            email: "dharshana.i@example.com",
            phoneEntries: [PhoneEntry(number: "+91 9876501234", tagID: ContactTagViewModel.mobileTag.id)],
            address: "45 Anna Nagar, Madurai",
            note: "Prefers calls over texts.",
            birthday: ContactViewModel.date(year: 2000, month: 11, day: 2)
        ),

        Contact(
            firstName: "Swathi",
            lastName: "L",
            email: "swathi.l@example.com",
            phoneEntries: [PhoneEntry(number: "+91 9123456780", tagID: ContactTagViewModel.mobileTag.id)],
            note: "Met at the design meetup.",
            birthday: ContactViewModel.date(year: 1999, month: 8, day: 23),
            additionalEmails: ["swathi.personal@example.com"]
        ),

        Contact(
            firstName: "Arun",
            lastName: "P",
            phoneEntries: [PhoneEntry(number: "+91 9876543210", tagID: ContactTagViewModel.mobileTag.id)]
        ),

        Contact(
            firstName: "Bala",
            lastName: "M",
            phoneEntries: [PhoneEntry(number: "+91 9988776655", tagID: ContactTagViewModel.mobileTag.id)]
        ),

        Contact(
            firstName: "Nishanth",
            lastName: "S A",
            email: "nishanth.sa@example.com",
            phoneEntries: [
                PhoneEntry(number: "+91 9898776655", tagID: ContactTagViewModel.mobileTag.id),
                PhoneEntry(number: "+91 9000011122", tagID: ContactTagViewModel.homeTag.id),
                PhoneEntry(number: "+91 9000033344", tagID: ContactTagViewModel.workTag.id)
            ],
            address: "7 Lake View Street, Coimbatore",
            birthday: ContactViewModel.date(year: 1997, month: 2, day: 9)
        )])
        
        _favouriteIDs.append(contentsOf: [_contacts[0].id, _contacts[4].id, _contacts[7].id, _contacts[3].id] )
    }

    // Small helper just for building the birthday dates above
    // without writing out DateComponents + Calendar every time.
    private static func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
    
     var contacts : [Contact] {
        _contacts
    }

    func addContact(
        firstName: String,
        lastName: String?,
        phoneEntries: [PhoneEntry],
        email: String?,
        address: String? = nil,
        note: String? = nil,
        birthday: Date? = nil,
        additionalEmails: [String] = [],
        profileImageData: Data? = nil,
        isFavourite: Bool
    ) throws -> Contact {
        let newContact = Contact(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneEntries: phoneEntries,
            address: address,
            note: note,
            birthday: birthday,
            additionalEmails: additionalEmails,
            profileImageData: nil
        )

        if let profileImageData {
            let fileName = try ContactImageStorage.saveImage(
                profileImageData,
                for: newContact.id
            )

            newContact.profileImageFilename = fileName
        }

        _contacts.append(newContact)
        
        if isFavourite {
            _favouriteIDs.append(newContact.id)
        }
        
        return newContact
    }

    func updateContact(_ contact: Contact) {
        guard let index = contacts.firstIndex(where: { $0.id == contact.id })
              else { return }
        _contacts[index] = contact
    }

    func deleteContact(id: UUID) {
        _contacts.removeAll { $0.id == id }
        _favouriteIDs.removeAll { $0 == id }
    }

    func toggleFavourite(id: UUID) {
        if let index = _favouriteIDs.firstIndex(of: id) {
            _favouriteIDs.remove(at: index)
        } else {
            _favouriteIDs.append(id)
        }
    }

    func isFavourite(id: UUID) -> Bool {
        _favouriteIDs.contains(id)
    }

    // Reorder, Used by FavouritesView's drag-to-reorder.
    func moveFavourite(from source: IndexSet, to destination: Int) {
        _favouriteIDs.move(fromOffsets: source, toOffset: destination)
    }

    // All tags, sorted alphabetically for picker display.
    var tags: [ContactTag] {
        tagViewModel.tags
    }

    func addTag(name: String) -> ContactTag {
        tagViewModel.addTag(name: name)
    }

    func renameTag(id: UUID, to newName: String) {
        tagViewModel.renameTag(id: id, to: newName)
    }

    func deleteTag(id: UUID) {
        tagViewModel.deleteTag(id: id)

        for contactIndex in _contacts.indices {
            for phoneIndex in _contacts[contactIndex].phoneEntries.indices {
                if _contacts[contactIndex].phoneEntries[phoneIndex].tagID == id {
                    _contacts[contactIndex].phoneEntries[phoneIndex].tagID = nil
                }
            }
        }
    }

    // Used to show a phone number's tag name.
    func getTagbyId(withID id: UUID?) -> ContactTag? {
        tagViewModel.getTagById(withID: id)
    }


    var favouriteContacts: [Contact] {
        _favouriteIDs.compactMap { id in
            _contacts.first { $0.id == id }
        }
    }

    func contactListItems(from contacts: [Contact]) -> [ContactListItem] {
        contacts.map { $0.listItem(isFavourite: isFavourite(id: $0.id)) }
    }

    func searchContacts(_ contacts: [Contact], matching query: String) -> [Contact] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return contacts }

        return contacts.filter { contact in
            if contact.fullName.localizedCaseInsensitiveContains(trimmedQuery) {
                return true
            }

            if contact.phoneNumbers.contains(where: { $0.localizedCaseInsensitiveContains(trimmedQuery) }) {
                return true
            }

            if let email = contact.email, email.localizedCaseInsensitiveContains(trimmedQuery) {
                return true
            }

            if contact.additionalEmails.contains(where: { $0.localizedCaseInsensitiveContains(trimmedQuery) }) {
                return true
            }
            
            if let note = contact.note, note.localizedStandardContains(trimmedQuery) {
                return true
            }

            return false
        }
    }

    static let emojiSectionKey = "✨"

    func groupedContacts(from items: [ContactListItem]) -> [String: [ContactListItem]] {
        var groups: [String: [ContactListItem]] = [:]

        for item in items {
            let key: String
            if item.fullName.startsWithEmoji {
                key = ContactViewModel.emojiSectionKey
            } else {
                key = String(item.fullName.prefix(1)).uppercased()
            }
            groups[key, default: []].append(item)
        }

        for key in groups.keys {
            groups[key] = sortByFullName(groups[key] ?? [])
        }

        return groups
    }

    func sectionLetters(for groups: [String: [ContactListItem]]) -> [String] {

        groups.keys.sorted { lhs, rhs in
            if lhs == ContactViewModel.emojiSectionKey { return false }
            if rhs == ContactViewModel.emojiSectionKey { return true }
            return lhs < rhs
        }
    }

    private func sortByFullName(_ items: [ContactListItem]) -> [ContactListItem] {
        return items.sorted { first, second in
            return first.fullName < second.fullName
        }
    }
}


