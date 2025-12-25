import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Фон в стиле приложения
            ThemeBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Иконка приложения с анимацией
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppColors.accent)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .rotationEffect(.degrees(rotation))
                }
                
                // Название приложения
                VStack(spacing: 8) {
                    Text("Dopamine Detox")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                        .opacity(opacity)
                    
                    Text("Self Control")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.secondaryText)
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            // Анимация появления
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Легкая анимация вращения
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

