
import SwiftUI

fileprivate extension Color {
    static let niPrimary = Color(#colorLiteral(red: 0.1176, green: 0.4784, blue: 0.9725, alpha: 1))
    static let niPurple = Color(#colorLiteral(red: 0.556, green: 0.278, blue: 0.988, alpha: 1))
    static let niGreen  = Color(#colorLiteral(red: 0.0, green: 0.725, blue: 0.431, alpha: 1))
    static let niOrange = Color(#colorLiteral(red: 1.0, green: 0.584, blue: 0.0, alpha: 1))
    static let niRed    = Color(#colorLiteral(red: 0.973, green: 0.235, blue: 0.188, alpha: 1))
    static let niCard   = Color(.secondarySystemBackground)
    static let niSeparator = Color.black.opacity(0.06)
}

fileprivate extension DateFormatter {
    static let niDateTime: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    static let niDateOnly: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
}

fileprivate func niFormat(_ date: Date?) -> String {
    guard let d = date else { return "—" }
    return DateFormatter.niDateTime.string(from: d)
}

fileprivate func niJoin(_ array: [String]) -> String {
    array.isEmpty ? "—" : array.joined(separator: ", ")
}

fileprivate func niBoolBadge(_ value: Bool, trueText: String = "Yes", falseText: String = "No") -> some View {
    Text(value ? trueText : falseText)
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(value ? Color.niGreen.opacity(0.15) : Color.niRed.opacity(0.12))
        .foregroundColor(value ? Color.niGreen : Color.niRed)
        .clipShape(Capsule())
}


@available(iOS 14.0, *)
struct NoteItemSearchBarView: View {
    @Binding var text: String
    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.niPrimary)
                TextField("Search title, content, tags, author", text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing = editing
                    }
                })
                .autocapitalization(.none)
                .disableAutocorrection(true)

                if isEditing && !text.isEmpty {
                    Button(action: { self.text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .transition(.scale)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.niCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEditing ? Color.niPrimary.opacity(0.6) : Color.clear, lineWidth: 1)
            )

            if isEditing {
                Button("Cancel") {
                    withAnimation(.spring()) {
                        self.text = ""
                        self.isEditing = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Search notes"))
    }
}

@available(iOS 14.0, *)
struct NoteItemListRowView: View {
    let note: NoteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                ZStack {
                    Circle()
                        .fill(Color.niPrimary.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: note.isPinned ? "pin.fill" : "note.text")
                        .foregroundColor(note.isPinned ? .niOrange : .niPrimary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title.isEmpty ? "Untitled" : note.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        Label(note.category, systemImage: "folder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .labelStyle(IconOnlyLabelStyle()) // we show icon separately below
                        Text(note.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.niPurple.opacity(0.13))
                            .foregroundColor(Color.niPurple)
                            .clipShape(Capsule())
                        Text("v\(note.version)")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.niPrimary.opacity(0.12))
                            .foregroundColor(.niPrimary)
                            .clipShape(Capsule())
                    }
                }
                Spacer()
                niBoolBadge(note.isEncrypted, trueText: "Encrypted", falseText: "Plain")
            }

            // Content preview
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }

            // Rich meta grid (15+ fields summarized)
            let two = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
            LazyVGrid(columns: two, spacing: 8) {
                NoteItemMetaRow(icon: "person.crop.circle", color: .niPrimary, title: "Author", value: note.author)
                NoteItemMetaRow(icon: "highlighter", color: .niPurple, title: "Editor", value: note.lastEditedBy)
                NoteItemMetaRow(icon: "calendar", color: .niGreen, title: "Created", value: niFormat(note.createdAt))
                NoteItemMetaRow(icon: "clock", color: .niGreen, title: "Updated", value: niFormat(note.updatedAt))
                NoteItemMetaRow(icon: "number", color: .niPrimary, title: "Priority", value: "\(note.priority)")
                NoteItemMetaRow(icon: note.isPinned ? "pin.fill" : "pin.slash", color: .niOrange, title: "Pinned", value: note.isPinned ? "Yes" : "No")
                NoteItemMetaRow(icon: "archivebox", color: .niRed, title: "Archived", value: note.isArchived ? "Yes" : "No")
                NoteItemMetaRow(icon: "bell", color: .niOrange, title: "Reminder", value: niFormat(note.reminderDate))
                NoteItemMetaRow(icon: "tag", color: .niPurple, title: "Tags", value: niJoin(note.tags))
                NoteItemMetaRow(icon: "checkmark.seal", color: .niGreen, title: "Checklist", value: note.checklist.isEmpty ? "—" : "\(note.checklist.count) items")
                NoteItemMetaRow(icon: "link", color: .niPrimary, title: "References", value: note.references.isEmpty ? "—" : "\(note.references.count) links")
                NoteItemMetaRow(icon: "paperplane", color: .niGreen, title: "Shared", value: note.sharedWith.isEmpty ? "—" : "\(note.sharedWith.count) people")
                NoteItemMetaRow(icon: "character", color: .niPrimary, title: "Words", value: "\(note.wordCount)")
                NoteItemMetaRow(icon: "textformat", color: .niPrimary, title: "Chars", value: "\(note.charCount)")
                NoteItemMetaRow(icon: "eye", color: .niPurple, title: "Reads", value: "\(note.readCount)")
                NoteItemMetaRow(icon: "folder.fill", color: .niGreen, title: "Folder", value: note.folder)
                NoteItemMetaRow(icon: "paintbrush", color: .niOrange, title: "Theme", value: note.theme)
                NoteItemMetaRow(icon: "hammer", color: .niPurple, title: "Custom", value: note.customFields.isEmpty ? "—" : "\(note.customFields.count) fields")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.niCard)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        )
        .accessibilityElement(children: .combine)
    }
}

@available(iOS 14.0, *)
struct NoteItemMetaRow: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 18)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value.isEmpty ? "—" : value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

