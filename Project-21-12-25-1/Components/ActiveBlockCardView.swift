import SwiftUI
import FamilyControls

// Карточка активного блока
struct ActiveBlockCardView: View {
    let schedule: BlockSchedule
    let selection: FamilyActivitySelection
    let isPaused: Bool
    let onPause: () -> Void
    let onScheduleTap: () -> Void
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с зеленой точкой
            HStack(spacing: 8) {
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 8, height: 8)
                
                Text("BLOCKING APPS".localized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.secondaryText)
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Карточка
            VStack(spacing: 0) {
                // Часть 1: Pause/Start Block
                Button(action: {
                    onPause()
                }) {
                    HStack(spacing: 16) {
                        // Иконка паузы/продолжить
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.accent)
                            .frame(width: 32, height: 32)
                        
                        // Текст
                        Text(isPaused ? "Start Block".localized : "Pause Block".localized)
                            .font(.body)
                            .foregroundStyle(AppColors.accent)
                        
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
                    onScheduleTap()
                }) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Заголовок
                        Text("Schedule Session".localized)
                            .font(.headline)
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
                        
                        // Время блокировки
                        Text("Blocking • \(remainingTimeText)")
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
            }
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private var remainingTimeText: String {
        let now = currentTime
        
        // Вычисляем оставшееся время до endTime расписания
        let remaining = max(0, schedule.endTime.timeIntervalSince(now))
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

