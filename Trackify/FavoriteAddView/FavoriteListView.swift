
import SwiftUI

@available(iOS 14.0, *)
struct FavoriteListView: View {
    @ObservedObject var store: AppDataManager
    @State private var search: String = ""
    @State private var showAddLink: Bool = false

    private var filtered: [Favorite] {
        if search.isEmpty { return store.favorites }
        return store.favorites.filter { fav in
            let hay = [
                fav.aliasName, fav.itemType, fav.category, fav.folder, fav.favoriteGroup,
                fav.visibility, fav.description, fav.notes, fav.tags.joined(separator: ","),
                fav.sharedWith.joined(separator: ","), fav.referenceLinks.joined(separator: ",")
            ].joined(separator: " ").lowercased()
            return hay.contains(search.lowercased())
        }
    }

    var body: some View {
            VStack(spacing: 0) {
                
                FavoriteSearchBarView(text: $search)

                if filtered.isEmpty {
                    FavoriteNoDataView()
                    Spacer()
                } else {
                    List {
                        NavigationLink(destination: FavoriteAddView(store: store), isActive: $showAddLink) { EmptyView() }.hidden()

                        ForEach(filtered) { fav in
                            NavigationLink(destination: FavoriteDetailView(favorite: fav)) {
                                FavoriteListRowView(favorite: fav)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                    .listRowBackground(Color.clear)
                            }
                            .accessibility(label: Text("Favorite \(fav.aliasName.isEmpty ? fav.itemType : fav.aliasName)"))
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("Favorites", displayMode: .large)
            .navigationBarItems(trailing:
                Button(action: { showAddLink = true }) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .accessibility(label: Text("Add Favorite"))
                }
            )
        
    }

    private func delete(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filtered[$0].id }
        if store.favorites.firstIndex(where: { idsToDelete.contains($0.id) }) != nil {
            store.favorites.removeAll { idsToDelete.contains($0.id) }
            store.objectWillChange.send()
        }
    }
}

@available(iOS 14.0, *)
struct FavoriteListRowView: View {
    let favorite: Favorite

    private var accent: Color {
        Color(hex: favorite.colorCode)
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // HEADER
            headerSection

            Divider().padding(.vertical, 4)

            // BADGES
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        badge(icon: "flag.fill", color: .red, title: "Priority", value: "\(favorite.priority)")
                        badge(icon: "folder.fill", color: .blue, title: "Folder", value: favorite.folder)
                    }
                    HStack(spacing: 12) {
                        badge(icon: "person.3.fill", color: .purple, title: "Shared", value: "\(favorite.sharedWith.count)")
                        badge(icon: "number.circle.fill", color: .orange, title: "Version", value: "\(favorite.version)")
                    }
                    HStack(spacing: 12) {
                        badge(icon: "clock.fill", color: .blue, title: "Opened", value: "\(favorite.timesOpened)x")
                        badge(icon: "square.stack.fill", color: .pink, title: "Group", value: favorite.favoriteGroup)
                    }
                }
            

            // EXTRA DATA (Links + Shortcut)
            extraSection

            // TAGS
            if !favorite.tags.isEmpty {
                tagSection
            }

            // NOTES & DESCRIPTION
            if !favorite.notes.isEmpty || !favorite.description.isEmpty {
                noteSection
            }

            Divider().padding(.vertical, 4)

            // FOOTER
            footerSection
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [accent.opacity(0.08), Color(UIColor.systemBackground)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(accent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: accent.opacity(0.15), radius: 6, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    // MARK: Header
    private var headerSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(accent.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: favorite.iconName)
                        .foregroundColor(accent)
                        .font(.title3)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(favorite.aliasName.isEmpty ? favorite.itemType : favorite.aliasName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if favorite.isPinned { Image(systemName: "pin.fill").foregroundColor(.orange) }
                    if favorite.visibility == "Public" { Image(systemName: "globe").foregroundColor(.green) }
                    if favorite.isArchived { Image(systemName: "archivebox.fill").foregroundColor(.gray) }
                    if favorite.isTemporary { Image(systemName: "hourglass").foregroundColor(.yellow) }
                }
                Text(favorite.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("#\(favorite.orderIndex)")
                .font(.caption)
                .padding(6)
                .background(accent.opacity(0.15))
                .clipShape(Capsule())
                .foregroundColor(accent)
        }
    }

    // MARK: Extra
    private var extraSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !favorite.shortcutKey.isEmpty {
                Label("Shortcut: \(favorite.shortcutKey)", systemImage: "command")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if !favorite.referenceLinks.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Label("Reference Links", systemImage: "link")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(favorite.referenceLinks.prefix(2), id: \.self) { link in
                        Text(link)
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .underline()
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    if favorite.referenceLinks.count > 2 {
                        Text("+\(favorite.referenceLinks.count - 2) more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var tagSection: some View {
        HStack {
            ForEach(favorite.tags.prefix(5), id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.15))
                    .clipShape(Capsule())
                    .foregroundColor(accent)
            }
            if favorite.tags.count > 5 {
                Text("+\(favorite.tags.count - 5) more")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: Notes
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !favorite.notes.isEmpty {
                Label {
                    Text(favorite.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .truncationMode(.tail)
                } icon: {
                    Image(systemName: "note.text").foregroundColor(.secondary)
                }
            }
            if !favorite.description.isEmpty {
                Label {
                    Text(favorite.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .truncationMode(.tail)
                } icon: {
                    Image(systemName: "text.alignleft").foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: Footer
    private var footerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 16) {
                Label("Created: \(dateFormatter.string(from: favorite.createdAt))", systemImage: "calendar")
                    .font(.caption2).foregroundColor(.secondary)
                Label("Last: \(dateFormatter.string(from: favorite.lastAccessed))", systemImage: "clock.arrow.circlepath")
                    .font(.caption2).foregroundColor(.secondary)
            }
            HStack(spacing: 16) {
                Label("By: \(favorite.createdBy)", systemImage: "person.fill")
                    .font(.caption2).foregroundColor(.secondary)
                Label("Mod: \(favorite.modifiedBy)", systemImage: "pencil")
                    .font(.caption2).foregroundColor(.secondary)
            }
            if let reminder = favorite.reminderDate {
                Label("Remind: \(dateFormatter.string(from: reminder))", systemImage: "bell.fill")
                    .font(.caption2).foregroundColor(.secondary)
            }
            if let expiry = favorite.expirationDate {
                Label("Expires: \(dateFormatter.string(from: expiry))", systemImage: "hourglass.bottomhalf.fill")
                    .font(.caption2).foregroundColor(.red)
            }
        }
    }

    // MARK: Badge
    private func badge(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .padding(6)
                .background(color)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption2).foregroundColor(.secondary)
                Text(value).font(.caption).foregroundColor(.primary)
            }
        }.frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