@available(iOS 14.0, *)
struct NoteItemNoDataView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(Color.niPrimary.opacity(0.08)).frame(width: 120, height: 120)
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(.niPrimary)
            }
            Text("No Notes Found")
                .font(.headline)
            Text("Try adjusting your search or add a new note with the + button.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("No notes found"))
    }
}

@available(iOS 14.0, *)
struct NoteItemListView: View {
    @ObservedObject var data: AppDataManager
    @State private var searchText = ""

    private var filtered: [NoteItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return data.notes }
        return data.notes.filter { note in
            let hay = [
                note.title,
                note.content,
                note.category,
                note.author,
                note.lastEditedBy,
                note.folder,
                note.theme,
                note.archivedReason
            ].joined(separator: " ").lowercased()
            return hay.contains(q) ||
                   note.tags.joined(separator: " ").lowercased().contains(q) ||
                   note.sharedWith.joined(separator: " ").lowercased().contains(q) ||
                   note.customFields.joined(separator: " ").lowercased().contains(q)
        }
    }

    var body: some View {
            VStack(spacing: 0) {
                NoteItemSearchBarView(text: $searchText)
                if filtered.isEmpty {
                    ScrollView { NoteItemNoDataView() }
                } else {
                    List {
                        ForEach(filtered, id: \.id) { note in
                            ZStack(alignment: .leading) {
                                NavigationLink(destination: NoteItemDetailView(note: note)) {
                                    EmptyView()
                                }
                                .opacity(0)

                                NoteItemListRowView(note: note)
                                    .contentShape(Rectangle())

                            }
                            .listRowBackground(Color.clear)
                            .padding(.vertical, 6)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("Notes", displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: NoteItemAddView(data: data)) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.niPrimary)
                        .accessibilityLabel(Text("Add Note"))
                }
            )
        
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func delete(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filtered[$0].id }
        if let indexes = IndexSet(data.notes.enumerated().compactMap({ idsToDelete.contains($0.element.id) ? $0.offset : nil })) as IndexSet? {
            data.deleteNote(at: indexes)
        }
    }
}

@available(iOS 14.0, *)
struct NoteItemAddSectionHeaderView: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(color))
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }
}

