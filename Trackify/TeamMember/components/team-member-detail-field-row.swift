import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberDetailFieldRow: View {
    let label: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(color)
                .frame(width: 18)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(TeamMemberTheme.labelSecondary)
                Text(value).font(.callout)
            }
            Spacer(minLength: 0)
        }
    }
}
