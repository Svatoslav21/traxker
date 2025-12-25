import Foundation
import FirebaseAnalytics

struct FirebaseTracker {
    static func trackOnboardingScreen(screenId: String) {
        Analytics.logEvent("onboarding_screen_view", parameters: [
            "screen_id": screenId
        ])
    }
    
    static func trackOnboardingAction(actionId: String) {
        Analytics.logEvent("onboarding_action", parameters: [
            "action_id": actionId
        ])
    }
    
    static func trackPaywallView(placementId: String) {
        Analytics.logEvent("paywall_view", parameters: [
            "placement_id": placementId
        ])
    }
    
    static func trackPaywallClose(placementId: String) {
        Analytics.logEvent("paywall_close", parameters: [
            "placement_id": placementId
        ])
    }
}