@available(iOS 14.0, *)
struct NoteItemAddFieldView: View {
    let icon: String
    let placeholder: String
    let color: Color
    @Binding var text: String
    var isMultiline: Bool = false

    @State private var isFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                ZStack(alignment: .leading) {
                    // Floating label
                    Text(placeholder)
                        .foregroundColor(isFocused || !text.isEmpty ? color : .secondary)
                        .font(isFocused || !text.isEmpty ? .caption : .subheadline)
                        .offset(y: isFocused || !text.isEmpty ? -16 : 0)
                        .animation(.easeInOut(duration: 0.18))

                    if isMultiline {
                        TextEditor(text: $text)
                            .frame(minHeight: 80, maxHeight: 140)
                            .onTapGesture { withAnimation { isFocused = true } }
                    } else {
                        TextField("", text: $text, onEditingChanged: { editing in
                            withAnimation { isFocused = editing }
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.niCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFocused ? color.opacity(0.6) : Color.niSeparator, lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

@available(iOS 14.0, *)
struct NoteItemAddDatePickerView: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var date: Date?
    @State private var isOn: Bool = false
    @State private var tempDate: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Toggle(title, isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: color))
            }
            .padding(.horizontal)

            if isOn {
                DatePicker("", selection: $tempDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(DefaultDatePickerStyle())
                    .labelsHidden()
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color.niCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.niSeparator, lineWidth: 1)
        )
        .padding(.horizontal)
        .onAppear {
            if let d = date {
                isOn = true
                tempDate = d
            }
        }
        .onChange(of: isOn, perform: { v in
            if v == false { date = nil } else { date = tempDate }
        })
        .onChange(of: tempDate, perform: { d in
            if isOn { date = d }
        })
    }
}

@available(iOS 14.0, *)
struct NoteItemTagChip: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

@available(iOS 14.0, *)
struct NoteItemAddView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var data: AppDataManager

    // Required fields (15+)
    @State private var ownerIdString = ""
    @State private var titleText = ""
    @State private var contentText = ""
    @State private var category = ""
    @State private var priorityText = "1"
    @State private var isPinned = false
    @State private var isArchived = false
    @State private var reminderDate: Date? = nil
    @State private var tagsString = ""
    @State private var checklistString = ""
    @State private var referencesString = ""
    @State private var relatedProjectIdString = ""
    @State private var relatedTaskIdString = ""
    @State private var author = ""
    @State private var lastEditedBy = ""
    @State private var folder = ""
    @State private var theme = ""
    @State private var customFieldsString = ""
    @State private var sharedWithString = ""
    @State private var isEncrypted = false
    @State private var archivedReason = ""

    // Alert
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Basics
                NoteItemAddSectionHeaderView(icon: "sparkles", title: "Basics", color: .niPrimary)
                NoteItemAddFieldView(icon: "person.fill", placeholder: "Owner ID (UUID)", color: .niPrimary, text: $ownerIdString)
                NoteItemAddFieldView(icon: "textformat.size", placeholder: "Title", color: .niPrimary, text: $titleText)
                NoteItemAddFieldView(icon: "doc.text", placeholder: "Content", color: .niPrimary, text: $contentText, isMultiline: true)
                NoteItemAddFieldView(icon: "folder", placeholder: "Category", color: .niPrimary, text: $category)
                NoteItemAddFieldView(icon: "number", placeholder: "Priority (1-5)", color: .niPrimary, text: $priorityText)

