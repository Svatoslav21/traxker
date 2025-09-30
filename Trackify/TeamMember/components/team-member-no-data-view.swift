import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberNoDataView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(TeamMemberTheme.indigo.opacity(0.12)).frame(width: 140, height: 140)
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 56))
                    .foregroundColor(TeamMemberTheme.indigo)
            }
            Text("No Team Members")
                .font(.title3).bold()
            Text("Tap the + button to add your first team member.")
                .font(.subheadline)
                .foregroundColor(TeamMemberTheme.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 40)
        .accessibilityElement(children: .combine)
    }
}
