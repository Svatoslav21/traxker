
import SwiftUI

@available(iOS 14.0, *)
struct ProjectListView: View {
    @ObservedObject var dataManager: AppDataManager
    @State private var query: String = ""

    private var filteredProjects: [Project] {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return dataManager.projects
        }
        let q = query.lowercased()
        return dataManager.projects.filter { p in
            p.name.lowercased().contains(q) ||
            p.description.lowercased().contains(q) ||
            p.status.lowercased().contains(q) ||
            p.category.lowercased().contains(q) ||
            p.manager.lowercased().contains(q) ||
            p.location.lowercased().contains(q) ||
            p.visibility.lowercased().contains(q) ||
            p.tags.joined(separator: " ").lowercased().contains(q)
        }
    }

    var body: some View {
            VStack(spacing: 8) {
                // Animated Search
                ProjectSearchBarView(query: $query)
                    .padding(.horizontal)

                if filteredProjects.isEmpty {
                    Spacer()
                    ProjectNoDataView()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredProjects, id: \.id) { project in
                            ZStack {
                                NavigationLink(destination: ProjectDetailView(project: project)) {
                                    EmptyView()
                                }
                                .opacity(0)

                                ProjectListRowView(project: project)
                                    .padding(.vertical, 6)
                            }
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            .listRowBackground(Color.clear)
                            .contentShape(Rectangle())
                        }
                        .onDelete(perform: delete(at:))
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("Projects", displayMode: .large)
            .navigationBarItems(trailing:
                NavigationLink(destination: ProjectAddView(dataManager: dataManager)) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .accessibilityLabel(Text("Add Project"))
                }
            )
        
    }

    private func delete(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredProjects[$0].id }
        var deleteOffsets = IndexSet()
        for (idx, item) in dataManager.projects.enumerated() {
            if idsToDelete.contains(item.id) {
                deleteOffsets.insert(idx)
            }
        }
        dataManager.deleteProject(at: deleteOffsets)
    }
}

