import SwiftUI

// Циферблат времени - улучшенный дизайн
struct TimeDialView: View {
    let savedTime: SavedTime
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Внешний круг с анимацией
                Circle()
                    .stroke(
                        AppColors.primaryGradient,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.spring(response: 2.0, dampingFraction: 0.6), value: rotationAngle)
                
                // Внутренний круг с Material
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 180, height: 180)
                    .overlay(
                        Circle()
                            .stroke(AppColors.secondaryText.opacity(0.2), lineWidth: 1)
                    )
                
                // Время
                VStack(spacing: 8) {
                    Text(savedTime.formattedTime)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                        .contentTransition(.numericText())
                    
                    Text("Saved Time".localized)
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            
            // Детали времени с улучшенным дизайном
            HStack(spacing: 24) {
                TimeDetailView(value: savedTime.hours, label: "Hours".localized)
                TimeDetailView(value: savedTime.minutes, label: "Minutes".localized)
                TimeDetailView(value: savedTime.seconds, label: "Seconds".localized)
            }
        }
        .onAppear {
            rotationAngle = 360
        }
    }
}

struct TimeDetailView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(AppColors.tertiaryText)
        }
        .frame(minWidth: 60)
    }
}

