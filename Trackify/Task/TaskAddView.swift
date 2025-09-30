
import SwiftUI

@available(iOS 14.0, *)
struct TaskAddView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var store: AppDataManager

    // Core fields
    @State private var projectIdStr: String = UUID().uuidString
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var status: String = "In Progress"
    @State private var priorityStr: String = "1"
    @State private var assignee: String = ""
    @State private var reviewer: String = ""

    // Dates
    @State private var createdAt: Date = Date()
    @State private var updatedAt: Date = Date()
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    @State private var completedAtEnabled: Bool = false
    @State private var completedAt: Date = Date()

    // Numbers
    @State private var estimatedHoursStr: String = "1"
    @State private var loggedHoursStr: String = "0"
    @State private var progress: Double = 0.25
    @State private var commentsCountStr: String = "0"
    @State private var attachmentsCountStr: String = "0"

    // Toggles
    @State private var isRecurring: Bool = false
    @State private var isBillable: Bool = true
    @State private var clientVisible: Bool = true
    @State private var approvalRequired: Bool = false
    @State private var archived: Bool = false

    // Texts
    @State private var recurrenceRule: String = ""
    @State private var approvalStatus: String = "Pending"
    @State private var riskLevel: String = "Low"

    // Arrays (comma separated)
    @State private var tagsCSV: String = ""
    @State private var checklistCSV: String = ""
    @State private var reminders: [Date] = []
    @State private var newReminder: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date())!

    // Relations
    @State private var blockedByStr: String = ""
    @State private var blockingCSV: String = ""

    // Alert
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = "Validation"
    @State private var alertMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header

                // Info section
                Group {
                    TaskAddSectionHeaderView(title: "Core Info", icon: "square.and.pencil")
                    TaskAddFieldView(label: "Title", icon: "textformat", text: $title)
                    TaskAddFieldView(label: "Description", icon: "doc.text", text: $description, isMultiline: true)
                    TaskAddFieldView(label: "Status", icon: "bolt.circle", text: $status)
                    HStack(spacing: 16) {
                        TaskAddFieldView(label: "Priority", icon: "exclamationmark.circle", text: $priorityStr, keyboard: .numberPad)
                        VStack {
                            Text("Progress").font(.caption).foregroundColor(.secondary)
                            Slider(value: $progress, in: 0...1, step: 0.01)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(14)
                    }
                    HStack(spacing: 16) {
                        TaskAddFieldView(label: "Assignee", icon: "person.fill", text: $assignee)
                        TaskAddFieldView(label: "Reviewer", icon: "checkmark.seal", text: $reviewer)
                    }
                }

                // Timing section
                Group {
                    TaskAddSectionHeaderView(title: "Dates & Duration", icon: "calendar")
                    TaskAddDatePickerView(label: "Created At", icon: "calendar.badge.clock", date: $createdAt)
                    TaskAddDatePickerView(label: "Updated At", icon: "calendar.badge.exclamationmark", date: $updatedAt)
                    TaskAddDatePickerView(label: "Due Date", icon: "calendar", date: $dueDate)
                    ToggleRow(title: "Completed At Enabled", icon: "calendar.badge.checkmark", isOn: $completedAtEnabled)
                    if completedAtEnabled {
                        TaskAddDatePickerView(label: "Completed At", icon: "calendar.badge.checkmark", date: $completedAt)
                    }

                    HStack(spacing: 16) {
                        TaskAddFieldView(label: "Estimated Hours", icon: "timer", text: $estimatedHoursStr, keyboard: .decimalPad)
                        TaskAddFieldView(label: "Logged Hours", icon: "clock.arrow.circlepath", text: $loggedHoursStr, keyboard: .decimalPad)
                    }
                }

                // Arrays & Recurrence
                Group {
                    TaskAddSectionHeaderView(title: "Tags, Checklist & Recurrence", icon: "tag")
                    TaskAddFieldView(label: "Tags (comma-separated)", icon: "number", text: $tagsCSV)
                    TaskAddFieldView(label: "Checklist (comma-separated)", icon: "checklist", text: $checklistCSV)
                    ToggleRow(title: "Is Recurring", icon: "arrow.triangle.2.circlepath", isOn: $isRecurring)
                    if isRecurring {
                        TaskAddFieldView(label: "Recurrence Rule", icon: "arrow.clockwise", text: $recurrenceRule)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reminders").font(.caption).foregroundColor(.secondary)
                        HStack {
                            DatePicker("", selection: $newReminder, displayedComponents: .date).labelsHidden()
                            Button(action: {
                                reminders.append(newReminder)
                            }) {
                                Label("Add", systemImage: "plus.circle.fill")
                                    .foregroundColor(.orange)
                            }.buttonStyle(PlainButtonStyle())
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(reminders.indices, id: \.self) { idx in
                                    TaskChip(text: dateStr(reminders[idx]), color: .orange)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                }

                // Visibility & Approvals
                Group {
                    TaskAddSectionHeaderView(title: "Visibility & Approvals", icon: "eye")
                    ToggleRow(title: "Is Billable", icon: "dollarsign.circle", isOn: $isBillable)
                    ToggleRow(title: "Client Visible", icon: "eye", isOn: $clientVisible)
                    ToggleRow(title: "Approval Required", icon: "hand.raised", isOn: $approvalRequired)
                    if approvalRequired {
                        TaskAddFieldView(label: "Approval Status", icon: "checkmark.seal", text: $approvalStatus)
                    }
                    TaskAddFieldView(label: "Risk Level", icon: "flame", text: $riskLevel)
                }

                // Meta & Relations
                Group {
                    TaskAddSectionHeaderView(title: "Meta, Counters & Relations", icon: "link")
                    HStack(spacing: 16) {
                        TaskAddFieldView(label: "Comments Count", icon: "doc.text", text: $commentsCountStr, keyboard: .numberPad)
                        TaskAddFieldView(label: "Attachments Count", icon: "paperclip", text: $attachmentsCountStr, keyboard: .numberPad)
                    }
                    TaskAddFieldView(label: "Project ID (UUID)", icon: "folder", text: $projectIdStr, keyboard: .asciiCapable)
                    TaskAddFieldView(label: "Blocked By (UUID)", icon: "link", text: $blockedByStr, keyboard: .asciiCapable)
                    TaskAddFieldView(label: "Blocking (UUIDs comma-separated)", icon: "link.badge.plus", text: $blockingCSV, keyboard: .asciiCapable)
                    ToggleRow(title: "Archived", icon: "archivebox", isOn: $archived)
                }

                // Save
                Button(action: submit) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Task")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule().fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    )
                    .shadow(color: Color.blue.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemGroupedBackground), Color(UIColor.secondarySystemGroupedBackground)]),
                startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
        .navigationBarTitle("New Task", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                if alertTitle == "Success" {
                    presentationMode.wrappedValue.dismiss()
                }
            }))
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Create a Task")
                    .font(.title2).bold()
                Text("Custom layout with floating labels and grouped sections.")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "square.and.pencil")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(.bottom, 4)
    }

    private func submit() {
        var errors: [String] = []

        // Validate
        if UUID(uuidString: projectIdStr) == nil { errors.append("Project ID is not a valid UUID.") }
        if title.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Title is required.") }
        if description.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Description is required.") }
        if status.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Status is required.") }
        guard let priority = Int(priorityStr) else { errors.append("Priority must be an integer."); gotoNext() ; return }
        func gotoNext() { } // no-op to allow guard above usage

        if assignee.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Assignee is required.") }
        if reviewer.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Reviewer is required.") }

        // Build arrays
        let tags = tagsCSV.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let checklist = checklistCSV.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let blockedByUUID = blockedByStr.isEmpty ? nil : UUID(uuidString: blockedByStr)
        if !blockedByStr.isEmpty && blockedByUUID == nil {
            errors.append("Blocked By is not a valid UUID.")
        }
        let blockingUUIDs: [UUID] = blockingCSV.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .compactMap { $0.isEmpty ? nil : UUID(uuidString: $0) }

        // If there were invalid blocking UUID strings, catch them:
        let blockingIdsParts = blockingCSV.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if blockingIdsParts.filter({ !$0.isEmpty }).count != blockingUUIDs.count {
            errors.append("One or more Blocking UUIDs are invalid.")
        }

        if !errors.isEmpty {
            alertTitle = "Validation"
            alertMessage = errors.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            showAlert = true
            return
        }

        let newTask = TaskModel(
            id: UUID(),
            projectId: UUID(uuidString: projectIdStr) ?? UUID(),
            title: title,
            description: description,
            status: status,
            priority: Int(priorityStr) ?? 0,
            assignee: assignee,
            reviewer: reviewer,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dueDate: dueDate,
            completedAt: completedAtEnabled ? completedAt : nil,
            estimatedHours: Double(estimatedHoursStr) ?? 0,
            loggedHours: Double(loggedHoursStr) ?? 0,
            tags: tags,
            progress: progress,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            reminders: reminders,
            checklist: checklist,
            commentsCount: Int(commentsCountStr) ?? 0,
            attachmentsCount: Int(attachmentsCountStr) ?? 0,
            isBillable: isBillable,
            clientVisible: clientVisible,
            approvalRequired: approvalRequired,
            approvalStatus: approvalStatus,
            riskLevel: riskLevel,
            blockedBy: blockedByUUID,
            blocking: blockingUUIDs,
            archived: archived
        )

        store.addTask(newTask)
        alertTitle = "Success"
        alertMessage = "Task saved successfully!"
        showAlert = true
    }

    private func dateStr(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

@available(iOS 14.0, *)
struct ToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Toggle(isOn: $isOn) {
                Text(title)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
}


@available(iOS 14.0, *)
struct TaskAddSectionHeaderView: View {
    let title: String
    let icon: String
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.05)]),
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(.blue)
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }
}

@available(iOS 14.0, *)
struct TaskAddFieldView: View {
    let label: String
    let icon: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isMultiline: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .padding(.top, isMultiline ? 10 : 0)

                VStack(alignment: .leading, spacing: 6) {
                    // Floating Label
                    Text(label.uppercased())
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .opacity(text.isEmpty ? 0.7 : 1)

                    if isMultiline {
                        TextEditor(text: $text)
                            .frame(minHeight: 80, maxHeight: 140)
                            .keyboardType(keyboard)
                            .accessibilityLabel(Text(label))
                    } else {
                        TextField(label, text: $text)
                            .keyboardType(keyboard)
                            .accessibilityLabel(Text(label))
                    }
                }
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
    }
}


@available(iOS 14.0, *)
struct TaskAddDatePickerView: View {
    let label: String
    let icon: String
    @Binding var date: Date
    var allowsPast: Bool = true

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 6) {
                    Text(label.uppercased())
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, .current)
                }
                Spacer()
            }
            .padding(14)
        }
    }
}


@available(iOS 14.0, *)
struct TaskChip: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text)
                .font(.caption)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(10)
    }
}
