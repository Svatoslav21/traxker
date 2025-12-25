import SwiftUI
import FamilyControls

struct ScheduleEditorView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var blockManager = AppBlockManager.shared
    
    @State private var name: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var isRepeating: Bool
    @State private var repeatDays: Set<Int>
    @State private var showingAppPicker = false
    @State private var selection = FamilyActivitySelection()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let scheduleId: UUID?
    
    init(schedule: BlockSchedule, navigationPath: Binding<NavigationPath>) {
        _name = State(initialValue: schedule.name)
        _startTime = State(initialValue: schedule.startTime)
        _endTime = State(initialValue: schedule.endTime)
        _isRepeating = State(initialValue: schedule.isRepeating)
        _repeatDays = State(initialValue: schedule.repeatDays)
        scheduleId = schedule.id
        _navigationPath = navigationPath
    }
    
    var body: some View {
        ZStack {
            ThemeBackgroundView()
                .ignoresSafeArea()
            
            Form {
                Section {
                    TextField("Block Name".localized, text: $name)
                        .foregroundStyle(AppColors.primaryText)
                    
                    DatePicker("Start Time".localized, selection: $startTime, displayedComponents: .hourAndMinute)
                        .foregroundStyle(AppColors.primaryText)
                    
                    DatePicker("End Time".localized, selection: $endTime, displayedComponents: .hourAndMinute)
                        .foregroundStyle(AppColors.primaryText)
                } header: {
                    Text("Block Details".localized)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Section {
                    Toggle("Repeat".localized, isOn: $isRepeating)
                        .foregroundStyle(AppColors.primaryText)
                    
                    if isRepeating {
                        DayPicker(selectedDays: $repeatDays)
                    }
                } header: {
                    Text("Repeat".localized)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Section {
                    Button(action: {
                        Task { @MainActor in
                            // Проверяем авторизацию перед открытием пикера
                            if !blockManager.isAuthorized {
                                await blockManager.requestAuthorization()
                            }
                            
                            // Открываем пикер только если авторизация предоставлена
                            if blockManager.isAuthorized {
                                showingAppPicker = true
                            } else {
                                alertMessage = "You need to provide Screen Time permission to select apps. Go to Settings and provide permission.".localized
                                showingAlert = true
                            }
                        }
                    }) {
                        HStack {
                            Text("Select Apps".localized)
                                .foregroundStyle(AppColors.primaryText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppColors.tertiaryText)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if !selection.applicationTokens.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.success)
                            Text("\(selection.applicationTokens.count) app(s) selected".localized)
                                .font(.subheadline)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                } header: {
                    Text("Blocked Apps".localized)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Section {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        saveSchedule()
                    }) {
                        Text("Save Schedule".localized)
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .background(AppColors.primaryGradient)
                            .cornerRadius(12)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit Schedule".localized)
            .navigationBarTitleDisplayMode(.inline)
            .familyActivityPicker(isPresented: $showingAppPicker, selection: $selection)
            .onAppear {
                selection = blockManager.selectionToRestrict
            }
            .onChange(of: selection) { oldValue, newValue in
                // Сохраняем выбор приложений при изменении
                blockManager.saveSelection(newValue)
            }
            .alert("Error".localized, isPresented: $showingAlert) {
                Button("OK".localized, role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveSchedule() {
        // Валидация времени
        guard startTime < endTime else {
            alertMessage = "Start time must be earlier than end time.".localized
            showingAlert = true
            return
        }
        
        // Валидация имени
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Schedule name cannot be empty.".localized
            showingAlert = true
            return
        }
        
        // Валидация повторяющихся дней
        if isRepeating && repeatDays.isEmpty {
            alertMessage = "Repeating schedule must have at least one selected day.".localized
            showingAlert = true
            return
        }
        
        // Сохраняем выбор приложений
        blockManager.saveSelection(selection)
        
        let success: Bool
        if let id = scheduleId, blockManager.schedules.contains(where: { $0.id == id }) {
            let existingSchedule = blockManager.schedules.first(where: { $0.id == id })!
            let updatedSchedule = BlockSchedule(
                id: id,
                name: name.trimmingCharacters(in: .whitespaces),
                startTime: startTime,
                endTime: endTime,
                isRepeating: isRepeating,
                repeatDays: repeatDays,
                isActive: existingSchedule.isActive,
                selectionIdentifier: existingSchedule.selectionIdentifier
            )
            success = blockManager.updateSchedule(updatedSchedule)
        } else {
            let schedule = BlockSchedule(
                name: name.trimmingCharacters(in: .whitespaces),
                startTime: startTime,
                endTime: endTime,
                isRepeating: isRepeating,
                repeatDays: repeatDays,
                isActive: true,
                selectionIdentifier: nil
            )
            success = blockManager.addSchedule(schedule)
        }
        
        if success {
            navigationPath.removeLast()
        } else {
            alertMessage = "Failed to save schedule. Schedule with this name may already exist.".localized
            showingAlert = true
        }
    }
}

struct DayPicker: View {
    @Binding var selectedDays: Set<Int>
    
    private var days: [(Int, String)] {
        [
            (1, "Mon".localized),
            (2, "Tue".localized),
            (3, "Wed".localized),
            (4, "Thu".localized),
            (5, "Fri".localized),
            (6, "Sat".localized),
            (7, "Sun".localized)
        ]
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.0) { day in
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    if selectedDays.contains(day.0) {
                        selectedDays.remove(day.0)
                    } else {
                        selectedDays.insert(day.0)
                    }
                }) {
                    Text(day.1)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedDays.contains(day.0) 
                                ? AppColors.accent 
                                : AppColors.cardBackground
                        )
                        .foregroundColor(
                            selectedDays.contains(day.0) 
                                ? .white 
                                : AppColors.primaryText
                        )
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
