//
//  FavoritesSettingsView.swift
//  App_01
//
//  Created by Nethra Kalaimani on 03/11/26.
//

import SwiftUI

struct FavouritesSettingsView: View {

    @AppStorage("favourites.tapAction") private var tapAction: RowTapAction = .call
    @AppStorage("favourites.doubleTapAction") private var doubleTapAction: RowTapAction = .copyPhoneNumber
    @AppStorage("favourites.longPressAction") private var longPressAction: RowTapAction = .showPreview


    @AppStorage("favourites.showAvatar") private var showAvatar = true
    @AppStorage("favourites.showPhoneText") private var showPhoneText = true
    @AppStorage("favourites.showFavouriteButton") private var showFavouriteButton = true
    @AppStorage("favourites.showCallButton") private var showCallButton = true
    @AppStorage("favourites.showEmailButton") private var showEmailButton = false

    @State private var showingResetConfirmation = false

    var body: some View {
        Form {
            Section {
                actionPicker("Tap", selection: $tapAction)
            } header: {
                Text("When you tap a contact row")
            } footer: {
                Text("By default this calls the contact's primary phone number.")
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
                    FavouritesRowSettingsView()
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
        .navigationTitle("Favourites Settings")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.customAppBackground)
        .tint(Color.appPrimary)
        .confirmationDialog(
            "Reset Favourites settings?",
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

   
    private func resetToDefault() {
        tapAction = .call
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
        FavouritesSettingsView()
    }
}
