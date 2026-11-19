//
//  ContactDetailView.swift
//  App_01
//
//  Created by Nethra Kalaimani on 23/10/26.
//

import SwiftUI
import SwiftData

struct ContactDetailView: View {
    

    let contactID: UUID
    @Environment(ContactViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @Query private var contacts: [Contact]
    @Query private var tags: [ContactTag]
    
    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false
    
    @Environment(\.dismiss) private var dismiss

    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = AppTheme.classic.rawValue

    private var contact: Contact? {
        contacts.first { $0.id == contactID }
    }


    var body: some View {
        VStack {
            if let contact {
                List {
                    Section {
                        VStack(spacing: 0) {
                            VStack(spacing: 8) {
                                ContactAvatar(
                                    imageData: contact.profileImageData,
                                    initials: contact.initials,
                                    size: 100
                                )

                                Text(contact.fullName)
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(Color.appText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            
                            Divider()
                                .overlay(Color.appSecondaryText.opacity(0.25))
                                .padding(8)
                            
                            // Action buttons
                            HStack(spacing: 32) {
                                ContactActionButton(
                                    icon: "message.fill", title: "Message",
                                    options: contact.phoneNumbers
                                ) { number in
                                    ContactAction.message(phoneNumber: number)
                                }
                                
                                ContactActionButton(
                                    icon: "phone.fill", title: "Call",
                                    options: contact.phoneNumbers
                                ) { number in
                                    ContactAction.call(phoneNumber: number)
                                }
                                
                                
                                ContactActionButton(
                                    icon: "video.fill", title: "Video",
                                    options: contact.phoneNumbers
                                ) { identifier in
                                    ContactAction.videoCall(identifier: identifier)
                                }
                                
                                ContactActionButton(
                                    icon: "envelope.fill", title: "Mail",
                                    isDisabled: contact.emailAddresses.isEmpty,
                                    options: contact.emailAddresses
                                ) { address in
                                    ContactAction.email(to: address)
                                }
                                                        
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                    }
                    
                    Section("Contact Info") {
                        ForEach(contact.phoneEntries) { entry in
                            let label = viewModel.getTagbyId(withID: entry.tagID, tags: tags)?.tagName ?? "Phone"
                                LabeledContent(label, value: entry.number)
                                .onTapGesture {
                                    ContactAction.call(phoneNumber: entry.number)
                                }
                        }

                        if let email = contact.email, !email.isEmpty {
                            LabeledContent("Email", value: email)
                                .onTapGesture {
                                    ContactAction.email(to: email)
                                }
                        }

                        ForEach(contact.additionalEmails, id: \.self) { extraEmail in
                            LabeledContent("Email", value: extraEmail)
                                .onTapGesture {
                                    ContactAction.email(to: extraEmail)
                                }
                        }

                        if let address = contact.address, !address.isEmpty {
                            LabeledContent("Address", value: address)
                        }

                        if let birthday = contact.birthday {
                            LabeledContent("Birthday", value: birthday.formatted(.dateTime.day().month(.wide)))
                        }
                    }

                    if let note = contact.note, !note.isEmpty {
                        Section("Note") {
                            Text(note)
                        }
                    }
                    
                    Section {
                        Button {
                            viewModel.toggleFavourite(id: contact.id)
                        } label: {
                            Label(
                                viewModel.isFavourite(id: contact.id) ? "Remove from Favourites" : "Add to Favourites",
                                systemImage: viewModel.isFavourite(id: contact.id) ? "star.slash" : "star"
                            )
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteConfirm = true
                        } label: {
                            Label("Delete Contact", systemImage: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.customAppBackground)
                .tint(.appPrimary)
                .navigationTitle(contact.fullName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Edit", systemImage: "pencil") {
                        showingEdit = true
                    }
                    
                }
                .fullScreenCover(isPresented: $showingEdit) {
                    NavigationStack {
                        EditContactView(contact: contact)
                    }
                }
                .alert("Delete \(contact.fullName)?", isPresented: $showingDeleteConfirm) {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteContact(id: contact.id, from: contacts , context: modelContext)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }
    
    
    private func shareText(for contact: Contact) -> String {

        var details = [
            "Name: \(contact.fullName)"
        ]

        for entry in contact.phoneEntries {
            details.append("Phone: \(entry.number)")
        }

        if let email = contact.email, !email.isEmpty {
            details.append("Email: \(email)")
        }

        return details.joined(separator: "\n")
    }
}

private struct ContactActionButton: View {
    let icon: String
    let title: String
    var isDisabled: Bool = false
    let options: [String]
    let onPick: (String) -> Void

    var body: some View {
        ContactChoiceButton(options: options, onPick: onPick) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.customAvatarText)
                    .frame(width: 50, height: 50)
                    .background(
                        isDisabled
                        ? Color.appSecondaryText.opacity(0.3)
                        : Color.appPrimary
                    )
                    .clipShape(Circle())
                
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isDisabled
                                     ? Color.appSecondaryText
                                     : Color.appPrimary
                    )
            }
        }
        .disabled(isDisabled)
    }
}

#Preview {
    NavigationStack {
        ContactDetailView(contactID: UUID())
            .environment(ContactViewModel())
            .modelContainer(for: Contact.self, inMemory: true)
    }
}