                // Flags
                NoteItemAddSectionHeaderView(icon: "flag.fill", title: "Flags", color: .niOrange)
                HStack(spacing: 16) {
                    Toggle(isOn: $isPinned) {
                        Label("Pinned", systemImage: "pin.fill")
                            .foregroundColor(.niOrange)
                    }
                    Toggle(isOn: $isArchived) {
                        Label("Archived", systemImage: "archivebox.fill")
                            .foregroundColor(.niRed)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.niCard))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.niSeparator, lineWidth: 1))
                .padding(.horizontal)

                NoteItemAddDatePickerView(icon: "bell.fill", title: "Add Reminder", color: .niOrange, date: $reminderDate)

                NoteItemAddSectionHeaderView(icon: "link", title: "Relations & Collections", color: .niPurple)
                NoteItemAddFieldView(icon: "number.square", placeholder: "Related Project ID (UUID, optional)", color: .niPurple, text: $relatedProjectIdString)
                NoteItemAddFieldView(icon: "number.square.fill", placeholder: "Related Task ID (UUID, optional)", color: .niPurple, text: $relatedTaskIdString)
                NoteItemAddFieldView(icon: "tag.fill", placeholder: "Tags (comma separated)", color: .niPurple, text: $tagsString)
                NoteItemAddFieldView(icon: "checkmark.seal.fill", placeholder: "Checklist Items (comma separated)", color: .niPurple, text: $checklistString)
                NoteItemAddFieldView(icon: "link.circle.fill", placeholder: "Reference Links (comma separated)", color: .niPurple, text: $referencesString)

                NoteItemAddSectionHeaderView(icon: "person.2.fill", title: "Authorship & Sharing", color: .niGreen)
                NoteItemAddFieldView(icon: "person.crop.circle.fill", placeholder: "Author", color: .niGreen, text: $author)
                NoteItemAddFieldView(icon: "pencil.circle.fill", placeholder: "Last Edited By", color: .niGreen, text: $lastEditedBy)
                NoteItemAddFieldView(icon: "envelope.open.fill", placeholder: "Shared With (emails, comma separated)", color: .niGreen, text: $sharedWithString)
                Toggle(isOn: $isEncrypted) {
                    Label("Encrypted", systemImage: "lock.fill").foregroundColor(.niGreen)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.niCard))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.niSeparator, lineWidth: 1))
                .padding(.horizontal)

                // Organization
                NoteItemAddSectionHeaderView(icon: "square.grid.2x2.fill", title: "Organization & Theme", color: .niPrimary)
                NoteItemAddFieldView(icon: "folder.fill", placeholder: "Folder", color: .niPrimary, text: $folder)
                NoteItemAddFieldView(icon: "paintbrush.fill", placeholder: "Theme", color: .niPrimary, text: $theme)
                NoteItemAddFieldView(icon: "hammer.fill", placeholder: "Custom Fields (comma separated)", color: .niPrimary, text: $customFieldsString)
                NoteItemAddFieldView(icon: "archivebox.fill", placeholder: "Archived Reason (if archived)", color: .niRed, text: $archivedReason)

                // Submit
                Button(action: submit) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Note")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.niPrimary))
                    .foregroundColor(.white)
                }
                .padding(.vertical, 12)
                .accessibilityLabel(Text("Save Note"))
            }
            .padding(.vertical, 12)
        }
        .navigationBarTitle("Add Note", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                if alertTitle == "Success" {
                    presentationMode.wrappedValue.dismiss()
                }
            }))
        }
    }

    private func submit() {
        var errors: [String] = []

        // Validate UUID-like fields
        let ownerId = UUID(uuidString: ownerIdString)
        if ownerId == nil { errors.append("Owner ID must be a valid UUID.") }

        // Required text fields
        if titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors.append("Title is required.") }
        if contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors.append("Content is required.") }
        if category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors.append("Category is required.") }
        if author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors.append("Author is required.") }
        if lastEditedBy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors.append("Last Edited By is required.") }
        if folder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors.append("Folder is required.") }
        if theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors.append("Theme is required.") }

        // Priority range
        guard let priorityVal = Int(priorityText), (1...5).contains(priorityVal) else {
            errors.append("Priority must be a number between 1 and 5.")
            // continue to avoid early exit
            return showErrors(errors)
        }

        // Optional UUIDs
        let relatedProjectId = relatedProjectIdString.isEmpty ? nil : UUID(uuidString: relatedProjectIdString)
        if !relatedProjectIdString.isEmpty && relatedProjectId == nil { errors.append("Related Project ID must be a valid UUID.") }
        let relatedTaskId = relatedTaskIdString.isEmpty ? nil : UUID(uuidString: relatedTaskIdString)
        if !relatedTaskIdString.isEmpty && relatedTaskId == nil { errors.append("Related Task ID must be a valid UUID.") }

        // Parsed arrays
        let tags = splitCSV(tagsString)
        let checklist = splitCSV(checklistString)
        let references = splitCSV(referencesString)
        let sharedWith = splitCSV(sharedWithString)
        let customFields = splitCSV(customFieldsString)

        // 15+ fields required check (show comprehensive errors)
        // We already validated many; enforce at least these non-empty: ownerId, title, content, category, priority, author, lastEditedBy, folder, theme, and lists may be empty but allowed.
        if !errors.isEmpty { return showErrors(errors) }

        // Compute counts
        let wordCount = Self.countWords(in: contentText)
        let charCount = contentText.count

        let now = Date()
        let note = NoteItem(
            id: UUID(),
            ownerId: ownerId!,
            title: titleText,
            content: contentText,
            createdAt: now,
            updatedAt: now,
            tags: tags,
            category: category,
            priority: priorityVal,
            isPinned: isPinned,
            isArchived: isArchived,
            reminderDate: reminderDate,
            checklist: checklist,
            references: references,
            relatedProjectId: relatedProjectId,
            relatedTaskId: relatedTaskId,
            author: author,
            lastEditedBy: lastEditedBy,
            wordCount: wordCount,
            charCount: charCount,
            readCount: 0,
            version: 1,
            sharedWith: sharedWith,
            isEncrypted: isEncrypted,
            folder: folder,
            theme: theme,
            customFields: customFields,
            archivedReason: archivedReason,
            deleted: false
        )

        data.addNote(note)
        alertTitle = "Success"
        alertMessage = "Your note has been saved successfully."
        showAlert = true
    }

    private func showErrors(_ errors: [String]) {
        alertTitle = "Please fix the following"
        alertMessage = "• " + errors.joined(separator: "\n• ")
        showAlert = true
    }

    private func splitCSV(_ s: String) -> [String] {
        s.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private static func countWords(in text: String) -> Int {
        let comps = text.split { !$0.isLetter && !$0.isNumber }
        return comps.count
    }
}

