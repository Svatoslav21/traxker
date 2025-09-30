import SwiftUI


@available(iOS 14.0, *)
struct TeamMemberAddView: View {
    @ObservedObject var dataManager: AppDataManager
    @Environment(\.presentationMode) private var presentationMode

    // Required fields (20+)
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var role = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var department = ""
    @State private var skillsText = ""
    @State private var joinedAt = Date()
    @State private var status = "Active"
    @State private var hourlyRate = ""
    @State private var weeklyHours = ""
    @State private var location = ""
    @State private var timezone = ""
    @State private var language = ""
    @State private var isActive = true
    @State private var isAvailable = true
    @State private var tagsText = ""
    @State private var emergencyContact = ""
    @State private var certificationsText = ""
    @State private var notes = ""
    @State private var performanceRating = 3
    @State private var vacationDays = ""
    @State private var sickDays = ""

    // Optional
    @State private var managerIdText = "" // free text UUID if needed

    @State private var showAlert = false
    @State private var alertMessage = ""

    private func validate() -> [String] {
        var errors: [String] = []
        func req(_ v: String, _ name: String) { if v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { errors.append("\(name) is required") } }
        req(firstName, "First Name")
        req(lastName, "Last Name")
        req(role, "Role")
        req(email, "Email")
        req(phone, "Phone")
        req(department, "Department")
        req(location, "Location")
        req(timezone, "Timezone")
        req(language, "Language")
        req(hourlyRate, "Hourly Rate")
        req(weeklyHours, "Weekly Hours")
        req(vacationDays, "Vacation Days")
        req(sickDays, "Sick Days")
        req(emergencyContact, "Emergency Contact")
        // light format checks
        if Double(hourlyRate) == nil { errors.append("Hourly Rate must be a number") }
        if Int(weeklyHours) == nil { errors.append("Weekly Hours must be an integer") }
        if Int(vacationDays) == nil { errors.append("Vacation Days must be an integer") }
        if Int(sickDays) == nil { errors.append("Sick Days must be an integer") }
        return errors
    }

    private func makeMember() -> TeamMember {
        let skills = skillsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let certs = certificationsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let managerId = UUID(uuidString: managerIdText)

        return TeamMember(
            id: UUID(),
            firstName: firstName,
            lastName: lastName,
            role: role,
            email: email,
            phone: phone,
            department: department,
            skills: skills,
            joinedAt: joinedAt,
            updatedAt: Date(),
            status: status,
            managerId: managerId,
            hourlyRate: Double(hourlyRate) ?? 0,
            weeklyHours: Int(weeklyHours) ?? 0,
            location: location,
            timezone: timezone,
            language: language,
            isActive: isActive,
            isAvailable: isAvailable,
            tags: tags,
            projectIds: [],
            taskIds: [],
            lastLogin: Date(),
            loginCount: 0,
            emergencyContact: emergencyContact,
            certifications: certs,
            notes: notes,
            performanceRating: performanceRating,
            vacationDays: Int(vacationDays) ?? 0,
            sickDays: Int(sickDays) ?? 0,
            archived: false
        )
    }

