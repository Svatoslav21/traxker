import SwiftUI
import Adapty

struct PremiumView: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var paywallManager = PaywallManager.shared
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        ZStack {
            ThemeBackgroundView()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header с короной
                    VStack(spacing: 16) {
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
                        .padding(.top, 40)
                        
                        Text("Unlock Premium".localized)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.primaryText)
                        
                        Text("Get the most out of Dopamine Detox".localized)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    
                    // Преимущества Premium
                    VStack(spacing: 20) {
                        PremiumFeatureRow(
                            icon: "infinity",
                            iconColor: AppColors.accent,
                            title: "Unlimited Blocks".localized,
                            description: "Create as many blocking schedules as you need".localized
                        )
                        
                        PremiumFeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: AppColors.accent,
                            title: "Advanced Analytics".localized,
                            description: "Detailed insights and statistics about your usage".localized
                        )
                        
                        PremiumFeatureRow(
                            icon: "bell.badge",
                            iconColor: AppColors.accent,
                            title: "Smart Reminders".localized,
                            description: "Never miss a blocking session with intelligent notifications".localized
                        )
                        
                        PremiumFeatureRow(
                            icon: "sparkles",
                            iconColor: AppColors.gold,
                            title: "Priority Support".localized,
                            description: "Get help faster with dedicated premium support".localized
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    
                    // Кнопка подписки
                    Button(action: {
                        subscribeToPremium()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.headline)
                            
                            Text("Subscribe Now".localized)
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
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    // Восстановить покупки
                    Button(action: {
                        restorePurchases()
                    }) {
                        Text("Restore Purchases".localized)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                            .underline()
                    }
                    .padding(.bottom, 32)
                    
                    // Термины и политика
                    HStack(spacing: 16) {
                        Button(action: {
                            showTerms = true
                        }) {
                            Text("Terms of Service".localized)
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                                .underline()
                        }
                        
                        Text("•")
                            .foregroundStyle(AppColors.secondaryText)
                        
                        Button(action: {
                            showPrivacy = true
                        }) {
                            Text("Privacy Policy".localized)
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                                .underline()
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Premium".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $paywallManager.isPresented) {
            if let configuration = paywallManager.paywallConfiguration {
                PaywallScreen(
                    paywallConfiguration: configuration,
                    onClose: {
                        navigationPath.removeLast()
                    }
                )
            }
        }
        .sheet(isPresented: $showTerms) {
            SafariView(url: URL(string: "https://example.com/terms")!)
        }
        .sheet(isPresented: $showPrivacy) {
            SafariView(url: URL(string: "https://example.com/privacy")!)
        }
    }
    
    private func subscribeToPremium() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Показываем paywall через placement pw_main
        paywallManager.showPaywall(placementId: PaywallManager.Placement.main.rawValue)
        FirebaseTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
        AppsFlyerTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
    }
    
    private func restorePurchases() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        Task {
            do {
                try await Adapty.restorePurchases()
                // Обновляем статус подписки после восстановления
                await SubscriptionManager.shared.loadSubscriptionStatus()
            } catch {
                print("❌ Restore failed:", error)
            }
        }
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// SafariView для открытия веб-страниц
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