@available(iOS 14.0, *)
struct NoteItemDetailFieldRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundColor(color).frame(width: 18)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text(value.isEmpty ? "—" : value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.niCard))
    }
}


@available(iOS 14.0, *)
struct NoteItemDetailView: View {
    
    var note: NoteItem

    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        ZStack {
                            Circle().fill(Color.niPrimary.opacity(0.15)).frame(width: 44, height: 44)
                            Image(systemName: note.isPinned ? "pin.fill" : "note.text")
                                .foregroundColor(note.isPinned ? .niOrange : .niPrimary)
                                .font(.title3)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title.isEmpty ? "Untitled Note" : note.title)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.primary)
                            HStack(spacing: 8) {
                                Text(note.category)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Color.niPurple.opacity(0.15))
                                    .foregroundColor(.niPurple)
                                    .clipShape(Capsule())
                                Text("v\(note.version)")
                                    .font(.caption2.weight(.semibold))
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.niPrimary.opacity(0.12))
                                    .foregroundColor(.niPrimary)
                                    .clipShape(Capsule())
                                niBoolBadge(note.isArchived, trueText: "Archived", falseText: "Active")
                            }
                        }
                        Spacer()
                    }
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.niCard))
                .padding(.horizontal)

                // Two-column grid for metadata
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 12) {
                        NoteItemDetailFieldRow(icon: "person.crop.circle", title: "Author", value: note.author, color: .niPrimary)
                        NoteItemDetailFieldRow(icon: "highlighter", title: "Last Edited By", value: note.lastEditedBy, color: .niPurple)
                        NoteItemDetailFieldRow(icon: "calendar", title: "Created At", value: niFormat(note.createdAt), color: .niGreen)
                        NoteItemDetailFieldRow(icon: "clock", title: "Updated At", value: niFormat(note.updatedAt), color: .niGreen)
                        NoteItemDetailFieldRow(icon: "number", title: "Priority", value: "\(note.priority)", color: .niPrimary)
                        NoteItemDetailFieldRow(icon: "lock", title: "Encrypted", value: note.isEncrypted ? "Yes" : "No", color: .niGreen)
                        NoteItemDetailFieldRow(icon: "pin", title: "Pinned", value: note.isPinned ? "Yes" : "No", color: .niOrange)
                        NoteItemDetailFieldRow(icon: "archivebox", title: "Archived", value: note.isArchived ? "Yes" : "No", color: .niRed)
                        NoteItemDetailFieldRow(icon: "bell", title: "Reminder", value: niFormat(note.reminderDate), color: .niOrange)
                        NoteItemDetailFieldRow(icon: "eye", title: "Read Count", value: "\(note.readCount)", color: .niPurple)
                        NoteItemDetailFieldRow(icon: "character", title: "Word Count", value: "\(note.wordCount)", color: .niPrimary)
                        NoteItemDetailFieldRow(icon: "textformat", title: "Character Count", value: "\(note.charCount)", color: .niPrimary)
                        NoteItemDetailFieldRow(icon: "folder", title: "Folder", value: note.folder, color: .niGreen)
                        NoteItemDetailFieldRow(icon: "paintbrush", title: "Theme", value: note.theme, color: .niOrange)
                        NoteItemDetailFieldRow(icon: "number.square", title: "Note ID", value: note.id.uuidString, color: .niPrimary)
                        NoteItemDetailFieldRow(icon: "number.square", title: "Owner ID", value: note.ownerId.uuidString, color: .niPrimary)
                        NoteItemDetailFieldRow(icon: "number.square", title: "Related Project", value: note.relatedProjectId?.uuidString ?? "—", color: .niPurple)
                        NoteItemDetailFieldRow(icon: "number.square.fill", title: "Related Task", value: note.relatedTaskId?.uuidString ?? "—", color: .niPurple)
                        NoteItemDetailFieldRow(icon: "exclamationmark.bubble", title: "Archived Reason", value: note.archivedReason.isEmpty ? "—" : note.archivedReason, color: .niRed)
                        NoteItemDetailFieldRow(icon: "key", title: "Deleted Flag", value: note.deleted ? "Yes" : "No", color: .niRed)
                    }
                }
                .padding(.top, 4)

                // Grouped arrays section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Collections")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        if !note.tags.isEmpty {
                            NoteItemCollectionRow(title: "Tags", icon: "tag.fill", color: .niPurple, items: note.tags)
                        } else {
                            NoteItemCollectionRow(title: "Tags", icon: "tag.fill", color: .niPurple, items: [])
                        }
                        NoteItemCollectionRow(title: "Checklist", icon: "checkmark.seal.fill", color: .niGreen, items: note.checklist)
                        NoteItemCollectionRow(title: "References", icon: "link", color: .niPrimary, items: note.references)
                        NoteItemCollectionRow(title: "Shared With", icon: "person.2.fill", color: .niGreen, items: note.sharedWith)
                        NoteItemCollectionRow(title: "Custom Fields", icon: "hammer.fill", color: .niOrange, items: note.customFields)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.niCard))
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }.padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationBarTitle("Note Detail", displayMode: .inline)
    }
}

@available(iOS 14.0, *)
struct NoteItemCollectionRow: View {
    let title: String
    let icon: String
    let color: Color
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                Text(items.isEmpty ? "—" : "\(items.count)")
                    .font(.caption)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(color.opacity(0.12))
                    .foregroundColor(color)
                    .clipShape(Capsule())
            }
            if items.isEmpty {
                Text("No items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                FlexibleWrap(items: items) { item in
                    NoteItemTagChip(text: item, color: color)
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.niCard))
    }
}

@available(iOS 14.0, *)
struct FlexibleWrap<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            self.generate(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generate(in g: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .padding(4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > g.size.width {
                            width = 0
                            height -= d.height
                        }
                        let res = width
                        if item == items.last {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return res
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let res = height
                        if item == items.last {
                            height = 0 // last item
                        }
                        return res
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { gp -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = gp.size.height
            }
            return Color.clear
        }
    }
}


