//
//  FavouritesView.swift
//  App_01
//
//  Created by Nethra Kalaimani on 23/10/26.
//

import SwiftUI

struct FavouritesView: View {
    
    @Environment(ContactViewModel.self) private var viewModel
    
    @State private var searchText = ""
    
    // What to show in each row
    @AppStorage("favourites.showAvatar") private var showAvatar = true
    @AppStorage("favourites.showPhoneText") private var showPhoneText = true
    @AppStorage("favourites.showFavouriteButton") private var showFavouriteButton = true
    @AppStorage("favourites.showCallButton") private var showCallButton = true
    @AppStorage("favourites.showEmailButton") private var showEmailButton = false
    
    var body: some View {
        
        // Favourites no longer get grouped alphabetically — the user's
        // own drag order *is* the order, and alphabetical sections would
        // fight with that, so this is one flat, reorderable list.
        let filteredFavourites = viewModel.searchContacts(
            viewModel.favouriteContacts,
            matching: searchText
        )
        
        let items = viewModel.contactListItems(
            from: filteredFavourites
        )
        
        List {
            ForEach(items) { item in
                FavouriteRow(item: item)
            }
            .onMove { source, destination in
                withAnimation {
                    viewModel.moveFavourite(from: source, to: destination)
                }
            }
            .navigationLinkIndicatorVisibility(.hidden)
        }
        .scrollContentBackground(.hidden)
        .background(Color.customAppBackground)
        .tint(Color.appPrimary)
        .navigationTitle("Favourites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !viewModel.favouriteContacts.isEmpty {
                    EditButton()
                        .disabled(!searchText.isEmpty)
                }
            }

            ToolbarItem(placement: .topBarTrailing){
                NavigationLink {
                    FavouritesSettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .searchable(text: $searchText ,prompt: "Search name, phone, or email")
        .overlay {
            if viewModel.favouriteContacts.isEmpty {
                ContentUnavailableView(
                    "No Favourites",
                    systemImage: "star",
                    description: Text("Mark a contact as favourite to see it here.")
                )
            } else if filteredFavourites.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
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

private struct FavouriteRow: View {
    let item: ContactListItem
    @Environment(ContactViewModel.self) private var viewModel

    @State private var showingDeleteConfirmation = false

    // Chosen by the user on the Favourites settings page.
    @AppStorage("favourites.tapAction") private var tapAction: RowTapAction = .call
    @AppStorage("favourites.doubleTapAction") private var doubleTapAction: RowTapAction = .copyPhoneNumber
    @AppStorage("favourites.longPressAction") private var longPressAction: RowTapAction = .showPreview

    // What to show in the row. Chosen by the user on the row layout settings page
    @AppStorage("favourites.showAvatar") private var showAvatar = true
    @AppStorage("favourites.showPhoneText") private var showPhoneText = true
    @AppStorage("favourites.showFavouriteButton") private var showFavouriteButton = true
    @AppStorage("favourites.showCallButton") private var showCallButton = true
    @AppStorage("favourites.showEmailButton") private var showEmailButton = false

    // Turned on by performAction()
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
                        .font(.title3)
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
                viewModel.deleteContact(id: item.id)
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
        FavouritesView()
    }
}
