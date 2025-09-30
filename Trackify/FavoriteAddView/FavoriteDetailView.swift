import SwiftUI

@available(iOS 14.0, *)
struct FavoriteDetailView: View {
    let favorite: Favorite
    @State private var expandedSections: Set<String> = ["Identity", "Classification"] // default open sections
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // HEADER CARD
                VStack(spacing: 12) {
                    Image(systemName: favorite.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: favorite.colorCode))
                        .padding()
                        .background(
                            Circle()
                                .fill(Color(hex: favorite.colorCode).opacity(0.15))
                        )
                    
                    Text(favorite.aliasName)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(favorite.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 8) {
                        if favorite.isPinned {
                            TagBadge(text: "Pinned", color: .yellow, icon: "pin.fill")
                        }
                        if favorite.isArchived {
                            TagBadge(text: "Archived", color: .gray, icon: "archivebox.fill")
                        }
                        if favorite.isTemporary {
                            TagBadge(text: "Temporary", color: .orange, icon: "clock.fill")
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground)) // ✅ iOS 14 safe
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                
                // SECTIONS
                SectionCard(title: "Identity", systemImage: "person.text.rectangle", color: .blue, isExpanded: expandedSections.contains("Identity")) {
                    detailRow("Owner ID", favorite.ownerId.uuidString, "person.fill", .blue)
                    detailRow("Item Type", favorite.itemType, "tag.fill", .pink)
                    detailRow("Item ID", favorite.itemId.uuidString, "number", .blue)
                    detailRow("Shortcut Key", favorite.shortcutKey, "keyboard", .green)

                }
                
                SectionCard(title: "Classification", systemImage: "folder.fill", color: .purple, isExpanded: expandedSections.contains("Classification")) {
                    detailRow("Category", favorite.category, "folder.fill", .purple)
                    detailRow("Folder", favorite.folder, "tray.full.fill", .orange)
                    detailRow("Group", favorite.favoriteGroup, "rectangle.3.group.fill", .green)
                    detailRow("Visibility", favorite.visibility, "eye.fill", .blue)
                    detailRow("Priority", "\(favorite.priority)", "exclamationmark.circle.fill", .red)
                    detailRow("Order Index", "\(favorite.orderIndex)", "list.number", .gray)
                    detailRow("Version", "\(favorite.version)", "number.square.fill", .blue)
                    detailRow("Deleted", favorite.deleted ? "Yes" : "No", "trash.fill", .red)
                }
                
                SectionCard(title: "Collaboration", systemImage: "person.3.fill", color: .green, isExpanded: expandedSections.contains("Collaboration")) {
                    detailRow("Tags", favorite.tags.joined(separator: ", "), "number", .pink)
                    detailRow("Shared With", favorite.sharedWith.joined(separator: ", "), "envelope.fill", .blue)
                    detailRow("Reference Links", favorite.referenceLinks.joined(separator: "\n"), "link", .green)
                    detailRow("Created By", favorite.createdBy, "person.crop.circle.badge.plus", .blue)
                    detailRow("Modified By", favorite.modifiedBy, "person.crop.circle.badge.checkmark", .green)
                }
                
                SectionCard(title: "Timeline & Stats", systemImage: "calendar", color: .orange, isExpanded: expandedSections.contains("Timeline & Stats")) {
                    detailRow("Created At", DateFormatter.favoriteDate.string(from: favorite.createdAt), "calendar", .orange)
                    detailRow("Last Accessed", DateFormatter.favoriteDate.string(from: favorite.lastAccessed), "clock", .blue)
                    detailRow("Times Opened", "\(favorite.timesOpened)x", "chart.bar.xaxis", .purple)
                    detailRow("Reminder Date", favorite.reminderDate.map { DateFormatter.favoriteDate.string(from: $0) } ?? "—", "bell.badge.fill", .red)
                    detailRow("Expiration Date", favorite.expirationDate.map { DateFormatter.favoriteDate.string(from: $0) } ?? "—", "hourglass", .gray)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground)) // ✅ iOS 14 safe
        .navigationBarTitle("Favorite Detail", displayMode: .inline)
    }
    
    // MARK: - Reusable Row
    private func detailRow(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

@available(iOS 14.0, *)
struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    let color: Color
    let isExpanded: Bool
    let content: () -> Content
    
    @State private var expanded: Bool = true
    
    init(title: String, systemImage: String, color: Color, isExpanded: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.isExpanded = isExpanded
        self.content = content
        self._expanded = State(initialValue: isExpanded)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { expanded.toggle() } }) {
                HStack {
                    Image(systemName: systemImage)
                        .foregroundColor(color)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.tertiarySystemBackground)) // ✅ replaced .thinMaterial
            }
            
            if expanded {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .padding(.horizontal)
                .padding(.bottom)
                .background(Color(.secondarySystemBackground)) // ✅ replaced .thinMaterial
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

@available(iOS 14.0, *)
struct TagBadge: View {
    let text: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}

@available(iOS 14.0, *)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

extension DateFormatter {
    static let favoriteDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
}
