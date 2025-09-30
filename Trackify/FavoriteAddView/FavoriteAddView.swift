
import SwiftUI

@available(iOS 14.0, *)
struct FavoriteAddView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var store: AppDataManager

    @State private var ownerIdText: String = ""
    @State private var itemType: String = ""
    @State private var itemIdText: String = ""
    @State private var notes: String = ""
    @State private var tagsCSV: String = ""
    @State private var priorityText: String = "1"
    @State private var isPinned: Bool = false
    @State private var orderIndexText: String = "0"
    @State private var category: String = ""
    @State private var folder: String = ""
    @State private var sharedWithCSV: String = ""
    @State private var colorCode: String = "#00A3FF"
    @State private var isArchived: Bool = false
    @State private var visibility: String = "Private"
    @State private var reminderDate = Date()
    @State private var reminderEnabled = false
    @State private var expirationDate = Date()
    @State private var expirationEnabled = false
    @State private var referenceLinksCSV: String = ""
    @State private var versionText: String = "1"
    @State private var favoriteGroup: String = ""
    @State private var isTemporary: Bool = false
    @State private var createdBy: String = ""
    @State private var modifiedBy: String = ""
    @State private var deleted: Bool = false
    @State private var iconName: String = "star.fill"
    @State private var shortcutKey: String = ""
    @State private var aliasName: String = ""
    @State private var detailDescription: String = ""

    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        ScrollView {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.accentColor.opacity(0.15), Color.blue.opacity(0.10)]),
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create Favorite")
                            .font(.title2).bold()
                        Text("Add a rich, fully detailed favorite item.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .padding()

            FavoriteAddSectionHeaderView(title: "Identity", systemImage: "person.crop.circle", color: .accentColor)
            Group {
                FavoriteAddFieldView(title: "Owner ID (UUID)", systemImage: "person.fill", text: $ownerIdText, keyboard: .default)
                FavoriteAddFieldView(title: "Item Type", systemImage: "tag.fill", text: $itemType)
                HStack(spacing: 12) {
                    FavoriteAddFieldView(title: "Item ID (UUID)", systemImage: "number", text: $itemIdText)
                }
                FavoriteAddFieldView(title: "Alias Name", systemImage: "pencil.and.outline", text: $aliasName)
                FavoriteAddFieldView(title: "Icon (SF Symbol)", systemImage: "star.fill", text: $iconName)
            }

            FavoriteAddSectionHeaderView(title: "Classification", systemImage: "square.grid.2x2.fill", color: .pink)
            Group {
                FavoriteAddFieldView(title: "Category", systemImage: "folder.fill", text: $category)
                FavoriteAddFieldView(title: "Folder", systemImage: "folder", text: $folder)
                FavoriteAddFieldView(title: "Favorite Group", systemImage: "rectangle.3.group.fill", text: $favoriteGroup)
                FavoriteAddFieldView(title: "Visibility (Private/Public)", systemImage: "eye.fill", text: $visibility)
                FavoriteAddToggleView(title: "Pinned", systemImage: "pin.fill", value: $isPinned)
                FavoriteAddToggleView(title: "Archived", systemImage: "archivebox.fill", value: $isArchived)
                FavoriteAddToggleView(title: "Temporary", systemImage: "clock.fill", value: $isTemporary)
                FavoriteAddToggleView(title: "Deleted", systemImage: "trash.fill", value: $deleted)
                HStack {
                    FavoriteAddFieldView(title: "Priority (0-3)", systemImage: "exclamationmark.circle.fill", text: $priorityText, keyboard: .numberPad)
                }
                HStack {
                    FavoriteAddFieldView(title: "Order Index", systemImage: "list.number", text: $orderIndexText, keyboard: .numberPad)
                    FavoriteAddFieldView(title: "Version", systemImage: "number.square.fill", text: $versionText, keyboard: .numberPad)
                }
            }

            FavoriteAddSectionHeaderView(title: "Collaboration", systemImage: "person.2.fill", color: .green)
            Group {
                FavoriteAddFieldView(title: "Shared With (comma-separated emails)", systemImage: "envelope.fill", text: $sharedWithCSV, keyboard: .emailAddress)
                FavoriteAddFieldView(title: "Tags (comma-separated)", systemImage: "number", text: $tagsCSV)
                FavoriteAddFieldView(title: "Reference Links (comma-separated URLs)", systemImage: "link", text: $referenceLinksCSV, keyboard: .URL)
                FavoriteAddFieldView(title: "Created By", systemImage: "person.crop.circle.badge.plus", text: $createdBy)
                FavoriteAddFieldView(title: "Modified By", systemImage: "person.crop.circle.badge.checkmark", text: $modifiedBy)
                FavoriteAddFieldView(title: "Shortcut Key", systemImage: "keyboard", text: $shortcutKey)
            }

            FavoriteAddSectionHeaderView(title: "Schedule", systemImage: "calendar.badge.clock", color: .orange)
            FavoriteAddDatePickerView(title: "Reminder Date", systemImage: "bell.badge.fill", date: $reminderDate, optional: true, isEnabled: $reminderEnabled)
            FavoriteAddDatePickerView(title: "Expiration Date", systemImage: "hourglass", date: $expirationDate, optional: true, isEnabled: $expirationEnabled)

            FavoriteAddSectionHeaderView(title: "Appearance & Content", systemImage: "paintbrush.pointed.fill", color: .purple)
            Group {
                FavoriteAddFieldView(title: "Color Hex (e.g. #00A3FF)", systemImage: "eyedropper.halffull", text: $colorCode, keyboard: .URL)
                FavoriteAddFieldView(title: "Notes (short)", systemImage: "note.text", text: $notes)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.below.ecg.fill")
                            .foregroundColor(.accentColor)
                        Text("Detailed Description")
                            .font(.subheadline).bold()
                    }.padding(.horizontal)
                    TextEditor(text: $detailDescription)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
                        .padding(.horizontal)
                }
                .padding(.vertical, 6)
            }

            Button(action: { onSubmit() }) {
                HStack {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Save Favorite")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                .foregroundColor(.white)
                .padding(.horizontal)
                .shadow(color: Color.accentColor.opacity(0.25), radius: 8, x: 0, y: 6)
            }
            .padding(.vertical)
        }
        .navigationBarTitle("New Favorite", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Favorite"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK"), action: {
                    if alertMessage.hasPrefix("Saved") {
                        presentationMode.wrappedValue.dismiss()
                    }
                  }))
        }
        .accessibilityElement(children: .contain)
    }

    private func onSubmit() {
        var errors: [String] = []
        
        // Validation
        let ownerId = UUID(uuidString: ownerIdText) ?? UUID()
        if UUID(uuidString: ownerIdText) == nil { errors.append("Owner ID must be a valid UUID.") }
        
        let itemId = UUID(uuidString: itemIdText) ?? UUID()
        if UUID(uuidString: itemIdText) == nil { errors.append("Item ID must be a valid UUID.") }
        
        if !["Private","Public"].contains(visibility) { errors.append("Visibility must be 'Private' or 'Public'.") }
        
        let priority = Int(priorityText) ?? -1
        if !(0...3).contains(priority) { errors.append("Priority must be 0–3.") }
        
        let orderIndex = Int(orderIndexText) ?? -1
        if orderIndex < 0 { errors.append("Order Index must be 0 or greater.") }
        
        let version = Int(versionText) ?? 0
        if version <= 0 { errors.append("Version must be a positive integer.") }
        
        if !colorCode.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
            errors.append("Color must start with # (e.g. #00A3FF).")
        }
        
        if itemType.isEmpty { errors.append("Item Type is required.") }
        if aliasName.isEmpty { errors.append("Alias Name is required.") }
        if iconName.isEmpty { errors.append("Icon (SF Symbol) is required.") }
        if createdBy.isEmpty { errors.append("Created By is required.") }
        if modifiedBy.isEmpty { errors.append("Modified By is required.") }
        if category.isEmpty { errors.append("Category is required.") }
        if detailDescription.count < 10 { errors.append("Description must be at least 10 characters.") }
        
        if !errors.isEmpty {
            alertMessage = "Please fix the following:\n• " + errors.joined(separator: "\n• ")
            showAlert = true
            return
        }
        
        // Create Favorite
        let favorite = Favorite(
            id: UUID(),
            ownerId: ownerId,
            itemType: itemType,
            itemId: itemId,
            createdAt: Date(),
            notes: notes,
            tags: tagsCSV.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            priority: priority,
            isPinned: isPinned,
            orderIndex: orderIndex,
            lastAccessed: Date(),
            timesOpened: 0,
            category: category,
            folder: folder,
            sharedWith: sharedWithCSV.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            colorCode: colorCode,
            isArchived: isArchived,
            visibility: visibility,
            reminderDate: reminderEnabled ? reminderDate : nil,
            expirationDate: expirationEnabled ? expirationDate : nil,
            referenceLinks: referenceLinksCSV.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            version: version,
            favoriteGroup: favoriteGroup,
            isTemporary: isTemporary,
            createdBy: createdBy,
            modifiedBy: modifiedBy,
            deleted: deleted,
            iconName: iconName,
            shortcutKey: shortcutKey,
            aliasName: aliasName,
            description: detailDescription
        )
        
        store.addFavorite(favorite)
        alertMessage = "Saved successfully!"
        showAlert = true
    }
}
