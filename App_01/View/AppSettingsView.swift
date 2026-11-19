//
//  AppSettingsView.swift
//  App_01
//


import SwiftUI

struct AppSettingsView: View {

    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = AppTheme.classic.rawValue

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRawValue) ?? .classic
    }

    var body: some View {
        Form {
            Section {
                samplePreviewRow
            } header: {
                Text("Preview")
            } footer: {
                Text("This is a sample row using made-up contact info, so you can see what the selected theme looks like.")
            }

            Section {
                ForEach(AppTheme.allCases) { theme in
                    Button {
                        withAnimation {
                            selectedThemeRawValue = theme.rawValue
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(Color(theme.secondaryColorName))
                                .frame(width: 22, height: 22)

                            Text(theme.displayName)
                                .foregroundStyle(Color.appText)

                            Spacer()

                            if theme == selectedTheme {
                                Image(systemName: "checkmark")
                                    .font(.body.bold())
                                    .foregroundStyle(Color.appPrimary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.appSurface)
                }
            } header: {
                Text("Theme")
            } footer: {
                Text("Pick the colors used throughout the app.")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.customAppBackground)
        .tint(Color.appPrimary)
        .id(selectedThemeRawValue)
    }


    // A mock contact row - dynamically changes
    private var samplePreviewRow: some View {
        HStack {
            ContactRowInfo(
                name: "Nethra K",
                phone: "+91 98765 43210",
                initials: "NK",
                profileImageData: nil,
                showAvatar: true,
                showPhoneText: true
            )

            Spacer()

            FavouriteButton(isFavourite: true) {}

            ContactChoiceButton(options: ["+91 98765 43210"]) { _ in } label: {
                Image(systemName: "phone.fill")
                    .foregroundStyle(Color.customAvatarText)
                    .padding(8)
                    .background(Color.appPrimary)
                    .clipShape(Circle())
            }
        }
        .allowsHitTesting(false)
        .listRowBackground(Color.appSurface)
    }
}

#Preview {
    NavigationStack {
        AppSettingsView()
    }
}
