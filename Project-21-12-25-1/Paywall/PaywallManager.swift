import SwiftUI
import Adapty
import AdaptyUI

@MainActor
final class PaywallManager: ObservableObject {

    static let shared = PaywallManager()

    @Published var isPresented = false
    @Published var paywall: AdaptyPaywall?
    @Published var paywallConfiguration: AdaptyUI.PaywallConfiguration?
    @Published var offer: AdaptyPaywall?
    @Published var currentPlacementId: String?

    // Placements
    enum Placement: String {
        case onboarding = "pw_onboarding"
        case main = "pw_main"
        case offer = "pw_offer"
    }

    func showPaywall(placementId: String) {
        Task {
            do {
                let paywall = try await Adapty.getPaywall(placementId: placementId)
                self.paywall = paywall
                self.currentPlacementId = placementId
                
                // Загружаем конфигурацию для UI
                let configuration = try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
                self.paywallConfiguration = configuration
                self.isPresented = true
            } catch {
                print("❌ Paywall load error:", error)
            }
        }
    }
    
    func showOffer() {
        Task {
            do {
                let offer = try await Adapty.getPaywall(placementId: Placement.offer.rawValue)
                self.offer = offer
                self.currentPlacementId = Placement.offer.rawValue
                // Очищаем основной paywall, чтобы не показывать offer повторно
                self.paywall = nil
                
                // Загружаем конфигурацию для UI
                let configuration = try await AdaptyUI.getPaywallConfiguration(forPaywall: offer)
                self.paywallConfiguration = configuration
                self.isPresented = true
                FirebaseTracker.trackPaywallView(placementId: Placement.offer.rawValue)
                AppsFlyerTracker.trackPaywallView(placementId: Placement.offer.rawValue)
            } catch {
                print("❌ Offer load error:", error)
            }
        }
    }

    func closePaywall() {
        isPresented = false
        paywall = nil
        paywallConfiguration = nil
        offer = nil
        currentPlacementId = nil
    }
}
