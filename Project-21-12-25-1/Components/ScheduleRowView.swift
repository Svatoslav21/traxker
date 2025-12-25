import SwiftUI
import FamilyControls

struct ScheduleRowView: View {
    let schedule: BlockSchedule
    let selection: FamilyActivitySelection
    let onTap: () -> Void
    let onStart: () -> Void
    let onPause: () -> Void
    let onDelete: () -> Void
    @StateObject private var blockManager = AppBlockManager.shared
    
    private var isActive: Bool {
        blockManager.isBlockingActive && blockManager.activeBlock?.id == schedule.id
    }
    
    private var isPaused: Bool {
        isActive && blockManager.isPaused
    }
    
    var body: some View {
        
        VStack {
            VStack(spacing: 0) {
                // Часть 1: Pause/Start Block
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    if isActive {
                        onPause()
                    } else {
                        onStart()
                    }
                }) {
                    HStack(spacing: 16) {
                        // Иконка в зависимости от состояния
                        Image(systemName: buttonIcon)
                            .font(.title3)
                            .foregroundStyle(AppColors.accent)
                        
                        // Текст в зависимости от состояния
                        Text(buttonText)
                            .font(.body)
                            .foregroundStyle(AppColors.accent)
                            .underline()
                        
                        Spacer()
                        
                        // Стрелка
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppColors.tertiaryText)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                
                // Разделитель
                Divider()
                    .padding(.horizontal, 20)
                
                // Часть 2: Schedule Session
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    onTap()
                }) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Название расписания
                        Text(schedule.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.primaryText)
                        
                        // Иконки приложений и информация
                        let appCount = selection.applicationTokens.count
                        let categoryCount = selection.webDomainTokens.count
                        
                        HStack(spacing: 12) {
                            // Иконки приложений (до 7)
                            ForEach(0..<min(7, appCount), id: \.self) { index in
                                Circle()
                                    .fill(AppColors.secondaryText.opacity(0.3))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "app.fill")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.secondaryText)
                                    )
                            }
                            
                            // Многоточие если больше 7
                            if appCount > 7 {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(AppColors.secondaryText.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text("...")
                                            .font(.caption2)
                                            .foregroundStyle(AppColors.secondaryText)
                                    )
                            }
                            
                            Spacer()
                            
                            // Иконка календаря и стрелка
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundStyle(AppColors.accent)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppColors.tertiaryText)
                        }
                        
                        // Текст с количеством
                        if categoryCount > 0 {
                            Text("\(categoryCount) category, \(appCount) apps")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        } else {
                            Text("\(appCount) apps")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        
                        // Время блокировки (если активно)
                        if isActive {
                            Text("Blocking • \(timeRangeText)")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        } else {
                            Text(timeRangeText)
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
            }
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 8)
            
            HStack {
                Text("<<< SWIPE TO DELETE")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
            }
            .padding(.horizontal)
        }

    }
    
    private var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: schedule.startTime)) - \(formatter.string(from: schedule.endTime))"
    }
    
    // Текст кнопки в зависимости от состояния
    private var buttonText: String {
        if isActive {
            // Если блокировка активна
            if isPaused {
                return "Resume".localized
            } else {
                return "Pause Block".localized
            }
        } else {
            // Если блокировка не активна
            return "Start Block".localized
        }
    }
    
    // Иконка кнопки в зависимости от состояния
    private var buttonIcon: String {
        if isActive {
            // Если блокировка активна
            if isPaused {
                return "play.circle.fill" // Resume
            } else {
                return "pause.circle.fill" // Pause
            }
        } else {
            // Если блокировка не активна
            return "play.circle.fill" // Start
        }
    }
}

