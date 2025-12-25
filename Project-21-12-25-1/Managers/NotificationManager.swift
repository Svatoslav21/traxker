import Foundation
import UserNotifications
import OSLog

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private let logger = Logger(subsystem: "com.danielian.selfcontrol.dopaminedetox", category: "NotificationManager")
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // Проверка статуса авторизации уведомлений
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            Task { @MainActor in
                self?.isAuthorized = settings.authorizationStatus == .authorized
                self?.logger.info("📱 Статус уведомлений: \(settings.authorizationStatus.rawValue)")
            }
        }
    }
    
    // Запрос разрешения на уведомления
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isAuthorized = granted
                if granted {
                    logger.info("✅ Разрешение на уведомления предоставлено")
                } else {
                    logger.warning("⚠️ Разрешение на уведомления отклонено")
                }
            }
            return granted
        } catch {
            await MainActor.run {
                isAuthorized = false
                logger.error("❌ Ошибка запроса разрешения на уведомления: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // Отправка уведомления о завершении блокировки
    func sendBlockEndedNotification(blockName: String) {
        // Проверяем разрешение перед отправкой
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            guard settings.authorizationStatus == .authorized else {
                self.logger.warning("⚠️ Уведомление не отправлено: разрешение не предоставлено (статус: \(settings.authorizationStatus.rawValue))")
                Task { @MainActor in
                    self.isAuthorized = false
                }
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Block Ended".localized
            content.body = String(format: "The block '%@' has ended.".localized, blockName)
            content.sound = .default
            content.badge = 1
            
            // Отправляем сразу
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil // nil означает немедленную отправку
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    self.logger.error("❌ Ошибка отправки уведомления: \(error.localizedDescription)")
                } else {
                    self.logger.info("✅ Уведомление о завершении блокировки отправлено: \(blockName)")
                }
            }
        }
    }
    
    // Тестовое уведомление
    func sendTestNotification() {
        // Проверяем разрешение перед отправкой
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            guard settings.authorizationStatus == .authorized else {
                self.logger.warning("⚠️ Тестовое уведомление не отправлено: разрешение не предоставлено (статус: \(settings.authorizationStatus.rawValue))")
                Task { @MainActor in
                    self.isAuthorized = false
                    // Попробуем запросить разрешение еще раз
                    let granted = await self.requestAuthorization()
                    // Если разрешение получили, отправляем уведомление снова
                    if granted {
                        self.sendTestNotification()
                    }
                }
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Test Notification".localized
            content.body = "This is a test notification to verify that push notifications are working correctly.".localized
            content.sound = .default
            content.badge = 1
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    self.logger.error("❌ Ошибка отправки тестового уведомления: \(error.localizedDescription)")
                } else {
                    self.logger.info("✅ Тестовое уведомление отправлено")
                }
            }
        }
    }
}

