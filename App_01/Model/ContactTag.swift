//
//  ContactTag.swift
//  App_01
//
//  Created by Nethra Kalaimani on 04/11/26.
//

import Foundation
import SwiftData

@Model
final class ContactTag: Identifiable, Equatable, Hashable {
    private(set) var id: UUID
    var tagName: String

    init(id: UUID = UUID(), _ tagName: String) {
        self.id = id
        self.tagName = tagName
    }

    static func == (lhs: ContactTag, rhs: ContactTag) -> Bool {
        lhs.tagName == rhs.tagName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(tagName)
    }
}
