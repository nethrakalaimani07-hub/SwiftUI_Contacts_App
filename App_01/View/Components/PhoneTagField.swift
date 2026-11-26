//
//  PhoneTagField.swift
//  App_01
//


import SwiftUI
import SwiftData

struct PhoneTagField: View {
    @Binding var tagID: UUID?
    
    @Environment(ContactViewModel.self) private var viewModel
    @State private var showingTagPicker = false
    
    @Query private var tags: [ContactTag]
    
    private var selectedTagName: String {
        viewModel.getTagbyId(withID: tagID, tags: tags)?.tagName ?? "No Tag"
    }
    
    var body: some View {
        Button {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            showingTagPicker = true
        } label: {
            HStack(spacing: 6) {
                Text("Tag:")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryText)
                
                Text(selectedTagName)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.appPrimary)
                
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.appSecondaryText)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingTagPicker) {
            PhoneTagPickerSheet(selectedTagID: $tagID)
                .presentationDetents([.medium, .large])
        }
    }
}


private struct PhoneTagPickerSheet: View {
    @Binding var selectedTagID: UUID?
    
    @Environment(ContactViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query private var contacts: [Contact]
    @Query private var tags: [ContactTag]
    
    private enum EditorMode: Equatable {
        case creating
        case renaming(ContactTag)
    }
    
    @State private var editorMode: EditorMode?
    @State private var tagNameInput = ""
    @State private var tagNameError: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    noTagRow
                    
                    Divider()
                        .overlay(Color.appSecondaryText.opacity(0.2))
                        .padding(.leading, 16)
                    
                    ForEach(tags) { tag in
                        tagRow(for: tag)
                        
                        Divider()
                            .overlay(Color.appSecondaryText.opacity(0.2))
                            .padding(.leading, 16)
                    }
                    
                    if editorMode == .creating {
                        TagEditorRow(
                            text: $tagNameInput,
                            errorMessage: $tagNameError,
                            confirmTitle: "Add"
                        ) {
                            confirmCreate()
                        } onCancel: {
                            cancelEditing()
                        }
                    } else {
                        Button {
                            beginCreating()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(Color.appPrimary)
                                
                                Text("Custom")
                                    .foregroundStyle(Color.appPrimary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .background(Color.customAppBackground)
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .tint(Color.appPrimary)
        }
        .onDisappear {
            try? context.save()
        }
    }
    
    private var noTagRow: some View {
        TagPickerRow(name: "No Tag", isSelected: selectedTagID == nil) {
            selectedTagID = nil
            dismiss()
        }
    }
    
    @ViewBuilder
    private func tagRow(for tag: ContactTag) -> some View {
        
        if let editorMode,
           case .renaming(let renamingTag) = editorMode,
           renamingTag.id == tag.id {
            
            TagEditorRow(
                text: $tagNameInput,
                errorMessage: $tagNameError,
                confirmTitle: "Save"
            ) {
                confirmRename(for: tag)
            } onCancel: {
                cancelEditing()
            }
            
        } else {
            
            TagPickerRow(
                name: tag.tagName,
                isSelected: selectedTagID == tag.id
            ) {
                selectedTagID = tag.id
                dismiss()
            }
            .contextMenu {
                Button {
                    beginRenaming(tag)
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    if selectedTagID == tag.id {
                        selectedTagID = nil
                    }
                    
                    viewModel.deleteTag(tag: tag, in: contacts, context: context)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    private func beginCreating() {
        editorMode = .creating
        tagNameInput = ""
        tagNameError = nil
    }
    
    private func beginRenaming(_ tag: ContactTag) {
        editorMode = .renaming(tag)
        tagNameInput = tag.tagName
        tagNameError = nil
    }
    
    private func cancelEditing() {
        editorMode = nil
        tagNameInput = ""
        tagNameError = nil
    }
    
    private func confirmCreate() {
        let trimmedName = tagNameInput.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else {
            tagNameError = "Enter a tag name."
            return
        }
        
        if let existingTag = tags.first(where: {
            $0.tagName.caseInsensitiveCompare(trimmedName) == .orderedSame
        }) {
            tagNameError = "\"\(existingTag.tagName)\" already exists."
            return
        }
        
        let newTag = viewModel.addTag(name: trimmedName, tags: tags, context: context)
        selectedTagID = newTag.id
        cancelEditing()
        dismiss()
    }
    
    private func confirmRename(for tag: ContactTag) {
        let trimmedName = tagNameInput.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else {
            tagNameError = "Enter a tag name."
            return
        }
        
        if let existingTag = tags.first(where: {
            $0.id != tag.id && $0.tagName.caseInsensitiveCompare(trimmedName) == .orderedSame
        }) {
            tagNameError = "\"\(existingTag.tagName)\" already exists."
            return
        }
        
        viewModel.renameTag(id: tag.id, to: trimmedName, tags: tags, context: context)
        
        cancelEditing()
    }
    
    private struct TagPickerRow: View {
        let name: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(name)
                        .font(.body)
                        .foregroundStyle(Color.appText)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct TagEditorRow: View {
        @Binding var text: String
        @Binding var errorMessage: String?
        let confirmTitle: String
        let onConfirm: () -> Void
        let onCancel: () -> Void
        
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    TextField("Tag name", text: $text)
                        .focused($isFocused)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit(onConfirm)
                        .foregroundStyle(Color.appText)
                        .tint(Color.appPrimary)
                        .padding(10)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    errorMessage == nil ? Color.appSecondaryText.opacity(0.35) : Color.red,
                                    lineWidth: 1
                                )
                        }
                        .onChange(of: text) {
                            errorMessage = nil
                        }
                    
                    Button(confirmTitle, action: onConfirm)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appPrimary)
                    
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(Color.appSecondaryText)
                }
                
                FormErrorText(message: errorMessage)
            }
            .padding(16)
            .onAppear {
                isFocused = true
            }
        }
    }
}
