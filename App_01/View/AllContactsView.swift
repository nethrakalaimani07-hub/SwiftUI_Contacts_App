//
//  ContactsView.swift
//  App_01
//
//  Created by Nethra Kalaimani on 23/10/26.
//

import SwiftUI

struct AllContactsView: View {
    
    @Environment(ContactViewModel.self) private var viewModel
    
    @State private var showingAddContact = false
    
    @State private var searchText = ""

    @AppStorage("allContacts.showAvatar") private var showAvatar = true
    @AppStorage("allContacts.showPhoneText") private var showPhoneText = true
    @AppStorage("allContacts.showFavouriteButton") private var showFavouriteButton = true
    @AppStorage("allContacts.showCallButton") private var showCallButton = true
    @AppStorage("allContacts.showEmailButton") private var showEmailButton = false
    
    var body: some View {
        
        let filteredContacts = viewModel.searchContacts(
            viewModel.contacts,
            matching: searchText
        )
        
        let items = viewModel.contactListItems(
            from: filteredContacts
        )
        
        let groups = viewModel.groupedContacts(from: items)
        let letters = viewModel.sectionLetters(for: groups)
        
        List {
            ForEach(letters, id: \.self) { letter in
                ContactSectionRows(
                    letter: letter,
                    items: groups[letter] ?? []
                )
            }
            
        }
        .scrollContentBackground(.hidden)
        .background(Color.customAppBackground)
        .tint(.appPrimary)
        .navigationTitle("Contacts")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search name, phone, or email")
        .overlay {
            if viewModel.contacts.isEmpty {
                ContentUnavailableView(
                    "No Contacts",
                    systemImage: "person.crop.circle.badge.plus",
                    description: Text("Tap + to add your first contact.")
                )
            } else if filteredContacts.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                NavigationLink {
                    AllContactsSettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            
            ToolbarItem {
                Button {
                    showingAddContact = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .fullScreenCover(isPresented: $showingAddContact) {
            NavigationView {
                AddNewContactView()
            }
        }
        .onAppear {
//            ContactImageStorage().createDirectory()
        }
        .gesture(
            MagnificationGesture()
                .onEnded { scale in
                    if scale > 1 {
                        withAnimation {
                            zoomIn()
                        }
                    } else if scale < 1 {
                        withAnimation {
                            zoomOut()
                        }
                    }
                }
        )
        
    }
    

    private func zoomIn() {
        showAvatar = true
        showPhoneText = true
        showFavouriteButton = true
        showCallButton = true
        showEmailButton = true
    }

    private func zoomOut() {
        showAvatar = false
        showPhoneText = false
        showFavouriteButton = false
        showCallButton = true
        showEmailButton = false
    }
    
}

private struct ContactSectionRows: View {
    let letter: String
    let items: [ContactListItem]

    var body: some View {
        Section {
            ForEach(items) { item in
                ContactRow(item: item)
            }
            .navigationLinkIndicatorVisibility(.hidden)
        } header: {
            if letter == ContactViewModel.emojiSectionKey {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.appSecondaryText)
            } else {
                Text(letter)
                    .foregroundStyle(Color.appSecondaryText)
                    .textCase(nil)
            }
        }
    }
}

private struct ContactRow: View {
    let item: ContactListItem
    @Environment(ContactViewModel.self) private var viewModel

    @State private var showingDeleteConfirmation = false

    @AppStorage("allContacts.tapAction") private var tapAction: RowTapAction = .showDetails
    @AppStorage("allContacts.doubleTapAction") private var doubleTapAction: RowTapAction = .copyPhoneNumber
    @AppStorage("allContacts.longPressAction") private var longPressAction: RowTapAction = .showPreview

    @AppStorage("allContacts.showAvatar") private var showAvatar = true
    @AppStorage("allContacts.showPhoneText") private var showPhoneText = true
    @AppStorage("allContacts.showFavouriteButton") private var showFavouriteButton = true
    @AppStorage("allContacts.showCallButton") private var showCallButton = true
    @AppStorage("allContacts.showEmailButton") private var showEmailButton = false

    
    
    @State private var showingDetails = false
    @State private var showingPreview = false

    var body: some View {
        HStack {
            rowInfo

            Spacer()

            if showFavouriteButton {
                FavouriteButton(isFavourite: item.isFavourite) {
                    viewModel.toggleFavourite(id: item.id)
                }
            }

            if showCallButton {
                ContactChoiceButton(options: item.phoneNumbers) { number in
                    ContactAction.call(phoneNumber: number)
                } label: {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(Color.customAvatarText)
                        .padding(8)
                        .background(Color.appPrimary)
                        .clipShape(Circle())
                }
            }

            if showEmailButton {
                ContactChoiceButton(options: item.emailAddresses) { address in
                    ContactAction.email(to: address)
                } label: {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(Color.customAvatarText)
                        .padding(8)
                        .background(Color.appPrimary)
                        .clipShape(Circle())
                }
            }
        }
        .navigationDestination(isPresented: $showingDetails) {
            ContactDetailView(contactID: item.id)
        }
        .confirmationDialog(
            item.fullName,
            isPresented: $showingPreview,
            titleVisibility: .visible
        ) {
            ForEach(item.phoneNumbers, id: \.self) { number in
                Button("Call \(number)") {
                    ContactAction.call(phoneNumber: number)
                }
            }
            ForEach(item.emailAddresses, id: \.self) { address in
                Button("Mail \(address)") {
                    ContactAction.email(to: address)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listRowBackground(Color.appSurface)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .confirmationDialog(
            "Delete \(item.fullName)?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    viewModel.deleteContact(id: item.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var rowInfo: some View {
        ContactRowInfo(
            name: item.fullName,
            phone: item.phone,
            initials: item.initials,
            profileImageData: item.profileImageData,
            showAvatar: showAvatar,
            showPhoneText: showPhoneText
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            performAction(doubleTapAction)
        }
        .onTapGesture {
            performAction(tapAction)
        }
        .onLongPressGesture {
            performAction(longPressAction)
        }
    }


    private func performAction(_ action: RowTapAction) {
        switch action {
        case .showDetails:
            showingDetails = true
        case .copyPhoneNumber:
            UIPasteboard.general.string = item.phone
        case .showPreview:
            showingPreview = true
        case .call:
            ContactAction.call(phoneNumber: item.phone)
        }
    }
}

#Preview {
    NavigationStack {
        AllContactsView()
    }
}
