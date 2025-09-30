
import SwiftUI

@available(iOS 14.0, *)
struct TaskListView: View {
    @ObservedObject var store: AppDataManager
    @State private var searchQuery: String = ""

    private var filteredTasks: [TaskModel] {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return store.tasks }
        let q = searchQuery.lowercased()
        return store.tasks.filter { t in
            t.title.lowercased().contains(q) ||
            t.description.lowercased().contains(q) ||
            t.assignee.lowercased().contains(q) ||
            t.reviewer.lowercased().contains(q) ||
            t.status.lowercased().contains(q) ||
            t.tags.joined(separator: ",").lowercased().contains(q)
        }
    }

    var body: some View {
            VStack(spacing: 12) {
                header
                TaskSearchBarView(query: $searchQuery)
                    .padding(.horizontal)
                
                if filteredTasks.isEmpty {
                    Spacer()
                    TaskNoDataView()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                TaskListRowView(task: task)
                                    .padding(.vertical, 6)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("Tasks", displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: TaskAddView(store: store)) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            })
        
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Task Dashboard")
                    .font(.title2).bold()
                Text("Card-based list, real-time search, swipe to delete.")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.top, 8)
        .padding(.horizontal)
    }

    private func delete(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredTasks[$0].id }
        if let indexes = IndexSet(store.tasks.enumerated().filter({ idsToDelete.contains($0.element.id) }).map({ $0.offset })) as IndexSet? {
            store.deleteTask(at: indexes)
        }
    }
}

@available(iOS 14.0, *)
struct TaskListRowView: View {
    let task: TaskModel

    private var progressPercent: Int {
        Int((task.progress * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                // Progress badge
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.25), lineWidth: 6)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: CGFloat(task.progress))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 44, height: 44)
                    Text("\(progressPercent)%")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel(Text("Progress \(progressPercent) percent"))
            }

            // Quick stats grid: show a lot of fields succinctly
            VStack(spacing: 6) {
                // Row 1
                HStack(spacing: 12) {
                    stat(icon: "calendar", label: "Due", value: dateStr(task.dueDate))
                    stat(icon: "exclamationmark.circle", label: "Priority", value: "\(task.priority)")
                    stat(icon: "bolt.circle", label: "Status", value: task.status)
                }
                // Row 2
                HStack(spacing: 12) {
                    stat(icon: "person.fill", label: "Assignee", value: task.assignee)
                    stat(icon: "checkmark.seal", label: "Reviewer", value: task.reviewer)
                    stat(icon: "clock.arrow.circlepath", label: "Est/Log", value: "\(Int(task.estimatedHours))h / \(Int(task.loggedHours))h")
                }
                // Row 3
                HStack(spacing: 12) {
                    stat(icon: "doc.text", label: "Comments", value: "\(task.commentsCount)")
                    stat(icon: "paperclip", label: "Attach", value: "\(task.attachmentsCount)")
                    stat(icon: "dollarsign.circle", label: "Billable", value: task.isBillable ? "Yes" : "No")
                }
                // Row 4
                HStack(spacing: 12) {
                    stat(icon: "eye", label: "Client Visible", value: task.clientVisible ? "Yes" : "No")
                    stat(icon: "hand.raised", label: "Approval", value: task.approvalRequired ? task.approvalStatus : "Not Required")
                    stat(icon: "flame", label: "Risk", value: task.riskLevel)
                }
                // Row 5 (relations/flags)
                HStack(spacing: 12) {
                    stat(icon: "link", label: "BlockedBy", value: task.blockedBy?.uuidString.prefix(8).description ?? "None")
                    stat(icon: "link.badge.plus", label: "Blocking", value: task.blocking.isEmpty ? "None" : "\(task.blocking.count)")
                    stat(icon: "archivebox", label: "Archived", value: task.archived ? "Yes" : "No")
                }
                // Row 6 (timing/meta)
                HStack(spacing: 12) {
                    stat(icon: "calendar.badge.clock", label: "Created", value: dateStr(task.createdAt))
                    stat(icon: "calendar.badge.exclamationmark", label: "Updated", value: dateStr(task.updatedAt))
                    stat(icon: "calendar.badge.checkmark", label: "Completed", value: task.completedAt.map(dateStr) ?? "—")
                }
            }

            // Tags / Checklist chips
            if !task.tags.isEmpty || !task.checklist.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(task.tags, id: \.self) { tag in
                            TaskChip(text: tag, color: .blue)
                        }
                        ForEach(task.checklist, id: \.self) { item in
                            TaskChip(text: item, color: .green)
                        }
                        if task.isRecurring {
                            TaskChip(text: "Recurring: \(task.recurrenceRule.isEmpty ? "Yes" : task.recurrenceRule)", color: .orange)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.secondarySystemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.blue.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
    }

    private func stat(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 0) {
                Text(label).font(.caption2).foregroundColor(.secondary)
                Text(value).font(.caption).foregroundColor(.primary).lineLimit(1)
            }
        }.frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(8)
    }

    private func dateStr(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

@available(iOS 14.0, *)
struct TaskNoDataView: View {
    @State private var animate: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 8)
                    .frame(width: 120, height: 120)
                Image(systemName: "tray")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.blue)
                    .scaleEffect(animate ? 1.05 : 0.95)
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true))
            }
            Text("No Tasks Found")
                .font(.title3).bold()
            Text("Tap the + button to add your first task.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear { animate = true }
        .accessibilityElement(children: .combine)
    }
}


@available(iOS 14.0, *)
struct TaskSearchBarView: View {
    @Binding var query: String
    @State private var isActive = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.12), Color.clear]),
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: isActive ? 44 : 36, height: isActive ? 44 : 36)
                    .animation(.easeInOut(duration: 0.25))
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
            }
            .onTapGesture {
                withAnimation { isActive = true }
            }

            TextField("Search by title, tag, assignee, status…", text: $query, onEditingChanged: { editing in
                withAnimation { isActive = editing }
            })
            .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Search tasks"))
    }
}
