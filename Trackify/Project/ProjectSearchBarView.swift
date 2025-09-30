
import SwiftUI

@available(iOS 14.0, *)
struct ProjectSearchBarView: View {
    @Binding var query: String
    @State private var isActive: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(isActive ? .blue : .secondary)
                    .scaleEffect(isActive ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isActive)

                TextField("Search projects...", text: $query, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isActive = editing
                    }
                })
                .disableAutocorrection(true)
                .autocapitalization(.none)

                if !query.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            query = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel(Text("Clear search"))
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

@available(iOS 14.0, *)
struct ProjectListRowView: View {
    let project: Project

    var progressText: String {
        "\(Int(project.progressPercent))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text(project.name)
                    .font(.headline)
                Spacer()
                Label(progressText, systemImage: "chart.bar.xaxis")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.blue.opacity(0.12)))
                    .foregroundColor(.blue)
            }

            // Primary meta
            HStack(spacing: 12) {
                Label(project.status, systemImage: "bolt.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Label(project.category, systemImage: "square.grid.2x2.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Label(project.riskLevel, systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Two-column compact grid (show 15+ fields compactly)
            VStack(spacing: 6) {
                row("Manager", project.manager, "person.fill")
                row("Team Size", "\(project.teamSize)", "person.2.fill")
                row("Priority", "\(project.priority)", "flag.fill")
                row("Milestone", project.milestone, "target")
                row("Tasks", "\(project.completedTasks)/\(project.tasksCount)", "checkmark.circle.fill")
                row("Budget", "\(project.currency) \(String(format: "%.2f", project.budget))", "dollarsign.circle.fill")
                row("Spent", "\(project.currency) \(String(format: "%.2f", project.spent))", "creditcard.fill")
                row("Location", project.location, "mappin.and.ellipse")
                row("Visibility", project.visibility, "eye.fill")
                row("Billable", project.isBillable ? "Yes" : "No", "briefcase.fill")
                row("Approval", project.approvalRequired ? "Required" : "Not Required", "checkmark.seal.fill")
                row("Deadl. Flex", project.deadlineFlexible ? "Flexible" : "Fixed", "calendar.badge.clock")
                row("Start", dateString(project.startDate), "calendar")
                row("End", dateString(project.endDate), "calendar")
                row("Updated", dateString(project.updatedAt), "clock.fill")
            }

            if !project.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(project.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.blue.opacity(0.12)))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
    }

    private func row(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }

    private func dateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}

@available(iOS 14.0, *)
struct ProjectNoDataView: View {
    @State private var animate: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48, weight: .regular))
                .foregroundColor(.secondary)
                .scaleEffect(animate ? 1.06 : 0.94)
                .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animate)
                .onAppear { animate = true }

            Text("No Projects Found")
                .font(.headline)
            Text("Try adding a new project or adjusting your search.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .padding()
        .accessibilityElement(children: .combine)
    }
}
