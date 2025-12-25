import SwiftUI

// Пустое состояние когда нет расписаний
struct EmptyStateView: View {
    let onCreateBlock: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Картинка по центру
            if let bannerImage = UIImage(named: "banner_zero") {
                Image(uiImage: bannerImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
            } else {
                // Fallback если картинка не найдена
                Image(systemName: "app.badge")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.secondaryText)
                    .padding(.top, 40)
            }
            
            // Текст "No Apps Blocking"
            Text("No Apps Blocking".localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
                .padding(.top, 24)
            
            // Текст описания
            Text("Please create a new blocking session to start blocking apps".localized)
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            
            // Разделитель
            Divider()
                .padding(.horizontal, 20)
                .padding(.top, 24)
            
            // Кнопка "Start Blocking Apps"
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                onCreateBlock()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.app.fill")
                        .font(.headline)
                    Text("Start Blocking Apps".localized)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(AppColors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

