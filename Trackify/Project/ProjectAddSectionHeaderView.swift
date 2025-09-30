
import SwiftUI

@available(iOS 14.0, *)
struct ProjectAddSectionHeaderView: View {
    let title: String
    let subtitle: String?
    let systemImage: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.blue)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.12))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

@available(iOS 14.0, *)
struct ProjectAddFieldView: View {
    let label: String
    let systemImage: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default

    @Binding var text: String
    @State private var isFocused: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            // Field container
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))

//            // Floating label
//            Text(label)
//                .font(.footnote)
//                .foregroundColor(isFocused || !text.isEmpty ? .blue : .secondary)
//                .scaleEffect(isFocused || !text.isEmpty ? 0.9 : 1.0, anchor: .leading)
//                .offset(y: (isFocused || !text.isEmpty) ? -22 : 0)
//                .padding(.leading, 44)
//                .animation(.easeInOut(duration: 0.2), value: isFocused || !text.isEmpty)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .frame(width: 28, height: 28)
                    .accessibilityHidden(true)

                // Using onEditingChanged for iOS 14 focus events
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = editing
                    }
                })
                .keyboardType(keyboardType)
                .textContentType(.none)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(label))
    }
}

@available(iOS 14.0, *)
struct ProjectAddDatePickerView: View {
    let label: String
    let systemImage: String
    @Binding var date: Date

    var body: some View {
        VStack(spacing: 8) {
            ProjectAddSectionHeaderView(title: label, subtitle: nil, systemImage: systemImage)
            DatePicker("", selection: $date, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle()) // iOS 14
                .labelsHidden()
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
        }
        .accessibilityElement(children: .combine)
    }
}

@available(iOS 14.0, *)
struct ProjectAddToggleView: View {
    let label: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
                .frame(width: 28, height: 28)
            Toggle(label, isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
    }
}
