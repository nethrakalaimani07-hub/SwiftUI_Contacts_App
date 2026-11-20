//
//  PhoneEntry.swift
//  App_01
//

import Foundation
import SwiftData

// Phone Entry = Phone number + Tag?
@Model
class PhoneEntry: Identifiable, Equatable{
    private(set) var id: UUID
    var number: String
    var tagID: UUID?

    init(id: UUID = UUID(), number: String, tagID: UUID? = nil) {
        self.id = id
        self.number = number
        self.tagID = tagID
    }
}
