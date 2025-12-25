import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import OSLog

@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    private let logger = Logger(subsystem: "com.danielian.selfcontrol.dopaminedetox", category: "ScreenTimeManager")
    
    @Published var dailyScreenTime: TimeInterval = 0
    @Published var weeklyScreenTime: TimeInterval = 0
    @Published var monthlyScreenTime: TimeInterval = 0
    @Published var dailyPickups: Int = 0
    @Published var weeklyPickups: Int = 0
    @Published var monthlyPickups: Int = 0
    @Published var appUsageStats: [AppUsageStat] = []
    
    private let deviceActivityCenter = DeviceActivityCenter()
    
    init() {
        loadScreenTimeData()
    }
    
    // Загрузка статистики Screen Time
    func loadScreenTimeData() {
        Task {
            await updateDailyStats()
            await updateWeeklyStats()
            await updateMonthlyStats()
            await updatePickupsStats()
            await updateAppUsageStats()
        }
    }
    
    // Обновление дневной статистики
    private func updateDailyStats() async {
        // Примечание: для получения реальных данных Screen Time нужна настройка DeviceActivityMonitor
        // Пока используем общее накопленное время как приблизительную статистику
        // В идеале нужно хранить статистику по дням отдельно
        let blockManager = AppBlockManager.shared
        self.dailyScreenTime = blockManager.savedTime.totalSeconds
        logger.info("📊 Daily stats updated: \(self.dailyScreenTime) seconds")
    }
    
    // Обновление недельной статистики
    private func updateWeeklyStats() async {
        // Примечание: сейчас используется общее накопленное время
        // В реальном приложении нужно хранить историю по дням и суммировать за последние 7 дней
        // Пока показываем то же самое время, что и дневная статистика
        let blockManager = AppBlockManager.shared
        self.weeklyScreenTime = blockManager.savedTime.totalSeconds
        logger.info("📊 Weekly stats updated: \(self.weeklyScreenTime) seconds")
    }
    
    // Обновление месячной статистики
    private func updateMonthlyStats() async {
        // Примечание: сейчас используется общее накопленное время
        // В реальном приложении нужно хранить историю по дням и суммировать за последние 30 дней
        // Пока показываем то же самое время, что и дневная статистика
        let blockManager = AppBlockManager.shared
        self.monthlyScreenTime = blockManager.savedTime.totalSeconds
        logger.info("📊 Monthly stats updated: \(self.monthlyScreenTime) seconds")
    }
    
    // Обновление статистики Pickups
    private func updatePickupsStats() async {
        // Примечание: Pickups статистика требует дополнительной настройки DeviceActivityMonitor
        // Пока оставляем 0, так как нет реальных данных
        self.dailyPickups = 0
        self.weeklyPickups = 0
        self.monthlyPickups = 0
        logger.info("📱 Pickups stats updated (requires DeviceActivityMonitor setup)")
    }
    
    // Обновление статистики по приложениям
    private func updateAppUsageStats() async {
        // Статистика по приложениям будет собираться на основе выбранных приложений
        let blockManager = AppBlockManager.shared
        let selectedApps = blockManager.selectionToRestrict.applicationTokens
        
        var stats: [AppUsageStat] = []
        for token in selectedApps {
            // Здесь можно получить детальную статистику по каждому приложению
            // Но для этого нужна дополнительная настройка DeviceActivityMonitor
            stats.append(AppUsageStat(
                token: token,
                usageTime: 0, // Будет заполнено через DeviceActivityMonitor
                pickups: 0
            ))
        }
        
        appUsageStats = stats
        logger.info("📱 App usage stats updated: \(stats.count) apps")
    }
    
    // Форматирование времени для отображения
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    // Получение среднего значения за день
    func getDailyAverage(for timeInterval: TimeInterval, days: Int) -> TimeInterval {
        guard days > 0 else { return 0 }
        return timeInterval / Double(days)
    }
    
    // Получение времени для выбранного периода
    func getTimeForPeriod(_ period: TimePeriod) -> TimeInterval {
        switch period {
        case .today:
            return dailyScreenTime
        case .thisWeek:
            return weeklyScreenTime
        case .thisMonth:
            return monthlyScreenTime
        }
    }
}

// Модель для статистики использования приложения
struct AppUsageStat: Identifiable {
    let id = UUID()
    let token: ApplicationToken
    var usageTime: TimeInterval
    var pickups: Int
    
    var formattedTime: String {
        let hours = Int(usageTime) / 3600
        let minutes = (Int(usageTime) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }
}

