import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberAddFieldView: View {
    let title: String
    let systemImage: String
    let color: Color
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .words

    @State private var isFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 20)
                    .accessibilityHidden(true)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(TeamMemberTheme.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isFocused ? color : TeamMemberTheme.separator, lineWidth: isFocused ? 1.5 : 1)
                        )
                    ZStack(alignment: .leading) {
                        Text(title)
                            .font(.caption)
                            .foregroundColor(isFocused || !text.isEmpty ? color : TeamMemberTheme.labelSecondary)
                            .offset(y: (isFocused || !text.isEmpty) ? -18 : 0)
                            .scaleEffect((isFocused || !text.isEmpty) ? 0.92 : 1.0, anchor: .leading)
                            .animation(.easeInOut(duration: 0.2))
                        TextField("", text: $text, onEditingChanged: { editing in
                            isFocused = editing
                        })
                        .keyboardType(keyboard)
                        .autocapitalization(autocapitalization)
                        .padding(.top, (isFocused || !text.isEmpty) ? 12 : 0)
                        .accessibilityLabel(Text(title))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                .frame(height: 48)
            }
        }
        .padding(.horizontal)
    }
}
