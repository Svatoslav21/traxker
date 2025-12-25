import SwiftUI
import FamilyControls

struct ReportView: View {
    @StateObject private var blockManager = AppBlockManager.shared
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var paywallManager = PaywallManager.shared
    @State private var selectedPeriod: TimePeriod = .today
    @State private var weekOffset: Int = 0 // Смещение для навигации по неделям
    @State private var monthOffset: Int = 0 // Смещение для навигации по месяцам
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackgroundView()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Period Selector с навигацией
                        PeriodSelectorWithNavigationView(
                            selectedPeriod: $selectedPeriod,
                            weekOffset: $weekOffset,
                            monthOffset: $monthOffset,
                            subscriptionManager: subscriptionManager,
                            paywallManager: paywallManager
                        )
                        
                        // SUMMARY Section
                        SummaryView(
                            period: selectedPeriod,
                            weekOffset: weekOffset,
                            monthOffset: monthOffset,
                            screenTimeManager: screenTimeManager
                        )
                        
                        // SCREEN TIME PER DAY
                        ScreenTimePerDayView(
                            period: selectedPeriod,
                            weekOffset: weekOffset,
                            monthOffset: monthOffset,
                            screenTimeManager: screenTimeManager
                        )
                        
                        // MOST TIME PER APP
                        MostTimePerAppView(blockManager: blockManager)
                    }
                    .padding()
                }
            }
            .navigationTitle("Report".localized)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                screenTimeManager.loadScreenTimeData()
                // Если выбран премиум период, но нет подписки - переключаем на Day
                if !subscriptionManager.isPremium && (selectedPeriod == .thisWeek || selectedPeriod == .thisMonth) {
                    selectedPeriod = .today
                }
            }
            .onChange(of: subscriptionManager.isPremium) { oldValue, newValue in
                // Если подписка истекла и выбран премиум период - переключаем на Day
                if !newValue && (selectedPeriod == .thisWeek || selectedPeriod == .thisMonth) {
                    selectedPeriod = .today
                }
            }
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case today = "Day"
    case thisWeek = "Week"
    case thisMonth = "Month"
    
    var localized: String {
        return rawValue.localized
    }
}

