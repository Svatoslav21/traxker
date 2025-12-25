import Foundation
import FamilyControls
import ManagedSettings
import Combine
import OSLog
import UserNotifications

@MainActor
class AppBlockManager: ObservableObject {
    static let shared = AppBlockManager()
    
    // Logger для улучшенного логирования
    private let logger = Logger(subsystem: "com.danielian.selfcontrol.dopaminedetox", category: "AppBlockManager")
    
    @Published var authorizationCenter = AuthorizationCenter.shared
    @Published var isAuthorized = false
    @Published var activeBlock: BlockSchedule?
    @Published var schedules: [BlockSchedule] = []
    @Published var savedTime = SavedTime()
    @Published var isBlockingActive = false
    @Published var isPaused = false
    @Published var isGrayscaleModeEnabled = false
    @Published var shouldShowGrayscaleDialog = false // Триггер для показа диалога черно-белого режима
    
    // Хранилище выбранных приложений
    @Published var selectionToRestrict = FamilyActivitySelection()
    
    // Используем именованное хранилище для сохранения между запусками
    private let storeName = ManagedSettingsStore.Name("blockStore")
    private var blockStore: ManagedSettingsStore {
        ManagedSettingsStore(named: storeName)
    }
    
    private var scheduleTimer: Timer?
    private var timeTrackingTimer: Timer?
    private var pauseStartTime: Date?
    private var blockStartTime: Date?
    private var accumulatedTime: TimeInterval = 0 // Накопленное время до паузы
    
    private let savedTimeKey = "savedTime"
    private let schedulesKey = "blockSchedules"
    private let selectionTokensKey = "selectionTokens" // Сохраняем количество токенов для валидации
    private let activeBlockKey = "activeBlockId"
    private let isBlockingActiveKey = "isBlockingActive"
    private let isPausedKey = "isPaused"
    
    // App Group для сохранения данных между запусками
    private let appGroupIdentifier = "group.com.danielian.selfcontrol.dopaminedetox"
    private var sharedUserDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    init() {
        checkAuthorization()
        loadSavedTime()
        loadSchedules()
        loadSelection()
        restoreBlockState()
        startScheduleMonitoring()
        startTimeTracking()
    }
    
    deinit {
        scheduleTimer?.invalidate()
        timeTrackingTimer?.invalidate()
    }
    
    // Проверка авторизации Screen Time
    func checkAuthorization() {
        Task {
            do {
                let status = await authorizationCenter.authorizationStatus
                await MainActor.run {
                    isAuthorized = (status == .approved)
                    if isAuthorized {
                        logger.info("✅ Авторизация Screen Time предоставлена")
                    } else {
                        logger.warning("⚠️ Авторизация Screen Time не предоставлена")
                    }
                }
            }
        }
    }
    
    // Загрузка выбранных приложений
    // Примечание: FamilyActivitySelection не может быть сериализован напрямую
    // Но ManagedSettingsStore с именованным хранилищем сохраняет настройки между запусками
    // Выбор приложений восстанавливается из активного блокирующего хранилища
    private func loadSelection() {
        // Проверяем, есть ли активная блокировка в хранилище
        let defaults = sharedUserDefaults ?? UserDefaults.standard
        let savedTokenCount = defaults.integer(forKey: selectionTokensKey)
        
        if savedTokenCount > 0 {
            logger.info("ℹ️ Найдено сохраненное состояние блокировки с \(savedTokenCount) приложениями")
            // Токены будут восстановлены из ManagedSettingsStore при восстановлении блокировки
        } else {
            logger.info("ℹ️ Нет сохраненного выбора приложений")
        }
    }
    
    // Сохранение выбранных приложений
    func saveSelection(_ selection: FamilyActivitySelection) {
        selectionToRestrict = selection
        
        // Сохраняем количество токенов для валидации при восстановлении
        let defaults = sharedUserDefaults ?? UserDefaults.standard
        defaults.set(selection.applicationTokens.count, forKey: selectionTokensKey)
        defaults.synchronize()
        
        logger.info("✅ Выбор приложений сохранен: \(selection.applicationTokens.count) приложений, \(selection.webDomainTokens.count) доменов")
    }
    
