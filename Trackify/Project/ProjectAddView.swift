
import SwiftUI

@available(iOS 14.0, *)
struct ProjectAddView: View {
    @ObservedObject var dataManager: AppDataManager
    @Environment(\.presentationMode) private var presentationMode

    // Core (strings for numeric to validate cleanly)
    @State private var name: String = ""
    @State private var descriptionText: String = ""
    @State private var status: String = "Active"
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(60*60*24*30)

    @State private var budget: String = ""
    @State private var spent: String = ""
    @State private var currency: String = "USD"

    @State private var tasksCount: String = ""
    @State private var completedTasks: String = ""
    @State private var milestone: String = "Kickoff"

    @State private var manager: String = ""
    @State private var teamSize: String = ""
    @State private var priority: String = "1"
    @State private var category: String = "Development"
    @State private var riskLevel: String = "Low"
    @State private var tagsInput: String = "SwiftUI, iOS"

    @State private var deadlineFlexible: Bool = false
    @State private var progressPercent: String = "0"
    @State private var location: String = "Remote"
    @State private var visibility: String = "Internal"
    @State private var isBillable: Bool = true
    @State private var approvalRequired: Bool = true
    @State private var revisionCount: String = "0"
    @State private var feedbackNotes: String = ""

    @State private var selectedClientID: String = ""

