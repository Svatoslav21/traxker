
import SwiftUI

@available(iOS 14.0, *)
struct TaskDetailView: View {
    let task: TaskModel
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Hero header
                header

                // Overview
                TaskDetailGroupCard(title: "Overview", icon: "rectangle.3.offgrid") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        TaskDetailFieldRow(icon: "textformat", title: "Title", value: task.title)
                        TaskDetailFieldRow(icon: "bolt.circle", title: "Status", value: task.status)
                        TaskDetailFieldRow(icon: "doc.text", title: "Description", value: task.description)
                        TaskDetailFieldRow(icon: "exclamationmark.circle", title: "Priority", value: "\(task.priority)")
                        TaskDetailFieldRow(icon: "person.fill", title: "Assignee", value: task.assignee)
                        TaskDetailFieldRow(icon: "checkmark.seal", title: "Reviewer", value: task.reviewer)
                        TaskDetailFieldRow(icon: "number", title: "Project ID", value: task.projectId.uuidString)
                        TaskDetailFieldRow(icon: "archivebox", title: "Archived", value: task.archived ? "Yes" : "No")
                    }
                }

                // Timing
                TaskDetailGroupCard(title: "Dates & Time", icon: "calendar") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        TaskDetailFieldRow(icon: "calendar.badge.clock", title: "Created At", value: dateStr(task.createdAt))
                        TaskDetailFieldRow(icon: "calendar.badge.exclamationmark", title: "Updated At", value: dateStr(task.updatedAt))
                        TaskDetailFieldRow(icon: "calendar", title: "Due Date", value: dateStr(task.dueDate))
                        TaskDetailFieldRow(icon: "calendar.badge.checkmark", title: "Completed At", value: task.completedAt.map(dateStr) ?? "—")
                        TaskDetailFieldRow(icon: "timer", title: "Estimated Hours", value: "\(task.estimatedHours)")
                        TaskDetailFieldRow(icon: "clock.arrow.circlepath", title: "Logged Hours", value: "\(task.loggedHours)")
                        TaskDetailFieldRow(icon: "percent", title: "Progress", value: "\(Int(task.progress * 100))%")
                    }
                }

                // Arrays/recurrence
                TaskDetailGroupCard(title: "Tags, Checklist & Recurrence", icon: "tag") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        TaskDetailFieldRow(icon: "number", title: "Tags", value: task.tags.isEmpty ? "—" : task.tags.joined(separator: ", "))
                        TaskDetailFieldRow(icon: "checklist", title: "Checklist", value: task.checklist.isEmpty ? "—" : task.checklist.joined(separator: ", "))
                        TaskDetailFieldRow(icon: "arrow.triangle.2.circlepath", title: "Is Recurring", value: task.isRecurring ? "Yes" : "No")
                        TaskDetailFieldRow(icon: "arrow.clockwise", title: "Recurrence Rule", value: task.recurrenceRule.isEmpty ? "—" : task.recurrenceRule)
                        TaskDetailFieldRow(icon: "bell", title: "Reminders", value: task.reminders.isEmpty ? "—" : task.reminders.map(dateStr).joined(separator: ", "))
                    }
                }

                // Visibility & approvals
                TaskDetailGroupCard(title: "Visibility & Approvals", icon: "eye") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        TaskDetailFieldRow(icon: "dollarsign.circle", title: "Billable", value: task.isBillable ? "Yes" : "No")
                        TaskDetailFieldRow(icon: "eye", title: "Client Visible", value: task.clientVisible ? "Yes" : "No")
                        TaskDetailFieldRow(icon: "hand.raised", title: "Approval Required", value: task.approvalRequired ? "Yes" : "No")
                        TaskDetailFieldRow(icon: "checkmark.seal", title: "Approval Status", value: task.approvalStatus)
                        TaskDetailFieldRow(icon: "flame", title: "Risk Level", value: task.riskLevel)
                    }
                }

                // Relations & counts
                TaskDetailGroupCard(title: "Relations & Counts", icon: "link") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        TaskDetailFieldRow(icon: "link", title: "Blocked By", value: task.blockedBy?.uuidString ?? "—")
                        TaskDetailFieldRow(icon: "link.badge.plus", title: "Blocking", value: task.blocking.isEmpty ? "—" : task.blocking.map { $0.uuidString }.joined(separator: ", "))
                        TaskDetailFieldRow(icon: "doc.text", title: "Comments Count", value: "\(task.commentsCount)")
                        TaskDetailFieldRow(icon: "paperclip", title: "Attachments Count", value: "\(task.attachmentsCount)")
                    }
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemGroupedBackground), Color(UIColor.secondarySystemGroupedBackground)]),
                startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
        .navigationBarTitle("Task Detail", displayMode: .inline)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.title2).bold()
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: CGFloat(task.progress))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                Text("\(Int(task.progress*100))%")
                    .font(.caption).foregroundColor(.blue)
            }
        }
    }

    private func dateStr(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

@available(iOS 14.0, *)
struct TaskDetailFieldRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text(value).font(.callout).foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

@available(iOS 14.0, *)
struct TaskDetailGroupCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundColor(.purple)
                Text(title).font(.headline)
                Spacer()
            }
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.secondarySystemBackground)]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.15), lineWidth: 1)
        )
    }
}