// Period Selector с навигацией
struct PeriodSelectorWithNavigationView: View {
    @Binding var selectedPeriod: TimePeriod
    @Binding var weekOffset: Int
    @Binding var monthOffset: Int
    @ObservedObject var subscriptionManager: SubscriptionManager
    @ObservedObject var paywallManager: PaywallManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Сегментированный контрол с поддержкой блокировки
            HStack(spacing: 8) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                    PeriodButton(
                        period: period,
                        isSelected: selectedPeriod == period,
                        isLocked: isPeriodLocked(period),
                        onTap: {
                            handlePeriodSelection(period)
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            // Навигация стрелками (только для премиум)
            if selectedPeriod != .today && subscriptionManager.isPremium {
                HStack {
                    // Текст периода
                    Text(getPeriodText())
                        .font(.subheadline)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    // Стрелки навигации
                    HStack(spacing: 16) {
                        Button(action: {
                            if selectedPeriod == .thisWeek {
                                weekOffset -= 1
                            } else if selectedPeriod == .thisMonth {
                                monthOffset -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundStyle(AppColors.accent)
                        }
                        
                Button(action: {
                            if selectedPeriod == .thisWeek {
                                weekOffset += 1
                            } else if selectedPeriod == .thisMonth {
                                monthOffset += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundStyle(selectedPeriod == .thisMonth && monthOffset >= 0 ? AppColors.secondaryText : AppColors.accent)
                        }
                        .disabled(selectedPeriod == .thisMonth && monthOffset >= 0)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getPeriodText() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if selectedPeriod == .thisWeek {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfDay(for: now)) ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? now
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
        } else if selectedPeriod == .thisMonth {
            let monthStart = calendar.date(byAdding: .month, value: monthOffset, to: calendar.startOfDay(for: now)) ?? now
            let monthEnd = calendar.date(byAdding: .day, value: -1, to: calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart) ?? monthStart
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            return "\(formatter.string(from: monthStart)) - \(formatter.string(from: monthEnd))"
        }
        return ""
    }
    
    // Проверка, заблокирован ли период
    private func isPeriodLocked(_ period: TimePeriod) -> Bool {
        if period == .today {
            return false // Day всегда доступен
        }
        return !subscriptionManager.isPremium
    }
    
    // Обработка выбора периода
    private func handlePeriodSelection(_ period: TimePeriod) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if isPeriodLocked(period) {
            // Открываем Paywall
            paywallManager.showPaywall(placementId: PaywallManager.Placement.main.rawValue)
            FirebaseTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
            AppsFlyerTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
        } else {
                    selectedPeriod = period
        }
    }
}

// Кнопка периода с поддержкой блокировки
struct PeriodButton: View {
    let period: TimePeriod
    let isSelected: Bool
    let isLocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            // Всегда вызываем onTap - внутри будет проверка блокировки
            onTap()
        }) {
            HStack(spacing: 6) {
                    Text(period.localized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                }
            }
            .foregroundColor(isSelected ? .white : (isLocked ? AppColors.secondaryText : AppColors.primaryText))
            .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                Group {
                    if isSelected {
                        AppColors.accent
                    } else if isLocked {
                        AppColors.cardBackground.opacity(0.5)
                    } else {
                        AppColors.cardBackground
                    }
                }
                        )
                        .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isLocked ? AppColors.secondaryText.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        // Убрали .disabled() - кнопки всегда кликабельны
    }
}

// SUMMARY Section
struct SummaryView: View {
    let period: TimePeriod
    let weekOffset: Int
    let monthOffset: Int
    @ObservedObject var screenTimeManager: ScreenTimeManager
    
    var screenTime: TimeInterval {
        switch period {
        case .today:
            return screenTimeManager.dailyScreenTime
        case .thisWeek:
            return screenTimeManager.weeklyScreenTime
        case .thisMonth:
            return screenTimeManager.monthlyScreenTime
        }
    }
    
    var daysCount: Int {
        switch period {
        case .today:
            return 1
        case .thisWeek:
            return 7
        case .thisMonth:
            return Calendar.current.range(of: .day, in: .month, for: getPeriodStartDate())?.count ?? 30
        }
    }
    
    var dateRangeText: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        
        let startDate = getPeriodStartDate()
        let endDate = getPeriodEndDate(startDate: startDate)
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    private func getPeriodStartDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .today:
            return calendar.startOfDay(for: now)
        case .thisWeek:
            return calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfDay(for: now)) ?? now
        case .thisMonth:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.date(byAdding: .month, value: monthOffset, to: now) ?? now)) ?? now
    }
}

    private func getPeriodEndDate(startDate: Date) -> Date {
        let calendar = Calendar.current
        
        switch period {
        case .today:
            return startDate
        case .thisWeek:
            return calendar.date(byAdding: .day, value: 6, to: startDate) ?? startDate
        case .thisMonth:
            return calendar.date(byAdding: .day, value: -1, to: calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate) ?? startDate
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            Text("SUMMARY".localized)
                .font(.headline)
                .foregroundStyle(AppColors.secondaryText)
                .textCase(.uppercase)
            
            // Карточка
            VStack(alignment: .leading, spacing: 16) {
                // Диапазон дат
                Text(dateRangeText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                
                // Total Screen Time
                Text(formatTime(screenTime))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(AppColors.primaryText)
                
                // Daily Average (если не сегодня)
                if period != .today {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DAILY AVERAGE".localized)
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                            .textCase(.uppercase)
                        
                        Text(formatTime(screenTime / Double(daysCount)))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(AppColors.primaryText)
                    }
                }
                
                // Label
                Text("SCREEN TIME".localized)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .cardMaterial()
        }
        .padding(.horizontal)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// SCREEN TIME PER DAY
struct ScreenTimePerDayView: View {
    let period: TimePeriod
    let weekOffset: Int
    let monthOffset: Int
    @ObservedObject var screenTimeManager: ScreenTimeManager
    
    var daysCount: Int {
        switch period {
        case .today:
            return 1
        case .thisWeek:
            return 7
        case .thisMonth:
            return Calendar.current.range(of: .day, in: .month, for: getPeriodStartDate())?.count ?? 30
        }
    }
    
    private func getPeriodStartDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .today:
            return calendar.startOfDay(for: now)
        case .thisWeek:
            return calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfDay(for: now)) ?? now
        case .thisMonth:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.date(byAdding: .month, value: monthOffset, to: now) ?? now)) ?? now
        }
    }
    
    private func getDayName(for index: Int) -> String {
        if period == .thisWeek {
            let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            return dayNames[index].localized
        } else {
            return "\(index + 1)"
        }
    }
    
    private func getTimeForDay(_ index: Int) -> TimeInterval {
        let totalTime = screenTimeManager.getTimeForPeriod(period)
        return totalTime / Double(daysCount)
    }
    
    private func getMaxTime() -> TimeInterval {
        let totalTime = screenTimeManager.getTimeForPeriod(period)
        return max(totalTime / Double(daysCount), 1.0) // Минимум 1 секунда для избежания деления на 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            Text("SCREEN TIME PER DAY".localized)
                .font(.headline)
                .foregroundStyle(AppColors.secondaryText)
                .textCase(.uppercase)
            
            if period == .today {
                // Для сегодня просто показываем значение
                VStack(alignment: .leading, spacing: 8) {
                    Text(formatTime(getTimeForDay(0)))
                        .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)
            }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .cardMaterial()
            } else {
                // График с барами
                VStack(spacing: 12) {
                    ForEach(0..<daysCount, id: \.self) { index in
                        HStack(spacing: 12) {
                            // Название дня
                            Text(getDayName(for: index))
                                .font(.subheadline)
                                .foregroundStyle(AppColors.primaryText)
                                .frame(width: 40, alignment: .leading)
                            
                            // Бар
                            GeometryReader { geometry in
                                let dayTime = getTimeForDay(index)
                                let maxTime = getMaxTime()
                                let widthRatio = maxTime > 0 ? min(1.0, dayTime / maxTime) : 0.0
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.secondaryText.opacity(0.2))
                                        .frame(height: 24)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.accent)
                                        .frame(width: geometry.size.width * CGFloat(widthRatio), height: 24)
                            }
                            }
                            .frame(height: 24)
                            
                            // Время
                            Text(formatTimeShort(getTimeForDay(index)))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.primaryText)
                                .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .padding(20)
        .cardMaterial()
            }
        }
        .padding(.horizontal)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
            }
        }
    
    private func formatTimeShort(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let minutesDecimal = Double(minutes) + (Double(Int(time) % 3600) / 60.0 - Double(minutes))
        
        if hours > 0 {
            return String(format: "%.1fh", Double(hours) + minutesDecimal / 60.0)
        } else {
            return "\(minutes)m"
        }
    }
}

