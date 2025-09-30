
import SwiftUI

@available(iOS 14.0, *)
struct ProjectDetailView: View {
    var project: Project

     var twoCols: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header()

                // Overview
                groupCard(title: "Overview", icon: "rectangle.and.pencil.and.ellipsis") {
                    LazyVGrid(columns: twoCols, spacing: 12) {
                        ProjectDetailFieldRow(title: "Status", value: project.status, systemImage: "bolt.fill")
                        ProjectDetailFieldRow(title: "Category", value: project.category, systemImage: "square.grid.2x2.fill")
                        ProjectDetailFieldRow(title: "Risk Level", value: project.riskLevel, systemImage: "exclamationmark.triangle.fill")
                        ProjectDetailFieldRow(title: "Visibility", value: project.visibility, systemImage: "eye.fill")
                    }
                    ProjectDetailFieldRow(title: "Description", value: project.description, systemImage: "text.quote")
                }

                // Timeline
                groupCard(title: "Timeline", icon: "calendar") {
                    LazyVGrid(columns: twoCols, spacing: 12) {
                        ProjectDetailFieldRow(title: "Start Date", value: dateString(project.startDate), systemImage: "calendar")
                        ProjectDetailFieldRow(title: "End Date", value: dateString(project.endDate), systemImage: "calendar")
                        ProjectDetailFieldRow(title: "Created", value: dateString(project.createdAt), systemImage: "clock")
                        ProjectDetailFieldRow(title: "Updated", value: dateString(project.updatedAt), systemImage: "clock.fill")
                        ProjectDetailFieldRow(title: "Deadline Flexible", value: project.deadlineFlexible ? "Yes" : "No", systemImage: "calendar.badge.clock")
                        ProjectDetailFieldRow(title: "Milestone", value: project.milestone, systemImage: "target")
                    }
                }

                // People & Roles
                groupCard(title: "People & Roles", icon: "person.3.fill") {
                    LazyVGrid(columns: twoCols, spacing: 12) {
                        ProjectDetailFieldRow(title: "Manager", value: project.manager, systemImage: "person.fill")
                        ProjectDetailFieldRow(title: "Team Size", value: "\(project.teamSize)", systemImage: "person.2.fill")
                        ProjectDetailFieldRow(title: "Priority", value: "\(project.priority)", systemImage: "flag.fill")
                    }
                }

                // Finance
                groupCard(title: "Financials", icon: "dollarsign.circle.fill") {
                    LazyVGrid(columns: twoCols, spacing: 12) {
                        ProjectDetailFieldRow(title: "Budget", value: "\(project.currency) \(String(format: "%.2f", project.budget))", systemImage: "dollarsign.circle.fill")
                        ProjectDetailFieldRow(title: "Spent", value: "\(project.currency) \(String(format: "%.2f", project.spent))", systemImage: "creditcard.fill")
                        ProjectDetailFieldRow(title: "Billable", value: project.isBillable ? "Yes" : "No", systemImage: "briefcase.fill")
                        ProjectDetailFieldRow(title: "Approval Required", value: project.approvalRequired ? "Yes" : "No", systemImage: "checkmark.seal.fill")
                        ProjectDetailFieldRow(title: "Revisions", value: "\(project.revisionCount)", systemImage: "arrow.counterclockwise.circle")
                        ProjectDetailFieldRow(title: "Progress %", value: "\(Int(project.progressPercent))%", systemImage: "chart.bar.xaxis")
                    }
                }

                // Classification & Misc
                groupCard(title: "Classification", icon: "slider.horizontal.3") {
                    LazyVGrid(columns: twoCols, spacing: 12) {
                        ProjectDetailFieldRow(title: "Location", value: project.location, systemImage: "mappin.and.ellipse")
                        ProjectDetailFieldRow(title: "Visibility", value: project.visibility, systemImage: "eye.fill")
                        ProjectDetailFieldRow(title: "Tags", value: project.tags.joined(separator: ", "), systemImage: "tag.fill")
                        ProjectDetailFieldRow(title: "Archived", value: project.archived ? "Yes" : "No", systemImage: "archivebox.fill")
                    }
                    if !project.feedbackNotes.isEmpty {
                        ProjectDetailFieldRow(title: "Feedback Notes", value: project.feedbackNotes, systemImage: "bubble.left.and.bubble.right.fill")
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Project Detail", displayMode: .inline)
    }

    // MARK: - Subviews
    private func header() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(project.name)
                .font(.largeTitle).bold()
            HStack(spacing: 12) {
                Label(project.status, systemImage: "bolt.fill")
                    .foregroundColor(.secondary)
                Label(project.category, systemImage: "square.grid.2x2.fill")
                    .foregroundColor(.secondary)
                Label("\(Int(project.progressPercent))%", systemImage: "chart.bar.xaxis")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
    }

    private func groupCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func dateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}

@available(iOS 14.0, *)
struct ProjectDetailFieldRow: View {
    let title: String
    let value: String
    var systemImage: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .frame(width: 20)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
