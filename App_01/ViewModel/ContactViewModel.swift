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

    private var _favouriteIDs: [UUID] = []

    private let dataActor: ContactDataActor

    init(dataActor: ContactDataActor) {
        self.dataActor = dataActor
    }
    
    // func addContact(
    //     firstName: String,
    //     lastName: String?,
    //     phoneEntries: [PhoneEntry],
    //     email: String?,
    //     address: String? = nil,
    //     note: String? = nil,
    //     birthday: Date? = nil,
    //     additionalEmails: [String] = [],
    //     profileImageData: Data? = nil,
    //     isFavourite: Bool,
    //     context: ModelContext
    // ) throws {
    //     let newContact = Contact(
    //         firstName: firstName,
    //         lastName: lastName,
    //         email: email,
    //         phoneEntries: phoneEntries,
    //         address: address,
    //         note: note,
    //         birthday: birthday,
    //         additionalEmails: additionalEmails,
    //         profileImageData: nil
    //     )
    //
    //     if let profileImageData {
    //         let fileName = try ContactImageStorage.saveImage(
    //             profileImageData,
    //             for: newContact.id
    //         )
    //
    //         newContact.profileImageFilename = fileName
    //     }
    //
    //     context.insert(newContact)
    //
    //     if isFavourite {
    //         _favouriteIDs.append(newContact.id)
    //     }
    // }
    //
    // func updateContact(_ contact: Contact, context: ModelContext) {
    //     try? context.save()
    // }
    //
    // func deleteContact(id: UUID, from contacts: [Contact], context: ModelContext) {
    //     guard let contact = contacts.first(where: { $0.id == id }) else { return }
    //
    //     if let fileName = contact.profileImageFilename {
    //         try? ContactImageStorage.deleteImage(named: fileName)
    //     }
    //
    //     context.delete(contact)
    //
    //     _favouriteIDs.removeAll { $0 == id }
    // }

   
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
    ) async throws {
        let newID = UUID()

        try await dataActor.addContact(
            id: newID,
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

        // _contacts.append(newContact)
        context.insert(newContact)

        if isFavourite {
            _favouriteIDs.append(newContact.id)
        }

    }

    func updateContact(_ contact: Contact, context: ModelContext) {
        // guard let index = contacts.firstIndex(where: { $0.id == contact.id })
        //       else { return }
        // _contacts[index] = contact
        try? context.save()
    }

    func deleteContact(id: UUID, from contacts: [Contact], context: ModelContext) {
        guard let contact = contacts.first(where: { $0.id == id }) else { return }

        // _contacts.removeAll { $0.id == id }
        context.delete(contact)

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
//    var tags: [ContactTag] {
//        tagViewModel.tags
//    }

    func addTag(name: String, tags: [ContactTag], context: ModelContext) -> ContactTag {
        tagViewModel.addTag(name: name, tags: tags, context: context)
    }

    func renameTag(id: UUID, to newName: String, tags: [ContactTag], context: ModelContext) {
        tagViewModel.renameTag(id: id, to: newName, tags: tags, context: context)
    }

    func deleteTag(tag: ContactTag, in contacts: [Contact], context: ModelContext) {
        tagViewModel.deleteTag(tag: tag, context: context)

        for contact in contacts {
            for phoneIndex in contact.phoneEntries.indices {
                if contact.phoneEntries[phoneIndex].tagID == tag.id {
                    contact.phoneEntries[phoneIndex].tagID = nil
                }
            }
        }
    }

    // Used to show a phone number's tag name.
    func getTagbyId(withID id: UUID?, tags: [ContactTag]) -> ContactTag? {
        tagViewModel.getTagById(withID: id, tags: tags)
    }

  
    func favouriteContacts(from contacts: [Contact]) -> [Contact] {
        _favouriteIDs.compactMap { id in
            contacts.first { $0.id == id }
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
