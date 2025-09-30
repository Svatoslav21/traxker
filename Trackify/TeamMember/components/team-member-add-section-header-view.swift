import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberAddSectionHeaderView: View {
    let title: String
    let systemImage: String
    let color: Color
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: systemImage)
                    .foregroundColor(color)
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }
}
