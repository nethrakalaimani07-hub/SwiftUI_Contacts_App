//
//  App_01App.swift
//  App_01
//
//  Created by Nethra Kalaimani on 23/10/26.
//

import SwiftUI
import SwiftData
@main
struct ContactsApp: App {
    
    @State private var viewModel = ContactViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(viewModel)
        .modelContainer(for: [Contact.self, ContactTag.self])
        // retrival - @Environment(Type of the variable)
    }
}
