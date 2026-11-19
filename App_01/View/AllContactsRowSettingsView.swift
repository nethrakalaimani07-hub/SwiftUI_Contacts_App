//
//  AllContactsRowSettingsView.swift
//  App_01
//

import SwiftUI

struct AllContactsRowSettingsView: View {

    @AppStorage("allContacts.showAvatar") private var showAvatar = true
    @AppStorage("allContacts.showPhoneText") private var showPhoneText = true
    @AppStorage("allContacts.showFavouriteButton") private var showFavouriteButton = true
    @AppStorage("allContacts.showCallButton") private var showCallButton = true
    @AppStorage("allContacts.showEmailButton") private var showEmailButton = false

    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = AppTheme.classic.rawValue

    var body: some View {
        Form {
            Section {
                samplePreviewRow
            } header: {
                Text("Preview")
            } footer: {
                Text("This is a sample row using made-up contact info, so you can see your changes without affecting real contacts.")
            }
            
            Section {
                checkboxRow("Profile Photo", isOn: $showAvatar)
                checkboxRow("Phone Number Text", isOn: $showPhoneText)
                checkboxRow("Favourite Star", isOn: $showFavouriteButton)
                checkboxRow("Call Button", isOn: $showCallButton)
                checkboxRow("Email Button", isOn: $showEmailButton)
            } header: {
                Text("Show in Each Row")
            }
        }
        .navigationTitle("Row Layout")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.customAppBackground)
        .tint(Color.appPrimary)
    }

    private var samplePreviewRow: some View {
        HStack {
            ContactRowInfo(
                name: "Nethra K",
                phone: "+91 98765 43210",
                initials: "NK",
                profileImageData: nil,
                showAvatar: showAvatar,
                showPhoneText: showPhoneText
            )
            
            Spacer()
            
            if showFavouriteButton {
                FavouriteButton(isFavourite: true) {}
            }
            
            if showCallButton {
                ContactChoiceButton(options: ["+91 98765 43210"]) { _ in } label: {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(Color.customAvatarText)
                        .padding(8)
                        .background(Color.appPrimary)
                        .clipShape(Circle())
                }
            }
            
            if showEmailButton {
                ContactChoiceButton(options: ["nethra.k@example.com"]) { _ in } label: {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(Color.customAvatarText)
                        .padding(8)
                        .background(Color.appPrimary)
                        .clipShape(Circle())
                }
            }
        }
        .allowsHitTesting(false)
    }

    // One checklist row. Tapping it toggles the box on or off.
    private func checkboxRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(Color.appText)
                Spacer()
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(isOn.wrappedValue ? Color.appPrimary : Color.appSecondaryText)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AllContactsRowSettingsView()
    }
}
