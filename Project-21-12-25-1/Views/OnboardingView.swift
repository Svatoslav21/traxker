import SwiftUI
import Adapty
import FamilyControls

struct OnboardingView: View {
    @StateObject private var paywallManager = PaywallManager.shared
    @StateObject private var blockManager = AppBlockManager.shared
    @State private var currentScreen = 0
    @Binding var isPresented: Bool
    
    // Action IDs из Adapty
    enum ActionID: String {
        case allowScreenTime = "allowScreenTime"
        case allowRateApp = "allowRateApp"
        case pwOnboarding = "pw_onboarding"
        case closeOnboarding = "CloseOnboarding"
    }
    
    // Screen IDs для трекинга
    enum ScreenID: String {
        case screen1 = "screen_1"
        case screen2 = "screen_2"
        case screen3 = "screen_3"
        case screen4 = "screen_4"
    }
    
    var body: some View {
        ZStack {
            ThemeBackgroundView()
                .ignoresSafeArea()
            
            TabView(selection: $currentScreen) {
                OnboardingScreen1(actionId: ActionID.allowScreenTime.rawValue)
                    .tag(0)
                
                OnboardingScreen2()
                    .tag(1)
                
                OnboardingScreen3()
                    .tag(2)
                
                OnboardingScreen4(
                    actionId: ActionID.pwOnboarding.rawValue,
                    closeActionId: ActionID.closeOnboarding.rawValue,
                    onPremiumTap: {
                        handlePremiumTap()
                    },
                    onClose: {
                        handleClose()
                    }
                )
                .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .onChange(of: currentScreen) { oldValue, newValue in
            // Трекинг экранов onboarding
            let screenId = getScreenId(for: newValue)
            FirebaseTracker.trackOnboardingScreen(screenId: screenId)
            AppsFlyerTracker.trackOnboardingScreen(screenId: screenId)
        }
    }
    
    private func getScreenId(for index: Int) -> String {
        switch index {
        case 0: return ScreenID.screen1.rawValue
        case 1: return ScreenID.screen2.rawValue
        case 2: return ScreenID.screen3.rawValue
        case 3: return ScreenID.screen4.rawValue
        default: return "screen_\(index + 1)"
        }
    }
    
    private func handlePremiumTap() {
        FirebaseTracker.trackOnboardingAction(actionId: ActionID.pwOnboarding.rawValue)
        AppsFlyerTracker.trackOnboardingAction(actionId: ActionID.pwOnboarding.rawValue)
        
        // Помечаем Onboarding как завершенный, чтобы он не показывался снова
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Закрываем Onboarding сразу
        AppsFlyerTracker.trackOnboardingComplete()
        isPresented = false
        
        // Показываем Paywall после небольшой задержки, чтобы Onboarding успел закрыться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        paywallManager.showPaywall(placementId: PaywallManager.Placement.onboarding.rawValue)
        FirebaseTracker.trackPaywallView(placementId: PaywallManager.Placement.onboarding.rawValue)
            AppsFlyerTracker.trackPaywallView(placementId: PaywallManager.Placement.onboarding.rawValue)
        }
    }
    
    private func handleClose() {
        FirebaseTracker.trackOnboardingAction(actionId: ActionID.closeOnboarding.rawValue)
        AppsFlyerTracker.trackOnboardingAction(actionId: ActionID.closeOnboarding.rawValue)
        AppsFlyerTracker.trackOnboardingComplete()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isPresented = false
    }
}

// Экран 1: Запрос разрешения Screen Time
struct OnboardingScreen1: View {
    let actionId: String
    @StateObject private var blockManager = AppBlockManager.shared
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.accent)
            
            Text("Enable Screen Time".localized)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)
            
            Text("To block apps, we need permission to access Screen Time settings".localized)
                .font(.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Показываем кнопку только если разрешение еще не дано
            if !blockManager.isAuthorized {
            Button(action: {
                requestScreenTimePermission()
            }) {
                Text("Allow Screen Time".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primaryGradient)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    private func requestScreenTimePermission() {
        FirebaseTracker.trackOnboardingAction(actionId: actionId)
        AppsFlyerTracker.trackOnboardingAction(actionId: actionId)
        
        Task {
            await blockManager.requestAuthorization()
            if !blockManager.isAuthorized {
                showingPermissionAlert = true
            }
        }
    }
}

// Экран 2: Информация о блокировке
struct OnboardingScreen2: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "app.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.accent)
            
            Text("Block Distracting Apps".localized)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)
            
            Text("Choose which apps to block and when. Take control of your digital habits".localized)
                .font(.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// Экран 3: Оценка приложения
struct OnboardingScreen3: View {
    @State private var showingRateAlert = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.gold)
            
            Text("Rate Our App".localized)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)
            
            Text("If you enjoy using Dopamine Detox, please consider rating us in the App Store".localized)
                .font(.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                requestRateApp()
            }) {
                Text("Rate App".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppColors.gold, AppColors.gold.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private func requestRateApp() {
        FirebaseTracker.trackOnboardingAction(actionId: "allowRateApp")
        AppsFlyerTracker.trackOnboardingAction(actionId: "allowRateApp")
        
        // Показываем системный диалог оценки
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: windowScene)
            } else {
                SKStoreReviewController.requestReview()
            }
        }
    }
}

// Экран 4: Premium предложение
struct OnboardingScreen4: View {
    let actionId: String
    let closeActionId: String
    let onPremiumTap: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gold.opacity(0.3), AppColors.gold.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.gold, AppColors.gold.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Unlock Premium".localized)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)
            
            Text("Get unlimited blocks, advanced analytics, and priority support".localized)
                .font(.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 16) {
                Button(action: {
                    onPremiumTap()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.headline)
                        
                        Text("Get Premium".localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [AppColors.gold, AppColors.gold.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: AppColors.gold.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                
                Button(action: {
                    onClose()
                }) {
                    Text("Maybe Later".localized)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

import StoreKit

