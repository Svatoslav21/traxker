import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberTheme {
    static let blue = Color(#colorLiteral(red: 0.14, green: 0.43, blue: 0.85, alpha: 1))     // Primary
    static let indigo = Color(#colorLiteral(red: 0.35, green: 0.36, blue: 0.86, alpha: 1))   // Accent
    static let green = Color(#colorLiteral(red: 0.17, green: 0.72, blue: 0.47, alpha: 1))    // Success
    static let orange = Color(#colorLiteral(red: 1.0, green: 0.59, blue: 0.18, alpha: 1))    // Warning
    static let red = Color(#colorLiteral(red: 0.93, green: 0.23, blue: 0.21, alpha: 1))      // Danger
    static let bgCard = Color(.secondarySystemBackground)
    static let bgGrouped = Color(.systemGroupedBackground)
    static let labelSecondary = Color(.secondaryLabel)
    static let separator = Color(.separator)
}

@available(iOS 14.0, *)
struct CapsuleTag: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(Capsule())
            .accessibilityLabel(Text(text))
    }
}
