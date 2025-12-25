import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var blockManager = AppBlockManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var paywallManager = PaywallManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var navigationPath = NavigationPath()
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                ThemeBackgroundView()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Золотой баннер Premium (только если нет подписки)
                        if !subscriptionManager.isPremium {
                        PremiumBannerView(onTap: {
                            paywallManager.showPaywall(placementId: PaywallManager.Placement.main.rawValue)
                            FirebaseTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
                            AppsFlyerTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
                        })
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        
                        // Карточки настроек
                        VStack(spacing: 16) {
                            // Share Dopamine Detox To Friends
                            SettingsCardView(
                                icon: "square.and.arrow.up",
                                title: "Share Dopamine Detox To Friends".localized,
                                action: {
                                    shareApp()
                                }
                            )
                            
                            // Contact Us
                            SettingsCardView(
                                icon: "envelope",
                                title: "Contact Us".localized,
                                action: {
                                    contactUs()
                                }
                            )
                            
                            // Rate Us
                            SettingsCardView(
                                icon: "star.fill",
                                title: "Rate Us".localized,
                                action: {
                                    rateApp()
                                }
                            )
                            
                            // Subscription
                            SettingsCardView(
                                icon: "creditcard",
                                title: "Subscription".localized,
                                action: {
                                    paywallManager.showPaywall(placementId: PaywallManager.Placement.main.rawValue)
                                    FirebaseTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
                                    AppsFlyerTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
                                }
                            )
                            
                            // Appearance Settings
                            AppearanceSettingsCardView(themeManager: themeManager)
                            
                            // Screen Time Access
                            ScreenTimeAccessCardView(blockManager: blockManager)
                            
                            // Test Notification
                            SettingsCardView(
                                icon: "bell.fill",
                                title: "Test Notification".localized,
                                action: {
                                    // Просто отправляем тестовое уведомление
                                    // Разрешение уже должно быть запрошено при запуске приложения
                                    NotificationManager.shared.sendTestNotification()
                                }
                            )
                            
                            // Reset Saved Time
                            SettingsCardView(
                                icon: "arrow.counterclockwise",
                                title: "Reset Saved Time".localized,
                                action: {
                                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                                    impact.impactOccurred()
                                    blockManager.savedTime = SavedTime()
                                },
                                isDestructive: true
                            )
                            
                            // About
                            AboutCardView()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Settings".localized)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .howToSelectApps:
                    HowToSelectAppsView(navigationPath: $navigationPath)
                case .premium:
                    PremiumView(navigationPath: $navigationPath)
                default:
                    EmptyView()
                }
            }
            .sheet(isPresented: $paywallManager.isPresented) {
                if let configuration = paywallManager.paywallConfiguration {
                    PaywallScreen(paywallConfiguration: configuration)
                }
            }
        }
    }
    
    private func shareApp() {
        let text = "Check out Dopamine Detox - Self Control app!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func contactUs() {
        let email = "sluckmenes64@outlook.com"
        let subject = "Dopamine Detox Support"
        
        // Правильно кодируем subject для URL
        var allowedCharacters = CharacterSet.urlQueryAllowed
        allowedCharacters.remove(charactersIn: "&=")
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? subject
        
        // Формируем mailto URL
        let mailtoString = "mailto:\(email)?subject=\(encodedSubject)"
        
        guard let url = URL(string: mailtoString) else {
            return
        }
        
        // Открываем почтовый клиент
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Если почтовый клиент не настроен, копируем email в буфер обмена
            UIPasteboard.general.string = email
        }
    }
    
    private func rateApp() {
        // Показываем системный диалог оценки приложения
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: windowScene)
            } else {
                SKStoreReviewController.requestReview()
            }
        }
    }
}

// Золотой баннер Premium
struct PremiumBannerView: View {
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                    
                    Text("Get Premium".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.6))
                }
                
                Text("Try our Dopamine Detox app Block any app on your phone".localized)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.gold)
            .cornerRadius(16)
            .shadow(color: AppColors.gold.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// Карточка настроек
struct SettingsCardView: View {
    let icon: String
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isDestructive ? AppColors.error : AppColors.accent)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(AppColors.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColors.tertiaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .cardMaterial()
        }
        .buttonStyle(.plain)
    }
}

// Карточка настроек внешнего вида
struct AppearanceSettingsCardView: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 30)
                
                Text("Appearance".localized)
                    .font(.body)
                    .foregroundStyle(AppColors.primaryText)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Theme Picker
            Picker("Theme".localized, selection: Binding(
                get: { themeManager.colorScheme },
                set: { newValue in
                    if let newValue = newValue {
                        themeManager.colorScheme = newValue
                    } else {
                        themeManager.colorScheme = nil
                    }
                    themeManager.saveTheme()
                }
            )) {
                Text("System".localized).tag(Optional<ColorScheme>.none)
                Text("Light".localized).tag(Optional<ColorScheme>.some(.light))
                Text("Dark".localized).tag(Optional<ColorScheme>.some(.dark))
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Grayscale Mode
            HStack {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.title3)
                    .foregroundStyle(AppColors.accent)
                
                Text("Grayscale Mode".localized)
                    .font(.body)
                    .foregroundStyle(AppColors.primaryText)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { AppBlockManager.shared.isGrayscaleModeEnabled },
                    set: { AppBlockManager.shared.isGrayscaleModeEnabled = $0 }
                ))
                .tint(AppColors.accent)
                .labelsHidden()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .cardMaterial()
    }
}

// Карточка Screen Time Access
struct ScreenTimeAccessCardView: View {
    @ObservedObject var blockManager: AppBlockManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
                        HStack {
                Image(systemName: "lock.shield.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 30)
                
                Text("Screen Time Access".localized)
                    .font(.body)
                                .foregroundStyle(AppColors.primaryText)
                
                            Spacer()
                
                            if blockManager.isAuthorized {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.success)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppColors.error)
                            }
                        }
                        
                        if !blockManager.isAuthorized {
                            Button(action: {
                                Task {
                                    await blockManager.requestAuthorization()
                                }
                            }) {
                    Text("Request Authorization".localized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.accent)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .cardMaterial()
    }
}

// Карточка About
struct AboutCardView: View {
    var body: some View {
        VStack(spacing: 12) {
                            HStack {
                Text("Version".localized)
                    .font(.body)
                                .foregroundStyle(AppColors.primaryText)
                            Spacer()
                            Text("1.0.0")
                    .font(.body)
                                .foregroundStyle(AppColors.secondaryText)
                        }
            
            Divider()
                        
                        HStack {
                Text("App Name".localized)
                    .font(.body)
                                .foregroundStyle(AppColors.primaryText)
                            Spacer()
                Text("Dopamine Detox".localized)
                    .font(.body)
                            .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .cardMaterial()
    }
}
