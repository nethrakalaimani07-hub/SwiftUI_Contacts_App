//
//  ContactTagViewModel.swift
//  App_01
//

import Foundation
import Observation
import SwiftData

@Observable
class ContactTagViewModel {

//    static let friendTag = ContactTag("Friend")
//    static let workTag = ContactTag("Work")
//    static let homeTag = ContactTag("Home")
//    static let otherTag = ContactTag("Other")
//    static let mobileTag = ContactTag("Mobile")
//    static let familyTag = ContactTag("Family")

//    private var _tags: Set<ContactTag> = [
//        ContactTagViewModel.friendTag,
//        ContactTagViewModel.workTag,
//        ContactTagViewModel.homeTag,
//        ContactTagViewModel.otherTag,
//        ContactTagViewModel.mobileTag,
//        ContactTagViewModel.familyTag
//    ]

    // All tags, sorted alphabetically for picker display.
//    var tags: [ContactTag] {
//        _tags.sorted { first, second in
//            return first.tagName < second.tagName
//        }
//    }

    func addTag(name: String, tags: [ContactTag] ,context: ModelContext) -> ContactTag {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if let existingTag = tags.first(where: { $0.tagName.caseInsensitiveCompare(trimmedName) == .orderedSame }) {
            return existingTag
        }

        let newTag = ContactTag(trimmedName)
        context.insert(newTag)
        return newTag
    }

    func renameTag(id: UUID, to newName: String, tags: [ContactTag], context: ModelContext) {
        let trimmedName = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty,
              let existingTag = tags.first(where: { $0.id == id })
                else { return }

        context.delete(existingTag)
        context.insert(ContactTag(id: id, trimmedName))
    }

    func deleteTag(tag: ContactTag, context: ModelContext) {
        context.delete(tag)
    }

    func getTagById(withID id: UUID?, tags: [ContactTag]) -> ContactTag? {
        guard let id else { return nil }
        return tags.first { $0.id == id }
    }
}
