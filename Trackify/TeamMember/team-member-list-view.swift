import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberListView: View {
    @ObservedObject var dataManager: AppDataManager
    @State private var searchText: String = ""
    @State private var pushAdd: Bool = false

    private var filtered: [TeamMember] {
        let s = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return dataManager.teamMembers }
        let lower = s.lowercased()
        return dataManager.teamMembers.filter { m in
            let hay = [
                m.firstName, m.lastName, m.role, m.email, m.phone,
                m.department, m.location, m.timezone, m.language,
                m.skills.joined(separator: " "), m.tags.joined(separator: " ")
            ].joined(separator: " ").lowercased()
            return hay.contains(lower)
        }
    }

    var body: some View {
            VStack(spacing: 0) {
                TeamMemberSearchBarView(text: $searchText)

                if filtered.isEmpty {
                    TeamMemberNoDataView()
                        .padding(.top, 40)
                    Spacer()
                } else {
                    List {
                        ForEach(filtered, id: \.id) { member in
                            ZStack {
                                NavigationLink(destination: TeamMemberDetailView(member: member)) {
                                    EmptyView()
                                }
                                .opacity(0)

                                TeamMemberListRowView(member: member)
                                    .contentShape(Rectangle())
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                NavigationLink(destination: TeamMemberAddView(dataManager: dataManager), isActive: $pushAdd) {
                    EmptyView()
                }
                .hidden()
            }
            .background(TeamMemberTheme.bgGrouped)
            .navigationBarTitle("Team Members", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: { pushAdd = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(TeamMemberTheme.blue)
                        .accessibilityLabel(Text("Add Team Member"))
                }
            )
        
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func delete(at offsets: IndexSet) {
        var originalOffsets = IndexSet()
        for i in offsets {
            let id = filtered[i].id
            if let idx = dataManager.teamMembers.firstIndex(where: { $0.id == id }) {
                originalOffsets.insert(idx)
            }
        }
        dataManager.deleteTeamMember(at: originalOffsets)
    }
}


