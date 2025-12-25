import SwiftUI
import AdaptyUI
import Adapty

struct PaywallScreen: View {
    @StateObject private var paywallManager = PaywallManager.shared
    let paywallConfiguration: AdaptyUI.PaywallConfiguration
    var onClose: (() -> Void)?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        AdaptyPaywallView(
            paywallConfiguration: paywallConfiguration,
            didFinishPurchase: { product, purchaseResult in
                // Покупка успешна
                FirebaseTracker.trackPaywallView(placementId: "purchase_success")
                
                // Получаем данные для трекинга
                let revenue = NSDecimalNumber(decimal: product.price).doubleValue
                let currency = product.priceLocale.currencyCode ?? "USD"
                
                // Обновляем статус подписки после покупки и получаем productId из профиля
                Task {
                    await SubscriptionManager.shared.loadSubscriptionStatus()
                    
                    // Получаем productId из профиля Adapty после покупки
                    var productId: String? = nil
                    if let activeProductId = SubscriptionManager.shared.activeProductId {
                        productId = activeProductId
                    }
                    
                    // Трекинг покупки в AppsFlyer
                    AppsFlyerTracker.trackPurchase(
                        revenue: revenue,
                        currency: currency,
                        productId: productId,
                        transactionId: nil // transactionId недоступен напрямую в AdaptyPurchaseResult
                    )
                    
                    // Трекинг активации подписки в AppsFlyer
                    if SubscriptionManager.shared.isPremium,
                       let activeProductId = SubscriptionManager.shared.activeProductId {
                        AppsFlyerTracker.trackSubscriptionActivated(
                            productId: activeProductId,
                            revenue: revenue,
                            currency: currency
                        )
                    }
                }
                
                paywallManager.closePaywall()
                onClose?()
                dismiss()
            },
            didFailPurchase: { product, error in
                print("❌ Purchase failed:", error)
            },
            didFinishRestore: { profile in
                paywallManager.closePaywall()
                onClose?()
                dismiss()
            },
            didFailRestore: { error in
                print("❌ Restore failed:", error)
            },
            didFailRendering: { error in
                print("❌ Rendering failed:", error)
            }
        )
        .onDisappear {
            // При закрытии показываем offer только если закрыли основной paywall (не offer)
            if paywallManager.isPresented == false {
                // Трекинг закрытия paywall
                if let placementId = paywallManager.currentPlacementId {
                    FirebaseTracker.trackPaywallClose(placementId: placementId)
                    AppsFlyerTracker.trackPaywallClose(placementId: placementId)
                    
                    // Показываем offer только если закрыли основной paywall (pw_main или pw_onboarding), но не offer
                    if placementId != PaywallManager.Placement.offer.rawValue && paywallManager.paywall != nil {
                        // Небольшая задержка перед показом offer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            paywallManager.showOffer()
                        }
                    }
                }
            }
        }
    }
}