    // Alert
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    // Dropdown sources
    private let statuses = ["Active", "On Hold", "Completed", "Cancelled"]
    private let categories = ["Development", "Design", "Marketing", "Research"]
    private let riskLevels = ["Low", "Medium", "High"]
    private let visibilities = ["Internal", "Public", "Private"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create New Project")
                            .font(.largeTitle).bold()
                        Text("Enter project details and settings below. All fields are required.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .padding(.top, 8)

                // About section
                ProjectAddSectionHeaderView(title: "Overview", subtitle: "Core identity & lifecycle", systemImage: "rectangle.and.pencil.and.ellipsis")

                ProjectAddFieldView(label: "Project Name", systemImage: "textformat", placeholder: "e.g. Mobile App", text: $name)
                ProjectAddFieldView(label: "Description", systemImage: "text.quote", placeholder: "e.g. Build SwiftUI app", text: $descriptionText)
                pickerRow(title: "Status", systemImage: "bolt.fill", selection: $status, options: statuses)
                HStack(spacing: 12) {
                    ProjectAddDatePickerView(label: "Start Date", systemImage: "calendar", date: $startDate)
                    ProjectAddDatePickerView(label: "End Date", systemImage: "calendar", date: $endDate)
                }

                // Finance
                ProjectAddSectionHeaderView(title: "Financials", subtitle: "Budget, spend & currency", systemImage: "dollarsign.circle.fill")
                HStack(spacing: 12) {
                    ProjectAddFieldView(label: "Budget", systemImage: "dollarsign", placeholder: "e.g. 50000", keyboardType: .decimalPad, text: $budget)
                    ProjectAddFieldView(label: "Spent", systemImage: "creditcard", placeholder: "e.g. 10000", keyboardType: .decimalPad, text: $spent)
                }
                ProjectAddFieldView(label: "Currency", systemImage: "coloncurrencysign", placeholder: "e.g. USD", text: $currency)

                // Progress
                ProjectAddSectionHeaderView(title: "Progress & Tasks", subtitle: "Track execution", systemImage: "chart.bar.xaxis")
                HStack(spacing: 12) {
                    ProjectAddFieldView(label: "Tasks Count", systemImage: "list.number", placeholder: "e.g. 25", keyboardType: .numberPad, text: $tasksCount)
                    ProjectAddFieldView(label: "Completed Tasks", systemImage: "checkmark.circle", placeholder: "e.g. 5", keyboardType: .numberPad, text: $completedTasks)
                }
                HStack(spacing: 12) {
                    ProjectAddFieldView(label: "Progress %", systemImage: "percent", placeholder: "e.g. 20", keyboardType: .decimalPad, text: $progressPercent)
                    ProjectAddFieldView(label: "Revision Count", systemImage: "arrow.counterclockwise.circle", placeholder: "e.g. 0", keyboardType: .numberPad, text: $revisionCount)
                }
                ProjectAddFieldView(label: "Milestone", systemImage: "target", placeholder: "e.g. Prototype", text: $milestone)

                // People
                ProjectAddSectionHeaderView(title: "People & Roles", subtitle: "Who is responsible", systemImage: "person.3.fill")
                ProjectAddFieldView(label: "Manager", systemImage: "person.fill", placeholder: "e.g. Alice Smith", text: $manager)
                HStack(spacing: 12) {
                    ProjectAddFieldView(label: "Team Size", systemImage: "person.2.fill", placeholder: "e.g. 6", keyboardType: .numberPad, text: $teamSize)
                    ProjectAddFieldView(label: "Priority", systemImage: "flag.fill", placeholder: "e.g. 1", keyboardType: .numberPad, text: $priority)
                }

                // Classification
                ProjectAddSectionHeaderView(title: "Classification", subtitle: "Category & risk", systemImage: "slider.horizontal.3")
                pickerRow(title: "Category", systemImage: "square.grid.2x2.fill", selection: $category, options: categories)
                pickerRow(title: "Risk Level", systemImage: "exclamationmark.triangle.fill", selection: $riskLevel, options: riskLevels)
                ProjectAddFieldView(label: "Tags (comma-separated)", systemImage: "tag.fill", placeholder: "e.g. SwiftUI,iOS", text: $tagsInput)

                // Settings
                ProjectAddSectionHeaderView(title: "Settings", subtitle: "Constraints & visibility", systemImage: "gearshape.2.fill")
                HStack(spacing: 12) {
                    ProjectAddToggleView(label: "Deadline Flexible", systemImage: "calendar.badge.clock", isOn: $deadlineFlexible)
                    ProjectAddToggleView(label: "Billable", systemImage: "briefcase.fill", isOn: $isBillable)
                }
                ProjectAddToggleView(label: "Approval Required", systemImage: "checkmark.seal.fill", isOn: $approvalRequired)

                HStack(spacing: 12) {
                    ProjectAddFieldView(label: "Location", systemImage: "mappin.and.ellipse", placeholder: "e.g. Remote", text: $location)
                    pickerRow(title: "Visibility", systemImage: "eye.fill", selection: $visibility, options: visibilities)
                }

                // Client link
                ProjectAddSectionHeaderView(title: "Client", subtitle: "Associate with client", systemImage: "building.2.fill")
                VStack(alignment: .leading, spacing: 8) {
                    ProjectAddFieldView(label: "ClientID", systemImage: "person.2", placeholder: "Client", text: $selectedClientID)
                }

                // Feedback Notes
                ProjectAddSectionHeaderView(title: "Feedback", subtitle: "Notes for context", systemImage: "bubble.left.and.bubble.right.fill")
                ProjectAddFieldView(label: "Feedback Notes", systemImage: "bubble.left.fill", placeholder: "e.g. Initial feedback positive", text: $feedbackNotes)

                // Save button
                Button(action: saveTapped) {
                    HStack {
                        Spacer()
                        Label("Save Project", systemImage: "tray.and.arrow.down.fill")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.blue))
                    .foregroundColor(.white)
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .navigationBarTitle("Add Project", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                if alertTitle == "Success" {
                    presentationMode.wrappedValue.dismiss()
                }
            }))
        }
        
    }

    // MARK: - UI Helpers
    private func pickerRow(title: String, systemImage: String, selection: Binding<String>, options: [String]) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Picker(selection: selection, label: Text("")) {
                    ForEach(options, id: \.self) { opt in
                        Text(opt).tag(opt)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Validation & Save
    private func saveTapped() {
        var errors: [String] = []

        // Basic string validation
        if name.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Project Name is required.") }
        if descriptionText.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Description is required.") }
        if manager.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Manager is required.") }
        if currency.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Currency is required.") }
        if location.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Location is required.") }

        // Numeric validation
        let budgetValue = Double(budget) ?? -1
        let spentValue = Double(spent) ?? -1
        let tasksCountValue = Int(tasksCount) ?? -1
        let completedValue = Int(completedTasks) ?? -1
        let teamSizeValue = Int(teamSize) ?? -1
        let priorityValue = Int(priority) ?? -1
        let progressValue = Double(progressPercent) ?? -1
        let revisionValue = Int(revisionCount) ?? -1

        if budgetValue < 0 { errors.append("Budget must be a valid non-negative number.") }
        if spentValue < 0 { errors.append("Spent must be a valid non-negative number.") }
        if spentValue > budgetValue { errors.append("Spent cannot exceed Budget.") }
        if tasksCountValue < 0 { errors.append("Tasks Count must be a valid number.") }
        if completedValue < 0 { errors.append("Completed Tasks must be a valid number.") }
        if completedValue > tasksCountValue { errors.append("Completed Tasks cannot exceed Tasks Count.") }
        if teamSizeValue <= 0 { errors.append("Team Size must be greater than 0.") }
        if !(1...5).contains(priorityValue) { errors.append("Priority must be between 1 and 5.") }
        if progressValue < 0 || progressValue > 100 { errors.append("Progress % must be between 0 and 100.") }
        if revisionValue < 0 { errors.append("Revision Count must be zero or more.") }
        if startDate > endDate { errors.append("Start Date must be before End Date.") }



        if !errors.isEmpty {
            alertTitle = "Validation Errors"
            alertMessage = errors.joined(separator: "\n• ")
            alertMessage = "• " + alertMessage
            showAlert = true
            return
        }

        let tagsArr = tagsInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Build project
        let newProject = Project(
            id: UUID(),
            name: name,
            clientId: selectedClientID,
            description: descriptionText,
            status: status,
            startDate: startDate,
            endDate: endDate,
            budget: budgetValue,
            spent: spentValue,
            currency: currency,
            tasksCount: tasksCountValue,
            completedTasks: completedValue,
            milestone: milestone,
            createdAt: Date(),
            updatedAt: Date(),
            manager: manager,
            teamSize: teamSizeValue,
            priority: priorityValue,
            category: category,
            riskLevel: riskLevel,
            tags: tagsArr,
            deadlineFlexible: deadlineFlexible,
            progressPercent: progressValue,
            location: location,
            visibility: visibility,
            isBillable: isBillable,
            approvalRequired: approvalRequired,
            revisionCount: revisionValue,
            feedbackNotes: feedbackNotes,
            archived: false
        )

        dataManager.addProject(newProject)
        alertTitle = "Success"
        alertMessage = "Project “\(name)” has been created successfully."
        showAlert = true
    }
}

