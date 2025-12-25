import Foundation
import Adapty
import OSLog

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    private let logger = Logger(subsystem: "com.danielian.selfcontrol.dopaminedetox", category: "SubscriptionManager")
    
    @Published var isPremium: Bool = false
    @Published var subscriptionStatus: SubscriptionStatus = .unknown
    @Published var expirationDate: Date?
    @Published var activeProductId: String?
    
    private var profileUpdateTimer: Timer?
    
    enum SubscriptionStatus {
        case unknown
        case active
        case expired
        case notSubscribed
    }
    
    private init() {
        loadSubscriptionStatus()
        startPeriodicCheck()
    }
    
    deinit {
        profileUpdateTimer?.invalidate()
    }
    
    // Загрузка статуса подписки
    func loadSubscriptionStatus() async {
        do {
            let profile = try await Adapty.getProfile()
            await updateSubscriptionStatus(from: profile)
        } catch {
            logger.error("❌ Ошибка загрузки профиля Adapty: \(error.localizedDescription)")
            await MainActor.run {
                subscriptionStatus = .unknown
                isPremium = false
            }
        }
    }
    
    // Синхронная загрузка (для init)
    private func loadSubscriptionStatus() {
        Task {
            await loadSubscriptionStatus()
        }
    }
    
    // Обновление статуса подписки из профиля
    private func updateSubscriptionStatus(from profile: AdaptyProfile) async {
        await MainActor.run {
            let previousStatus = subscriptionStatus
            
            // Проверяем активные access levels
            if let premiumAccessLevel = profile.accessLevels["premium"],
               premiumAccessLevel.isActive {
                isPremium = true
                subscriptionStatus = .active
                expirationDate = premiumAccessLevel.expiresAt
                activeProductId = premiumAccessLevel.vendorProductId
                
                logger.info("✅ Подписка активна. Истекает: \(self.expirationDate?.description ?? "неизвестно")")
            } else {
                // Проверяем, была ли подписка, но истекла
                if let premiumAccessLevel = profile.accessLevels["premium"],
                   let expiredDate = premiumAccessLevel.expiresAt,
                   expiredDate < Date() {
                    // Если статус был active, а теперь expired - трекинг истечения
                    if previousStatus == .active {
                        AppsFlyerTracker.trackSubscriptionExpired()
                    }
                    
                    isPremium = false
                    subscriptionStatus = .expired
                    expirationDate = expiredDate
                    activeProductId = nil
                    
                    logger.info("⚠️ Подписка истекла: \(expiredDate)")
                } else {
                    isPremium = false
                    subscriptionStatus = .notSubscribed
                    expirationDate = nil
                    activeProductId = nil
                    
                    logger.info("ℹ️ Подписка не активна")
                }
            }
        }
    }
    
    // Периодическая проверка статуса подписки
    private func startPeriodicCheck() {
        profileUpdateTimer?.invalidate()
        // Проверяем каждые 5 минут
        profileUpdateTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.loadSubscriptionStatus()
            }
        }
    }
    
    // Проверка, активна ли подписка (синхронная версия для быстрой проверки)
    var hasActiveSubscription: Bool {
        return isPremium && subscriptionStatus == .active
    }
    
    // Получить информацию о подписке
    func getSubscriptionInfo() -> (isActive: Bool, expiresAt: Date?, productId: String?) {
        return (isPremium, expirationDate, activeProductId)
    }
}