    // Запрос авторизации
    func requestAuthorization() async {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            let status = await authorizationCenter.authorizationStatus
            await MainActor.run {
                isAuthorized = (status == .approved)
                if isAuthorized {
                    logger.info("✅ Авторизация успешно предоставлена")
                } else {
                    logger.warning("⚠️ Авторизация не предоставлена пользователем")
                }
            }
        } catch {
            await MainActor.run {
                isAuthorized = false
                logger.error("❌ Ошибка запроса авторизации: \(error.localizedDescription)")
            }
        }
    }
    
    // Загрузка сохраненного времени
    private func loadSavedTime() {
        if let data = UserDefaults.standard.data(forKey: savedTimeKey),
           let saved = try? JSONDecoder().decode(SavedTime.self, from: data) {
            savedTime = saved
        }
    }
    
    // Сохранение времени
    private func saveSavedTime() {
        if let data = try? JSONEncoder().encode(savedTime) {
            UserDefaults.standard.set(data, forKey: savedTimeKey)
        }
    }
    
    // Загрузка расписаний
    private func loadSchedules() {
        if let data = UserDefaults.standard.data(forKey: schedulesKey),
           let decoded = try? JSONDecoder().decode([BlockSchedule].self, from: data) {
            schedules = decoded
        }
    }
    
    // Сохранение расписаний
    private func saveSchedules() {
        if let data = try? JSONEncoder().encode(schedules) {
            UserDefaults.standard.set(data, forKey: schedulesKey)
        }
    }
    
    // Валидация расписания
    private func validateSchedule(_ schedule: BlockSchedule) -> Bool {
        // Проверка имени
        guard !schedule.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            logger.warning("⚠️ Расписание не может иметь пустое имя")
            return false
        }
        
        // Проверка времени
        guard schedule.startTime < schedule.endTime else {
            logger.warning("⚠️ Время начала должно быть раньше времени окончания")
            return false
        }
        
        // Проверка повторяющихся дней
        if schedule.isRepeating {
            guard !schedule.repeatDays.isEmpty else {
                logger.warning("⚠️ Повторяющееся расписание должно иметь хотя бы один день")
                return false
            }
        }
        
        return true
    }
    
    // Добавить расписание
    func addSchedule(_ schedule: BlockSchedule) -> Bool {
        guard validateSchedule(schedule) else {
            return false
        }
        
        // Проверка на дубликаты по имени
        if schedules.contains(where: { $0.name == schedule.name && $0.id != schedule.id }) {
            logger.warning("⚠️ Расписание с таким именем уже существует")
            return false
        }
        
        schedules.append(schedule)
        saveSchedules()
        logger.info("✅ Расписание добавлено: \(schedule.name)")
        return true
    }
    
    // Обновить расписание
    func updateSchedule(_ schedule: BlockSchedule) -> Bool {
        guard validateSchedule(schedule) else {
            return false
        }
        
        guard let index = schedules.firstIndex(where: { $0.id == schedule.id }) else {
            logger.warning("⚠️ Расписание не найдено для обновления")
            return false
        }
        
        // Проверка на дубликаты по имени
        if schedules.contains(where: { $0.name == schedule.name && $0.id != schedule.id }) {
            logger.warning("⚠️ Расписание с таким именем уже существует")
            return false
        }
        
        schedules[index] = schedule
        saveSchedules()
        logger.info("✅ Расписание обновлено: \(schedule.name)")
        return true
    }
    
    // Удалить расписание
    func deleteSchedule(_ schedule: BlockSchedule) {
        // Если удаляемое расписание активно, останавливаем блокировку
        if isBlockingActive && activeBlock?.id == schedule.id {
            stopBlock()
        }
        
        let countBefore = schedules.count
        schedules.removeAll { $0.id == schedule.id }
        if schedules.count < countBefore {
            saveSchedules()
            logger.info("✅ Расписание удалено: \(schedule.name)")
        }
    }
    
    // Начать блокировку
    func startBlock(schedule: BlockSchedule) -> Bool {
        guard isAuthorized else {
            logger.warning("⚠️ Блокировка не может быть начата: авторизация не предоставлена")
            return false
        }
        
        guard !selectionToRestrict.applicationTokens.isEmpty else {
            logger.warning("⚠️ Блокировка не может быть начата: не выбраны приложения")
            return false
        }
        
        // Останавливаем предыдущую блокировку, если есть
        if isBlockingActive, let currentBlock = activeBlock {
            logger.info("⏹️ Останавливаем предыдущую блокировку: \(currentBlock.name)")
            stopBlock()
        }
        
        activeBlock = schedule
        isBlockingActive = true
        isPaused = false
        
        if blockStartTime == nil {
            blockStartTime = Date()
            accumulatedTime = 0
        }
        
        pauseStartTime = nil
        
        // Сохраняем состояние блокировки
        saveBlockState()
        
        // Применяем блокировку через ManagedSettings
        logger.info("🔒 Начинаем блокировку \(self.selectionToRestrict.applicationTokens.count) приложений для расписания: \(schedule.name)")
        
        // Устанавливаем shield.applications - это блокирует приложения
        blockStore.shield.applications = self.selectionToRestrict.applicationTokens
        
        // Также блокируем веб-домены, если они выбраны
        if !self.selectionToRestrict.webDomainTokens.isEmpty {
            blockStore.shield.webDomains = self.selectionToRestrict.webDomainTokens
        }
        
        startTimeTracking()
        logger.info("✅ Блокировка активирована: \(schedule.name)")
        
        // Трекинг начала блокировки в AppsFlyer
        AppsFlyerTracker.trackBlockStart(blockName: schedule.name)
        
        return true
    }
    
    // Остановить блокировку
    func stopBlock() {
        guard isBlockingActive else { return }
        
        let blockName = activeBlock?.name ?? "Unknown"
        isBlockingActive = false
        isPaused = false
        
        // Сохраняем накопленное время
        if let startTime = blockStartTime {
            let currentDuration = Date().timeIntervalSince(startTime)
            if let pauseDuration = getPauseDuration() {
                accumulatedTime += currentDuration - pauseDuration
            } else {
                accumulatedTime += currentDuration
            }
            savedTime.totalSeconds += self.accumulatedTime
            saveSavedTime()
            logger.info("💾 Сохранено \(Int(self.accumulatedTime)) секунд блокировки")
        }
        
        // Снимаем блокировку
        logger.info("🔓 Снимаем блокировку: \(blockName)")
        blockStore.clearAllSettings()
        
        blockStartTime = nil
        pauseStartTime = nil
        accumulatedTime = 0
        activeBlock = nil
        
        // Очищаем сохраненное состояние
        clearBlockState()
        
        timeTrackingTimer?.invalidate()
        logger.info("✅ Блокировка снята: \(blockName)")
        
        // Трекинг завершения блокировки в AppsFlyer
        AppsFlyerTracker.trackBlockEnd(blockName: blockName, duration: accumulatedTime)
        
        // Отправляем уведомление о завершении блокировки
        NotificationManager.shared.sendBlockEndedNotification(blockName: blockName)
        
        // Показываем диалог для предложения черно-белого режима
        if !selectionToRestrict.applicationTokens.isEmpty {
            shouldShowGrayscaleDialog = true
        }
    }
    
    // Пауза блокировки
    func pauseBlock() {
        guard isBlockingActive, !isPaused else { return }
        isPaused = true
        pauseStartTime = Date()
        
        // Сохраняем накопленное время до паузы
        if let startTime = blockStartTime {
            let currentDuration = Date().timeIntervalSince(startTime)
            accumulatedTime += currentDuration
            blockStartTime = nil // Сбрасываем для возобновления
        }
        
        // Временно снимаем блокировку
        logger.info("⏸️ Пауза блокировки: \(self.activeBlock?.name ?? "Unknown")")
        blockStore.clearAllSettings()
        
        // Сохраняем состояние
        saveBlockState()
        
        // Показываем диалог для предложения черно-белого режима
        if !selectionToRestrict.applicationTokens.isEmpty {
            shouldShowGrayscaleDialog = true
        }
    }
    
    // Возобновить блокировку
    func resumeBlock() {
        guard isBlockingActive, isPaused else { return }
        isPaused = false
        
        // Время паузы не засчитывается, просто возобновляем отсчет
        pauseStartTime = nil
        blockStartTime = Date() // Начинаем новый отсчет
        
        // Возобновляем блокировку приложений
        logger.info("▶️ Возобновляем блокировку: \(self.activeBlock?.name ?? "Unknown")")
        if !self.selectionToRestrict.applicationTokens.isEmpty {
            blockStore.shield.applications = self.selectionToRestrict.applicationTokens
        }
        
        // shield.webDomains требует Set<WebDomainToken>
        if !self.selectionToRestrict.webDomainTokens.isEmpty {
            blockStore.shield.webDomains = self.selectionToRestrict.webDomainTokens
        }
        
        startTimeTracking()
        
        // Сохраняем состояние
        saveBlockState()
        
        logger.info("✅ Блокировка возобновлена: \(self.activeBlock?.name ?? "Unknown")")
    }
    
    // Получить длительность паузы
    private func getPauseDuration() -> TimeInterval? {
        guard let pauseStart = pauseStartTime else { return nil }
        return Date().timeIntervalSince(pauseStart)
    }
    
    // Мониторинг расписаний для автоматического запуска
    private func startScheduleMonitoring() {
        scheduleTimer?.invalidate()
        // Проверяем расписания каждую минуту
        scheduleTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkAndProcessSchedules()
            }
        }
        // Первая проверка сразу
        checkAndProcessSchedules()
    }
    
    // Проверка и обработка расписаний
    private func checkAndProcessSchedules() {
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now) // 1 = Sunday, 2 = Monday, etc.
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        // Проверяем активные расписания
        for schedule in self.schedules where schedule.isActive {
            // Проверяем, нужно ли запустить блокировку
            if shouldStartSchedule(schedule, currentTime: currentTime, currentWeekday: currentWeekday) {
                if !self.isBlockingActive || self.activeBlock?.id != schedule.id {
                    logger.info("⏰ Автоматический запуск расписания: \(schedule.name)")
                    // Убеждаемся, что есть выбор приложений
                    if !self.selectionToRestrict.applicationTokens.isEmpty {
                        _ = self.startBlock(schedule: schedule)
                    } else {
                        logger.warning("⚠️ Не удалось запустить расписание \(schedule.name): нет выбранных приложений")
                    }
                }
            }
            
            // Проверяем, нужно ли остановить блокировку
            if shouldStopSchedule(schedule, currentTime: currentTime, currentWeekday: currentWeekday) {
                if self.isBlockingActive && self.activeBlock?.id == schedule.id {
                    logger.info("⏰ Автоматическая остановка расписания: \(schedule.name)")
                    self.stopBlock()
                }
            }
        }
    }
    
    // Проверка, нужно ли запустить расписание
    private func shouldStartSchedule(_ schedule: BlockSchedule, currentTime: DateComponents, currentWeekday: Int) -> Bool {
        let scheduleStart = Calendar.current.dateComponents([.hour, .minute], from: schedule.startTime)
        
        // Проверяем время
        guard let currentMinutes = currentTime.minute,
              let currentHour = currentTime.hour,
              let startMinutes = scheduleStart.minute,
              let startHour = scheduleStart.hour else {
            return false
        }
        
        let currentTotalMinutes = currentHour * 60 + currentMinutes
        let startTotalMinutes = startHour * 60 + startMinutes
        
        // Проверяем, что текущее время совпадает с временем начала (с точностью до минуты)
        guard abs(currentTotalMinutes - startTotalMinutes) < 2 else {
            return false
        }
        
        // Если расписание повторяющееся, проверяем день недели
        if schedule.isRepeating {
            // Конвертируем weekday: iOS использует 1=Sunday, но мы используем 1=Monday
            let adjustedWeekday = currentWeekday == 1 ? 7 : currentWeekday - 1
            return schedule.repeatDays.contains(adjustedWeekday)
        } else {
            // Для неповторяющихся расписаний проверяем дату
            let scheduleDate = Calendar.current.startOfDay(for: schedule.startTime)
            let today = Calendar.current.startOfDay(for: Date())
            return scheduleDate == today
        }
    }
    
    // Проверка, нужно ли остановить расписание
    private func shouldStopSchedule(_ schedule: BlockSchedule, currentTime: DateComponents, currentWeekday: Int) -> Bool {
        let scheduleEnd = Calendar.current.dateComponents([.hour, .minute], from: schedule.endTime)
        
        guard let currentMinutes = currentTime.minute,
              let currentHour = currentTime.hour,
              let endMinutes = scheduleEnd.minute,
              let endHour = scheduleEnd.hour else {
            return false
        }
        
        let currentTotalMinutes = currentHour * 60 + currentMinutes
        let endTotalMinutes = endHour * 60 + endMinutes
        
        // Проверяем, что текущее время совпадает с временем окончания (с точностью до минуты)
        return abs(currentTotalMinutes - endTotalMinutes) < 2
    }
    
    // Отслеживание времени
    private func startTimeTracking() {
        timeTrackingTimer?.invalidate()
        // Оптимизация: обновляем каждые 5 секунд вместо каждой секунды
        timeTrackingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateSavedTime()
            }
        }
    }
    
    // Обновление сохраненного времени (для отображения в реальном времени)
    private func updateSavedTime() {
        guard isBlockingActive, !isPaused, let startTime = blockStartTime else { return }
        
        // Обновляем только для отображения, не сохраняем каждый раз
        savedTime.lastUpdated = Date()
    }
    
    // Получить текущее отображаемое время (включая активную сессию)
    // Показывает только время блокировки выбранных приложений
    func getCurrentDisplayTime() -> SavedTime {
        var displayTime = SavedTime()
        
        // Показываем время только если есть выбранные приложения
        guard !selectionToRestrict.applicationTokens.isEmpty else {
            return displayTime
        }
        
        // Базовое накопленное время (только для выбранных приложений)
        displayTime.totalSeconds = savedTime.totalSeconds
        
        // Добавляем текущую активную сессию, если блокировка активна и не на паузе
        if isBlockingActive, !isPaused, let startTime = blockStartTime {
            let currentDuration = Date().timeIntervalSince(startTime)
            displayTime.totalSeconds += accumulatedTime + currentDuration
        } else if accumulatedTime > 0 {
            // Если есть накопленное время, добавляем его
            displayTime.totalSeconds += accumulatedTime
        }
        
        return displayTime
    }
    
    // Включить/выключить черно-белый режим
    func toggleGrayscaleMode() {
        self.isGrayscaleModeEnabled.toggle()
        logger.info("🎨 Черно-белый режим: \(self.isGrayscaleModeEnabled ? "включен" : "выключен")")
    }
    
    // Сохранение состояния блокировки
    private func saveBlockState() {
        let defaults = sharedUserDefaults ?? UserDefaults.standard
        defaults.set(isBlockingActive, forKey: isBlockingActiveKey)
        defaults.set(isPaused, forKey: isPausedKey)
        if let activeBlockId = activeBlock?.id.uuidString {
            defaults.set(activeBlockId, forKey: activeBlockKey)
        }
        defaults.synchronize()
    }
    
    // Очистка состояния блокировки
    private func clearBlockState() {
        let defaults = sharedUserDefaults ?? UserDefaults.standard
        defaults.removeObject(forKey: isBlockingActiveKey)
        defaults.removeObject(forKey: isPausedKey)
        defaults.removeObject(forKey: activeBlockKey)
        defaults.synchronize()
    }
    
    // Восстановление состояния блокировки при запуске
    private func restoreBlockState() {
        let defaults = sharedUserDefaults ?? UserDefaults.standard
        let wasBlockingActive = defaults.bool(forKey: isBlockingActiveKey)
        let wasPaused = defaults.bool(forKey: isPausedKey)
        
        guard wasBlockingActive,
              let activeBlockIdString = defaults.string(forKey: activeBlockKey),
              let activeBlockId = UUID(uuidString: activeBlockIdString),
              let schedule = schedules.first(where: { $0.id == activeBlockId }) else {
            logger.info("ℹ️ Нет сохраненного состояния блокировки для восстановления")
            return
        }
        
        // Проверяем, есть ли сохраненные токены
        let savedTokenCount = defaults.integer(forKey: selectionTokensKey)
        
        if savedTokenCount > 0 {
            // Восстанавливаем состояние блокировки
            // Примечание: selectionToRestrict будет пустым после перезапуска,
            // но ManagedSettingsStore с именованным хранилищем сохраняет настройки
            // Проверяем, есть ли активные блокировки в хранилище
            activeBlock = schedule
            isBlockingActive = true
            isPaused = wasPaused
            
            // Восстанавливаем блокировку только если не на паузе
            if !wasPaused {
                // Именованное хранилище должно сохранить настройки, но на всякий случай восстанавливаем
                // если selectionToRestrict не пустой (например, если приложение не было полностью закрыто)
                if !selectionToRestrict.applicationTokens.isEmpty {
                    blockStore.shield.applications = selectionToRestrict.applicationTokens
                    if !selectionToRestrict.webDomainTokens.isEmpty {
                        blockStore.shield.webDomains = selectionToRestrict.webDomainTokens
                    }
                }
                blockStartTime = Date()
                accumulatedTime = 0
                logger.info("✅ Восстановлена активная блокировка: \(schedule.name)")
            } else {
                logger.info("✅ Восстановлена блокировка на паузе: \(schedule.name)")
            }
        } else {
            // Если нет сохраненных токенов, очищаем состояние
            clearBlockState()
            logger.warning("⚠️ Блокировка не восстановлена: нет сохраненных приложений")
        }
    }
}
