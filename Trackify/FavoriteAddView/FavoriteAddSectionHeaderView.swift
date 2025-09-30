

import SwiftUI

@available(iOS 14.0, *)
struct FavoriteAddSectionHeaderView: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                Image(systemName: systemImage)
                    .foregroundColor(color)
                    .imageScale(.medium)
            }
            .frame(width: 36, height: 36)
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibility(label: Text(title))
    }
}

@available(iOS 14.0, *)
struct FavoriteAddFieldView: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    @State private var isFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
                    .frame(width: 20)
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(title)
                            .foregroundColor(.secondary)
                            .padding(.leading, 2)
                            .transition(.opacity)
                            .allowsHitTesting(false)
                    }
                    TextField("", text: $text, onEditingChanged: { editing in
                        withAnimation(.easeInOut(duration: 0.2)) { isFocused = editing }
                    })
                    .keyboardType(keyboard)
                    .textContentType(.none)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .accessibility(label: Text(title))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

@available(iOS 14.0, *)
struct FavoriteAddToggleView: View {
    let title: String
    let systemImage: String
    @Binding var value: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Toggle(title, isOn: $value)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}

@available(iOS 14.0, *)
struct FavoriteAddDatePickerView: View {
    let title: String
    let systemImage: String
    @Binding var date: Date
    var optional: Bool = false
    @Binding var isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
                    .frame(width: 20)
                Text(title)
                    .font(.subheadline).bold()
                Spacer()
                if optional {
                    Toggle("Enable", isOn: $isEnabled)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
            }
            .padding(.horizontal)
            if !optional || isEnabled {
                DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}

@available(iOS 14.0, *)
struct FavoriteSearchBarView: View {
    @Binding var text: String
    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .scaleEffect(isEditing ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2))
                TextField("Search favorites...", text: $text, onEditingChanged: { editing in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { isEditing = editing }
                })
                .textContentType(.none)
                .autocapitalization(.none)
                .disableAutocorrection(true)

                if isEditing  {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .transition(.opacity)
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEditing ? Color.accentColor : Color.clear, lineWidth: 1)
            )

            if isEditing {
                Button("Cancel") {
                    withAnimation(.easeInOut) {
                        text = ""
                        isEditing = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}



@available(iOS 14.0, *)
struct FavoriteNoDataView: View {
    @State private var spin = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 6, dash: [6, 8]))
                    .foregroundColor(Color.accentColor.opacity(0.25))
                    .frame(width: 120, height: 120)
                Image(systemName: "sparkles")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.accentColor)
                    .rotationEffect(.degrees(spin ? 5 : -5))
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true))
                    .onAppear { spin = true }
            }
            Text("No Favorites Found")
                .font(.headline)
            Text("Tap “+” to add a colorful, rich favorite with all details.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 40)
        .accessibilityElement(children: .combine)
        .accessibility(label: Text("No favorites found"))
    }
}

@available(iOS 14.0, *)
struct FavoriteDetailHeaderView: View {
    let favorite: Favorite

    private var accent: Color {
        Color(favorite.colorCode) ?? .blue
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(accent.opacity(0.12))
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accent.opacity(0.2))
                            .frame(width: 56, height: 56)
                        Image(systemName: favorite.iconName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(accent)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(favorite.aliasName.isEmpty ? favorite.itemType : favorite.aliasName)
                            .font(.title2).bold()
                        Text(favorite.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    Spacer()
                }
                HStack(spacing: 12) {
                    pill(text: favorite.visibility, system: "eye.fill")
                    pill(text: "Priority \(favorite.priority)", system: "exclamationmark.circle.fill")
                    pill(text: favorite.category, system: "folder.fill")
                }
            }
            .padding()
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private func pill(text: String, system: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: system)
            Text(text)
        }
        .font(.caption)
        .padding(.vertical, 6).padding(.horizontal, 10)
        .background(Capsule().fill(Color.white.opacity(0.7)))
        .foregroundColor(.primary)
        .accessibility(label: Text(text))
    }
}


@available(iOS 14.0, *)
struct FavoriteDetailFieldRow: View {
    let title: String
    let value: String
    let systemImage: String
    var highlight: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(highlight ? .accentColor : .secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption).foregroundColor(.secondary)
                Text(value.isEmpty ? "—" : value)
                    .font(.body).foregroundColor(.primary)
                    .lineLimit(nil)
            }
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(highlight ? Color.accentColor.opacity(0.08) : Color(UIColor.secondarySystemBackground))
        )
    }
}
