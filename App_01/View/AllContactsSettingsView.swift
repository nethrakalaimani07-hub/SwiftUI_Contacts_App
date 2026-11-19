//
//  AllContactsSettingsView.swift
//  App_01
//
//  Created by Nethra Kalaimani on 03/11/26.
//


import SwiftUI

struct AllContactsSettingsView: View {

    @AppStorage("allContacts.tapAction") private var tapAction: RowTapAction = .showDetails
    @AppStorage("allContacts.doubleTapAction") private var doubleTapAction: RowTapAction = .copyPhoneNumber
    @AppStorage("allContacts.longPressAction") private var longPressAction: RowTapAction = .showPreview
    
    @AppStorage("allContacts.showAvatar") private var showAvatar = true
    @AppStorage("allContacts.showPhoneText") private var showPhoneText = true
    @AppStorage("allContacts.showFavouriteButton") private var showFavouriteButton = true
    @AppStorage("allContacts.showCallButton") private var showCallButton = true
    @AppStorage("allContacts.showEmailButton") private var showEmailButton = false


    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = AppTheme.classic.rawValue

    @State private var showingResetConfirmation = false

    var body: some View {
        Form {
            Section {
                actionPicker("Tap", selection: $tapAction)
            } header: {
                Text("When you tap a contact row")
            } footer: {
                Text("By default this opens the contact's details page.")
            }

            Section {
                actionPicker("Double Tap", selection: $doubleTapAction)
            } header: {
                Text("When you double tap a contact row")
            } footer: {
                Text("By default this copies the contact's phone number.")
            }

            Section {
                actionPicker("Long Press", selection: $longPressAction)
            } header: {
                Text("When you long press a contact row")
            } footer: {
                Text("By default this shows a menu of the contact's phone numbers and emails.")
            }

            Section {
                NavigationLink {
                    AllContactsRowSettingsView()
                } label: {
                    Text("Choose What Shows in Each Row")
                }
            } footer: {
                Text("Pick which details and buttons appear, like the profile photo, phone number, or call button.")
            }

            Section {
                Button(role: .destructive) {
                    showingResetConfirmation = true
                } label: {
                    Text("Reset to Default")
                }
            }
        }
        .navigationTitle("All Contacts Settings")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.customAppBackground)
        .tint(Color.appPrimary)
        .confirmationDialog(
            "Reset All Contacts settings?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset to Default", role: .destructive) {
                resetToDefault()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This puts every tap, double tap, long press, and row layout choice back to default.")
        }
    }

    // back to default values
    private func resetToDefault() {
        tapAction = .showDetails
        doubleTapAction = .copyPhoneNumber
        longPressAction = .showPreview

        showAvatar = true
        showPhoneText = true
        showFavouriteButton = true
        showCallButton = true
        showEmailButton = false
    }

    private func actionPicker(_ title: String, selection: Binding<RowTapAction>) -> some View {
        Picker(title, selection: selection) {
            ForEach(RowTapAction.allCases, id: \.self) { action in
                Text(action.rawValue).tag(action)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllContactsSettingsView()
    }
}
