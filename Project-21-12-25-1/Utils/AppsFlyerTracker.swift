import Foundation
import AppsFlyerLib

struct AppsFlyerTracker {
    
    // Трекинг покупки (используем стандартное событие af_purchase)
    static func trackPurchase(
        revenue: Double,
        currency: String = "USD",
        productId: String? = nil,
        transactionId: String? = nil
    ) {
        var parameters: [String: Any] = [
            "af_revenue": revenue,
            "af_currency": currency
        ]
        
        if let productId = productId {
            parameters["af_content_id"] = productId
        }
        
        if let transactionId = transactionId {
            parameters["af_order_id"] = transactionId
        }
        
        // Используем стандартное событие AppsFlyer для покупок
        AppsFlyerLib.shared().logEvent("af_purchase", withValues: parameters)
    }
    
    // Трекинг просмотра Paywall
    static func trackPaywallView(placementId: String) {
        AppsFlyerLib.shared().logEvent("af_paywall_view", withValues: [
            "placement_id": placementId
        ])
    }
    
    // Трекинг закрытия Paywall
    static func trackPaywallClose(placementId: String) {
        AppsFlyerLib.shared().logEvent("af_paywall_close", withValues: [
            "placement_id": placementId
        ])
    }
    
    // Трекинг начала блокировки
    static func trackBlockStart(blockName: String) {
        AppsFlyerLib.shared().logEvent("af_block_start", withValues: [
            "block_name": blockName
        ])
    }
    
    // Трекинг завершения блокировки
    static func trackBlockEnd(blockName: String, duration: TimeInterval) {
        AppsFlyerLib.shared().logEvent("af_block_end", withValues: [
            "block_name": blockName,
            "duration_seconds": Int(duration)
        ])
    }
    
    // Трекинг просмотра экрана онбординга
    static func trackOnboardingScreen(screenId: String) {
        AppsFlyerLib.shared().logEvent("af_onboarding_screen", withValues: [
            "screen_id": screenId
        ])
    }
    
    // Трекинг действия в онбординге
    static func trackOnboardingAction(actionId: String) {
        AppsFlyerLib.shared().logEvent("af_onboarding_action", withValues: [
            "action_id": actionId
        ])
    }
    
    // Трекинг завершения онбординга
    static func trackOnboardingComplete() {
        AppsFlyerLib.shared().logEvent("af_onboarding_complete", withValues: nil)
    }
    
    // Трекинг подписки (когда подписка активирована)
    static func trackSubscriptionActivated(productId: String, revenue: Double, currency: String = "USD") {
        AppsFlyerLib.shared().logEvent("af_subscription_activated", withValues: [
            "af_content_id": productId,
            "af_revenue": revenue,
            "af_currency": currency
        ])
    }
    
    // Трекинг истечения подписки
    static func trackSubscriptionExpired() {
        AppsFlyerLib.shared().logEvent("af_subscription_expired", withValues: nil)
    }
}

