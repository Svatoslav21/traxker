import SwiftUI

// Плашка сверху с иконкой, названием, кнопкой Premium и настройками
struct TopHeaderView: View {
    @State private var showingSettings = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    var onPremiumTap: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка и название слева
            HStack(spacing: 10) {
                // Иконка приложения
                if let iconImage = UIImage(named: "icon") {
                    Image(uiImage: iconImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .cornerRadius(8)
                } else {
                    // Fallback если иконка не найдена
                    Image(systemName: "app.fill")
                        .font(.title2)
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 32, height: 32)
                }
                
                Text("Dopamine Detox".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.primaryText)
            }
            
            Spacer()
            
            // Кнопка Get Premium справа (только если нет подписки)
            if !subscriptionManager.isPremium {
                Button(action: {
                    onPremiumTap?()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                        Text("Get Premium".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.gold)
                    .cornerRadius(20)
                }
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            .ultraThinMaterial
        )
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}

