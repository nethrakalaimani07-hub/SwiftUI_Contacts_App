//
//  AddNewContactView.swift
//  App_01
//
//  Created by Nethra Kalaimani on 23/10/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct AddNewContactView: View {
    
    @Environment(\.modelContext) private var context

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var address = ""
    @State private var note = ""
    @State private var isFavourite = false

    @State private var birthday: Date?

    @State private var phoneEntries: [PhoneEntryInput] = [PhoneEntryInput()]
    @State private var additionalEmails: [String] = []

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImageData: Data?

    @State private var firstNameError: String?
    @State private var emailError: String?

    @State private var showingDiscardConfirmation = false

    @Environment(ContactViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = AppTheme.classic.rawValue
    
    private var initialsPreview: String {
        let initials = String.contactInitials(firstName: firstName, lastName: lastName)
        return initials.isEmpty ? "?" : initials
    }

    private var hasUnsavedChanges: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty ||
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty ||
        !email.trimmingCharacters(in: .whitespaces).isEmpty ||
        !address.trimmingCharacters(in: .whitespaces).isEmpty ||
        !note.trimmingCharacters(in: .whitespaces).isEmpty ||
        birthday != nil ||
        isFavourite ||
        profileImageData != nil ||
        phoneEntries.count > 1 ||
        phoneEntries.contains { entry in
            entry.countryCode.trimmingCharacters(in: .whitespaces) != "+91" ||
            !entry.number.trimmingCharacters(in: .whitespaces).isEmpty ||
            entry.tagID != nil
        } ||
        additionalEmails.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    Spacer()
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing){
                            
                            ContactAvatar(imageData: profileImageData, initials: initialsPreview, size: 100)
                            ZStack {
                                Circle()
                                    .fill(Color.appSurface)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.appPrimary)
                            }
                            .frame(width: 36, height: 36)
                            .overlay {
                                Circle()
                                    .stroke(Color.customAppBackground, lineWidth: 3)
                            }
                        }
                    }
    
                    Spacer()
                }
                .onChange(of: selectedPhotoItem) {
                    Task {
                        if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                            profileImageData = data
                        }
                    }
                }
                
                LabeledFormField(
                    label: "First Name",
                    placeholder: "e.g. Nethra",
                    text: $firstName,
                    errorMessage: firstNameError
                )
                .onChange(of: firstName) {
                    firstNameError = firstName.isValidName ? nil : "First name is required."
                }
                
                LabeledFormField(
                    label: "Last Name (optional)",
                    placeholder: "e.g. K",
                    text: $lastName
                )
                
                PhoneEntriesEditor(entries: $phoneEntries)
                
                LabeledFormField(
                    label: "Email (optional)",
                    placeholder: "e.g. nethra@mail.com",
                    text: $email,
                    errorMessage: emailError,
                    keyboardType: .emailAddress,
                    autoCaptilization: .never
                )
                .onChange(of: email) {
                    emailError = email.isValidEmail ? nil : "Enter a valid email address."
                }
                
                AdditionalFieldsList(
                    title: "Add another email",
                    fieldLabel: "Email",
                    placeholder: "Another email",
                    entries: $additionalEmails,
                    keyboardType: .emailAddress,
                    validate: { text in
                        text.isValidEmail ? nil : "Enter a valid email address."
                    }
                )
                
                LabeledFormField(
                    label: "Address (optional)",
                    placeholder: "e.g. 12 MG Road, Chennai",
                    text: $address
                )
                
                BirthdayField(birthday: $birthday)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Note (optional)")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.appSecondaryText)
                    
                    TextEditor(text: $note)
                        .font(.body)
                        .foregroundStyle(Color.appText)
                        .tint(Color.appPrimary)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .frame(height: 100)
                        .background(
                            Color.appSurface,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.appSecondaryText.opacity(0.3),
                                    lineWidth: 1
                                )
                        }
                }
                
                Toggle(isOn: $isFavourite) {
                    Text("Mark as Favourite")
                        .foregroundStyle(Color.appText)
                }
                .tint(Color.appPrimary)
                
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.customAppBackground)
        .navigationTitle("New Contact")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    if hasUnsavedChanges {
                        showingDiscardConfirmation = true
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
            }
        }
        .tint(Color.appPrimary)
        .alert(
            "Discard this contact?",
            isPresented: $showingDiscardConfirmation
        ) {
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. If you discard now, they will be lost.")
        }
    }

    private func validate() -> Bool {
        var isValid = true

        if !firstName.isValidName {
            firstNameError = "First name is required."
            isValid = false
        }

        for index in phoneEntries.indices {
            let entry = phoneEntries[index]

            if !entry.countryCode.isValidCountryCode {
                phoneEntries[index].countryCodeError = "Enter a valid country code, e.g. +91."
                isValid = false
            }

            let numberIsEmpty = entry.number.trimmingCharacters(in: .whitespaces).isEmpty

            if index == 0 && numberIsEmpty {
                phoneEntries[index].numberError = "Phone number is required."
                isValid = false
            } else if !numberIsEmpty && !entry.number.isValidPhoneNumber {
                phoneEntries[index].numberError = "Enter a valid phone number (exactly 10 digits)."
                isValid = false
            }
        }

        if !email.isValidEmail {
            emailError = "Enter a valid email address."
            isValid = false
        }

        return isValid
    }
    
    private func buildPhoneEntries() -> [PhoneEntry] {
        phoneEntries.compactMap { entry in
            let trimmedNumber = entry.number.trimmingCharacters(in: .whitespaces)
            guard !trimmedNumber.isEmpty else { return nil }

            let fullNumber = "\(entry.countryCode.trimmingCharacters(in: .whitespaces)) \(trimmedNumber)"
            return PhoneEntry(number: fullNumber, tagID: entry.tagID)
        }
    }

    private func save() {
        guard validate() else { return }

        do {
            let newContact = try viewModel.addContact(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : lastName,
                phoneEntries: buildPhoneEntries(),
                email: email.trimmingCharacters(in: .whitespaces).isEmpty ? nil : email,
                address: address.trimmingCharacters(in: .whitespaces).isEmpty ? nil : address,
                note: note.trimmingCharacters(in: .whitespaces).isEmpty ? nil : note,
                birthday: birthday ?? nil,
                additionalEmails: additionalEmails.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
                profileImageData: profileImageData,
                isFavourite: isFavourite
            )
            context.insert(newContact)
        } catch {
            print("Failed to save contact: \(error)")
        }
        
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddNewContactView()
            .environment(ContactViewModel())
    }
}