    var body: some View {
        NavigationView {
            ScrollView {
                // Identity
                TeamMemberAddSectionHeaderView(title: "Identity", systemImage: "person.fill", color: TeamMemberTheme.blue)
                VStack(spacing: 12) {
                    TeamMemberAddFieldView(title: "First Name", systemImage: "person.fill", color: TeamMemberTheme.blue, text: $firstName)
                    TeamMemberAddFieldView(title: "Last Name", systemImage: "person.fill", color: TeamMemberTheme.blue, text: $lastName)
                    TeamMemberAddFieldView(title: "Role", systemImage: "briefcase.fill", color: TeamMemberTheme.indigo, text: $role)
                    TeamMemberAddDatePickerView(title: "Joined At", systemImage: "calendar", color: TeamMemberTheme.blue, date: $joinedAt)
                }

                // Contact
                TeamMemberAddSectionHeaderView(title: "Contact", systemImage: "envelope.fill", color: TeamMemberTheme.indigo)
                VStack(spacing: 12) {
                    TeamMemberAddFieldView(title: "Email", systemImage: "envelope.fill", color: TeamMemberTheme.indigo, text: $email, keyboard: .emailAddress, autocapitalization: .none)
                    TeamMemberAddFieldView(title: "Phone", systemImage: "phone.fill", color: TeamMemberTheme.green, text: $phone, keyboard: .numbersAndPunctuation, autocapitalization: .none)
                    TeamMemberAddFieldView(title: "Emergency Contact", systemImage: "cross.case.fill", color: TeamMemberTheme.red, text: $emergencyContact)
                }

                // Work & Locale
                TeamMemberAddSectionHeaderView(title: "Work & Locale", systemImage: "gearshape.fill", color: TeamMemberTheme.orange)
                VStack(spacing: 12) {
                    TeamMemberAddFieldView(title: "Department", systemImage: "rectangle.3.group.fill", color: TeamMemberTheme.blue, text: $department)
                    TeamMemberAddFieldView(title: "Location", systemImage: "mappin.and.ellipse", color: TeamMemberTheme.orange, text: $location)
                    TeamMemberAddFieldView(title: "Timezone (e.g. PST)", systemImage: "globe", color: TeamMemberTheme.indigo, text: $timezone, autocapitalization: .allCharacters)
                    TeamMemberAddFieldView(title: "Language", systemImage: "character.book.closed.fill", color: TeamMemberTheme.indigo, text: $language)
                    TeamMemberAddFieldView(title: "Manager UUID (optional)", systemImage: "person.2.fill", color: TeamMemberTheme.blue, text: $managerIdText, keyboard: .default, autocapitalization: .none)
                }

                // Skills & Tags
                TeamMemberAddSectionHeaderView(title: "Skills & Tags", systemImage: "tag.fill", color: TeamMemberTheme.red)
                VStack(spacing: 12) {
                    TeamMemberAddFieldView(title: "Skills (comma-separated)", systemImage: "wrench.and.screwdriver.fill", color: TeamMemberTheme.orange, text: $skillsText, autocapitalization: .none)
                    TeamMemberAddFieldView(title: "Certifications (comma-separated)", systemImage: "rosette", color: TeamMemberTheme.indigo, text: $certificationsText, autocapitalization: .none)
                    TeamMemberAddFieldView(title: "Tags (comma-separated)", systemImage: "tag.fill", color: TeamMemberTheme.red, text: $tagsText, autocapitalization: .none)
                }

                // Workload & Status
                TeamMemberAddSectionHeaderView(title: "Workload & Status", systemImage: "chart.bar.doc.horizontal.fill", color: TeamMemberTheme.blue)
                VStack(spacing: 12) {
                    TeamMemberAddFieldView(title: "Hourly Rate", systemImage: "dollarsign.circle", color: TeamMemberTheme.green, text: $hourlyRate, keyboard: .decimalPad, autocapitalization: .none)
                    TeamMemberAddFieldView(title: "Weekly Hours", systemImage: "timer", color: TeamMemberTheme.blue, text: $weeklyHours, keyboard: .numberPad, autocapitalization: .none)
                    HStack(spacing: 12) {
                        togglePill(title: "Active", isOn: $isActive, color: TeamMemberTheme.green, symbol: "checkmark.seal.fill")
                        togglePill(title: "Available", isOn: $isAvailable, color: TeamMemberTheme.orange, symbol: "bolt.fill")
                    }
                    .padding(.horizontal)

                    HStack {
                        Text("Performance")
                            .font(.subheadline).bold()
                            .foregroundColor(.primary)
                        Spacer()
                        Stepper(value: $performanceRating, in: 1...5) {
                            HStack {
                                ForEach(0..<5) { i in
                                    Image(systemName: i < performanceRating ? "star.fill" : "star")
                                        .foregroundColor(TeamMemberTheme.orange)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(TeamMemberTheme.bgCard).cornerRadius(12)
                    .padding(.horizontal)
                }

                // Time Off
                TeamMemberAddSectionHeaderView(title: "Time Off", systemImage: "calendar.badge.exclamationmark", color: TeamMemberTheme.red)
                VStack(spacing: 12) {
                    TeamMemberAddFieldView(title: "Vacation Days", systemImage: "sun.max.fill", color: TeamMemberTheme.orange, text: $vacationDays, keyboard: .numberPad, autocapitalization: .none)
                    TeamMemberAddFieldView(title: "Sick Days", systemImage: "bandage.fill", color: TeamMemberTheme.red, text: $sickDays, keyboard: .numberPad, autocapitalization: .none)
                }

                // Notes
                TeamMemberAddSectionHeaderView(title: "Notes", systemImage: "note.text", color: TeamMemberTheme.indigo)
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $notes)
                        .frame(height: 120)
                        .padding(10)
                        .background(TeamMemberTheme.bgCard)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(TeamMemberTheme.separator, lineWidth: 1))
                        .padding(.horizontal)
                }

                Spacer(minLength: 24)

                Button(action: saveTapped) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Team Member")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [TeamMemberTheme.blue, TeamMemberTheme.indigo]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    .accessibilityLabel(Text("Add Team Member"))
                }
                .padding(.bottom, 24)
            }
            .background(TeamMemberTheme.bgGrouped.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("New Team Member", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Team Member"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("successfully") {
                            presentationMode.wrappedValue.dismiss()
                        }
                      })
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private func togglePill(title: String, isOn: Binding<Bool>, color: Color, symbol: String) -> some View {
        Button(action: { isOn.wrappedValue.toggle() }) {
            HStack {
                Image(systemName: isOn.wrappedValue ? symbol : "circle")
                Text(title)
                    .bold()
            }
            .foregroundColor(isOn.wrappedValue ? .white : color)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(isOn.wrappedValue ? color : color.opacity(0.12))
            .cornerRadius(20)
        }
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(isOn.wrappedValue ? "On" : "Off"))
    }

    private func saveTapped() {
        let errors = validate()
        if !errors.isEmpty {
            alertMessage = "Please fix the following:\n• " + errors.joined(separator: "\n• ")
            showAlert = true
            return
        }
        let newMember = makeMember()
        dataManager.addTeamMember(newMember)
        alertMessage = "Team member added successfully."
        showAlert = true
    }
}
