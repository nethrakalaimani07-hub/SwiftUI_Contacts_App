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

    // Favourites are still kept in memory (not SwiftData) — only the
    // contacts list itself is persisted now.
    private var _favouriteIDs: [UUID] = []

    // Adding, updating, deleting contacts (now via SwiftData)

    // Creates a new Contact and inserts it into SwiftData's
    // ModelContext, so it's actually saved to disk instead of just
    // living in memory. The View passes in its own `modelContext`
    // (read via @Environment(\.modelContext)) since this view model
    // doesn't have one of its own.
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
        isFavourite: Bool,
        context: ModelContext
    ) throws {
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

        // Old in-memory version: _contacts.append(newContact)
        context.insert(newContact)

        if isFavourite {
            _favouriteIDs.append(newContact.id)
        }

    }

    // Contact is a SwiftData @Model, which is a class — so a Contact
    // you got from a @Query is already "live": changing its
    // properties (like EditContactView does) already updates what
    // will be saved. This just makes sure that change is written to
    // disk right away instead of waiting for SwiftData's next
    // autosave.
    func updateContact(_ contact: Contact, context: ModelContext) {
        // Old in-memory version:
        // guard let index = contacts.firstIndex(where: { $0.id == contact.id })
        //       else { return }
        // _contacts[index] = contact
        try? context.save()
    }

    // Needs the current contacts list (from @Query in the calling
    // View) to find the one to delete, since this view model doesn't
    // keep its own list any more.
    func deleteContact(id: UUID, from contacts: [Contact], context: ModelContext) {
        guard let contact = contacts.first(where: { $0.id == id }) else { return }

        // Old in-memory version: _contacts.removeAll { $0.id == id }
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

    // Needs the current contacts list passed in now (from @Query),
    // to clear the deleted tag off any phone entry that used it.
    // Contact is a class, so mutating phoneEntries here saves
    // straight through to SwiftData.
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

    // Contacts marked as favourite, in the user's own chosen order.
    // Needs the full contacts list passed in now (from @Query in the
    // View), since this view model no longer keeps its own list.
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