// MOST TIME PER APP
struct MostTimePerAppView: View {
    @ObservedObject var blockManager: AppBlockManager
    
    var appCount: Int {
        blockManager.selectionToRestrict.applicationTokens.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            Text("MOST TIME PER APP".localized)
                .font(.headline)
                .foregroundStyle(AppColors.secondaryText)
                .textCase(.uppercase)
            
            if appCount == 0 {
                // Пустое состояние
            VStack(spacing: 12) {
                    Text("No app usage data available".localized)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .cardMaterial()
            } else {
                // Список приложений
                VStack(spacing: 0) {
                    ForEach(0..<appCount, id: \.self) { index in
                        AppUsageRowView(
                            index: index,
                            totalApps: appCount
                        )
                        
                        if index < appCount - 1 {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .cardMaterial()
                
                // Show More button (если больше 5 приложений)
                if appCount > 5 {
                    Button(action: {
                        // Действие для показа всех приложений
                    }) {
                        Text("Show More".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
            }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal)
    }
}

// Строка использования приложения
struct AppUsageRowView: View {
    let index: Int
    let totalApps: Int
    
    // Используем общее накопленное время, разделенное между приложениями
    private var appTime: TimeInterval {
        let blockManager = AppBlockManager.shared
        let totalTime = blockManager.savedTime.totalSeconds
        // Равномерно распределяем время между приложениями
        return totalTime / Double(max(totalApps, 1))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка приложения
            Circle()
                .fill(AppColors.accent.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "app.fill")
                .font(.title3)
                .foregroundStyle(AppColors.accent)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                // Название приложения
                Text("App \(index + 1)")
                .font(.body)
                    .fontWeight(.medium)
                .foregroundStyle(AppColors.primaryText)
                
                // Время использования
                Text(formatTime(appTime))
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
            
            // Бар использования
            GeometryReader { geometry in
                let maxTime = AppBlockManager.shared.savedTime.totalSeconds
                let widthRatio = maxTime > 0 ? min(1.0, appTime / maxTime) : 0.0
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.accent)
                    .frame(width: geometry.size.width * CGFloat(widthRatio), height: 8)
            }
            .frame(width: 80, height: 8)
            
            // Pickups и Notifications
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(0) pickups".localized)
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryText)
                Text("\(0) notifications".localized)
                    .font(.caption2)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
        .padding(20)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}
