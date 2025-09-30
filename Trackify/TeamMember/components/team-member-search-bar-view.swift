import SwiftUI

@available(iOS 14.0, *)
struct TeamMemberSearchBarView: View {
    @Binding var text: String
    @State private var isEditing: Bool = false

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(TeamMemberTheme.indigo)
                TextField("Search name, role, email, tags", text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) { isEditing = editing }
                })
                .textContentType(.name)
                .disableAutocorrection(true)
                if !text.isEmpty {
                    Button(action: { self.text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(TeamMemberTheme.labelSecondary)
                    }
                    .accessibilityLabel(Text("Clear search"))
                }
            }
            .padding(8)
            .background(TeamMemberTheme.bgCard)
            .cornerRadius(12)

            if isEditing {
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isEditing = false
                        self.text = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .foregroundColor(TeamMemberTheme.blue)
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
