import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberDetailView: View {
    let member: TeamMember

    private var name: String { "\(member.firstName) \(member.lastName)" }

    let twoCols = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Hero header
                VStack(spacing: 10) {
                    Image(systemName: member.isActive ? "person.crop.circle.fill" : "person.crop.circle.badge.xmark")
                        .font(.system(size: 64))
                        .foregroundColor(member.isActive ? TeamMemberTheme.blue : TeamMemberTheme.red)
                        .accessibilityHidden(true)
                    Text(name).font(.title2).bold()
                    Text(member.role).font(.subheadline).foregroundColor(TeamMemberTheme.labelSecondary)
                    HStack(spacing: 8) {
                        CapsuleTag(text: member.status, color: member.isAvailable ? TeamMemberTheme.green : TeamMemberTheme.orange)
                        CapsuleTag(text: "Perf \(member.performanceRating)/5", color: TeamMemberTheme.orange)
                        CapsuleTag(text: member.language, color: TeamMemberTheme.indigo)
                    }
                }
                .padding(.top, 8)

                // Identity & Contact
                groupCard(title: "Identity & Contact", color: TeamMemberTheme.blue, icon: "person.fill") {
                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                        TeamMemberDetailFieldRow(label: "First Name", value: member.firstName, systemImage: "person.fill", color: TeamMemberTheme.blue)
                        TeamMemberDetailFieldRow(label: "Last Name", value: member.lastName, systemImage: "person.fill", color: TeamMemberTheme.blue)
                        TeamMemberDetailFieldRow(label: "Email", value: member.email, systemImage: "envelope.fill", color: TeamMemberTheme.indigo)
                        TeamMemberDetailFieldRow(label: "Phone", value: member.phone, systemImage: "phone.fill", color: TeamMemberTheme.green)
                        TeamMemberDetailFieldRow(label: "Joined At", value: Fmt.date.string(from: member.joinedAt), systemImage: "calendar", color: TeamMemberTheme.blue)
                        TeamMemberDetailFieldRow(label: "Updated At", value: Fmt.date.string(from: member.updatedAt), systemImage: "clock.fill", color: TeamMemberTheme.blue)
                        TeamMemberDetailFieldRow(label: "Emergency Contact", value: member.emergencyContact, systemImage: "cross.case.fill", color: TeamMemberTheme.red)
                        TeamMemberDetailFieldRow(label: "Manager ID", value: member.managerId?.uuidString ?? "—", systemImage: "person.2.fill", color: TeamMemberTheme.blue)
                    }
                }

                // Work & Availability
                groupCard(title: "Work & Availability", color: TeamMemberTheme.indigo, icon: "briefcase.fill") {
                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                        TeamMemberDetailFieldRow(label: "Department", value: member.department, systemImage: "rectangle.3.group.fill", color: TeamMemberTheme.blue)
                        TeamMemberDetailFieldRow(label: "Location", value: member.location, systemImage: "mappin.and.ellipse", color: TeamMemberTheme.orange)
                        TeamMemberDetailFieldRow(label: "Timezone", value: member.timezone, systemImage: "globe", color: TeamMemberTheme.indigo)
                        TeamMemberDetailFieldRow(label: "Language", value: member.language, systemImage: "character.book.closed.fill", color: TeamMemberTheme.indigo)
                        TeamMemberDetailFieldRow(label: "Active", value: member.isActive ? "Yes" : "No", systemImage: "checkmark.seal.fill", color: TeamMemberTheme.green)
                        TeamMemberDetailFieldRow(label: "Available", value: member.isAvailable ? "Yes" : "No", systemImage: "bolt.fill", color: TeamMemberTheme.orange)
                        TeamMemberDetailFieldRow(label: "Hourly Rate", value: "\(Int(member.hourlyRate))", systemImage: "dollarsign.circle", color: TeamMemberTheme.green)
                        TeamMemberDetailFieldRow(label: "Weekly Hours", value: "\(member.weeklyHours)", systemImage: "timer", color: TeamMemberTheme.blue)
                    }
                }

                // Experience & Tags
                groupCard(title: "Skills & Tags", color: TeamMemberTheme.orange, icon: "wrench.and.screwdriver.fill") {
                    VStack(alignment: .leading, spacing: 10) {
                        TeamMemberDetailFieldRow(label: "Skills", value: member.skills.commaString, systemImage: "wrench.and.screwdriver.fill", color: TeamMemberTheme.orange)
                        TeamMemberDetailFieldRow(label: "Certifications", value: member.certifications.commaString.isEmpty ? "—" : member.certifications.commaString, systemImage: "rosette", color: TeamMemberTheme.indigo)
                        TeamMemberDetailFieldRow(label: "Tags", value: member.tags.commaString.isEmpty ? "—" : member.tags.commaString, systemImage: "tag.fill", color: TeamMemberTheme.red)
                    }
                }

                // Activity
                groupCard(title: "Activity", color: TeamMemberTheme.green, icon: "chart.bar.doc.horizontal.fill") {
                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                        TeamMemberDetailFieldRow(label: "Last Login", value: Fmt.date.string(from: member.lastLogin), systemImage: "calendar.badge.clock", color: TeamMemberTheme.blue)
                        TeamMemberDetailFieldRow(label: "Login Count", value: "\(member.loginCount)", systemImage: "chart.bar.doc.horizontal.fill", color: TeamMemberTheme.blue)
                        TeamMemberDetailFieldRow(label: "Projects Linked", value: member.projectIds.countString, systemImage: "folder.fill", color: TeamMemberTheme.indigo)
                        TeamMemberDetailFieldRow(label: "Tasks Linked", value: member.taskIds.countString, systemImage: "checklist", color: TeamMemberTheme.green)
                        TeamMemberDetailFieldRow(label: "Performance", value: "\(member.performanceRating)/5", systemImage: "star.fill", color: TeamMemberTheme.orange)
                        TeamMemberDetailFieldRow(label: "Archived", value: member.archived ? "Yes" : "No", systemImage: "archivebox.fill", color: TeamMemberTheme.red)
                    }
                }

                // Leave & Notes
                groupCard(title: "Time Off & Notes", color: TeamMemberTheme.red, icon: "calendar.badge.exclamationmark") {
                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                        TeamMemberDetailFieldRow(label: "Vacation Days", value: "\(member.vacationDays)", systemImage: "sun.max.fill", color: TeamMemberTheme.orange)
                        TeamMemberDetailFieldRow(label: "Sick Days", value: "\(member.sickDays)", systemImage: "bandage.fill", color: TeamMemberTheme.red)
                    }
                    Divider().padding(.vertical, 8)
                    TeamMemberDetailFieldRow(label: "Notes", value: member.notes.isEmpty ? "—" : member.notes, systemImage: "note.text", color: TeamMemberTheme.indigo)
                }

                // Technical IDs (complete data)
                groupCard(title: "Identifiers", color: TeamMemberTheme.blue, icon: "number") {
                    VStack(alignment: .leading, spacing: 10) {
                        TeamMemberDetailFieldRow(label: "ID", value: member.id.uuidString, systemImage: "number.circle", color: TeamMemberTheme.blue)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(TeamMemberTheme.bgGrouped.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Team Member", displayMode: .inline)
    }

    @ViewBuilder
    private func groupCard<Content: View>(title: String, color: Color, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.subheadline).bold()
            }
            .padding(.horizontal, 12).padding(.top, 12)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14).fill(TeamMemberTheme.bgCard))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(TeamMemberTheme.separator, lineWidth: 0.5))
        }
    }
}
