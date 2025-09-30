import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberListRowView: View {
    let member: TeamMember

    private var name: String { "\(member.firstName) \(member.lastName)" }
    private var skillsText: String { member.skills.prefix(4).joined(separator: ", ") + (member.skills.count > 4 ? " +" : "") }
    private var tagsText: String { member.tags.prefix(4).joined(separator: ", ") + (member.tags.count > 4 ? " +" : "") }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: member.isAvailable ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 28))
                    .foregroundColor(member.isAvailable ? TeamMemberTheme.green : TeamMemberTheme.orange)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name).font(.headline)
                    Text(member.role).font(.subheadline).foregroundColor(TeamMemberTheme.labelSecondary)
                }
                Spacer()
                CapsuleTag(text: member.status, color: member.isActive ? TeamMemberTheme.green : TeamMemberTheme.red)
            }

            Divider()

            // Info grid (shows 15+ fields)
            VStack(alignment: .leading, spacing: 8) {
                iconRow("envelope.fill", color: TeamMemberTheme.indigo, text: member.email)
                iconRow("phone.fill", color: TeamMemberTheme.green, text: member.phone)
                iconRow("briefcase.fill", color: TeamMemberTheme.blue, text: member.department)
                iconRow("mappin.and.ellipse", color: TeamMemberTheme.orange, text: "\(member.location) • \(member.timezone)")
                iconRow("globe", color: TeamMemberTheme.indigo, text: member.language)
                iconRow("wrench.and.screwdriver.fill", color: TeamMemberTheme.orange, text: "Skills: \(skillsText)")
                iconRow("tag.fill", color: TeamMemberTheme.red, text: "Tags: \(tagsText)")
                iconRow("clock.fill", color: TeamMemberTheme.blue, text: "Joined: \(Fmt.dateShort.string(from: member.joinedAt))")
                iconRow("calendar.badge.clock", color: TeamMemberTheme.blue, text: "Last Login: \(Fmt.date.string(from: member.lastLogin))")
                iconRow("person.2.fill", color: TeamMemberTheme.indigo, text: "Team Size Links: P \(member.projectIds.count) • T \(member.taskIds.count)")
                iconRow("dollarsign.circle", color: TeamMemberTheme.green, text: "Rate: \(Int(member.hourlyRate))/hr • \(member.weeklyHours)h/w")
                iconRow("star.fill", color: TeamMemberTheme.orange, text: "Performance: \(member.performanceRating)/5")
                iconRow("chart.bar.doc.horizontal.fill", color: TeamMemberTheme.blue, text: "Login Count: \(member.loginCount)")
                iconRow("cross.case.fill", color: TeamMemberTheme.red, text: "Vac: \(member.vacationDays) • Sick: \(member.sickDays)")
                iconRow("note.text", color: TeamMemberTheme.indigo, text: member.notes.isEmpty ? "No notes" : member.notes)
            }

        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(TeamMemberTheme.bgCard))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(TeamMemberTheme.separator, lineWidth: 0.5))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(name))
    }

    @ViewBuilder
    private func iconRow(_ symbol: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol).foregroundColor(color).frame(width: 18)
            Text(text).font(.callout)
            Spacer()
        }
    }
}
