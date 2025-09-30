import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberAddDatePickerView: View {
    let title: String
    let systemImage: String
    let color: Color
    @Binding var date: Date

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundColor(color)
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
                    .accessibilityLabel(Text(title))
            }
            Spacer()
        }
        .padding()
        .background(TeamMemberTheme.bgCard)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
