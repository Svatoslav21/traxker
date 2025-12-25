import SwiftUI

struct MainTabView: View {
    @StateObject private var blockManager = AppBlockManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var paywallManager = PaywallManager.shared
    @State private var selectedTab = 1
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(2)
            }
            
            TabView(selection: $selectedTab) {
            ReportView()
                .tabItem {
                    Label("Report".localized, systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            HomeView()
                .tabItem {
                    Label("Home".localized, systemImage: "plus.app.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings".localized, systemImage: "gearshape.fill")
                }
                .tag(2)
            }
            .tint(AppColors.accent)
            .preferredColorScheme(themeManager.colorScheme)
            .grayscaleMode(blockManager.isGrayscaleModeEnabled && (!blockManager.isBlockingActive || blockManager.isPaused))
            
            // Paywall sheet
            .sheet(isPresented: $paywallManager.isPresented) {
                if let configuration = paywallManager.paywallConfiguration {
                    PaywallScreen(paywallConfiguration: configuration)
                }
            }
            
            // Onboarding
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(isPresented: $showOnboarding)
            }
            .onAppear {
                // Показываем splash screen на короткое время
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSplash = false
                    }
                    
                    // После скрытия splash показываем onboarding если нужно
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if !hasCompletedOnboarding {
                            // Трекинг запуска онбординга после сплеша
                            FirebaseTracker.trackOnboardingAction(actionId: "ob_main_1")
                            AppsFlyerTracker.trackOnboardingAction(actionId: "ob_main_1")
                            showOnboarding = true
                        }
                    }
                }
            }
        }
    }
}
