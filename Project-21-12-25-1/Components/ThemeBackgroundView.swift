import SwiftUI

// Профессиональный адаптивный фон с поддержкой MeshGradient (iOS 18+)
struct ThemeBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if #available(iOS 18.0, *) {
            // Используем MeshGradient для iOS 18+ с правильным синтаксисом
            MeshGradient(
                width: 2,
                height: 2,
                points: [
                    [0.0, 0.0], [1.0, 0.0],
                    [0.0, 1.0], [1.0, 1.0]
                ],
                colors: meshColorsFlat
            )
        } else {
            // Fallback для iOS 17 - используем LinearGradient
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    @available(iOS 18.0, *)
    private var meshColorsFlat: [Color] {
        switch colorScheme {
        case .dark:
            return [
                Color(red: 0.11, green: 0.11, blue: 0.118), // #1C1C1E
                Color(red: 0.11, green: 0.11, blue: 0.118),
                Color(red: 0.11, green: 0.11, blue: 0.118),
                Color(red: 0.11, green: 0.11, blue: 0.118)
            ]
        case .light:
            return [
                Color(red: 0.98, green: 0.98, blue: 0.99),
                Color(red: 0.96, green: 0.97, blue: 0.98),
                Color(red: 0.95, green: 0.96, blue: 0.97),
                Color(red: 0.97, green: 0.97, blue: 0.98)
            ]
        @unknown default:
            return [
                Color(red: 0.11, green: 0.11, blue: 0.118), // #1C1C1E
                Color(red: 0.11, green: 0.11, blue: 0.118),
                Color(red: 0.11, green: 0.11, blue: 0.118),
                Color(red: 0.11, green: 0.11, blue: 0.118)
            ]
        }
    }
    
    private var backgroundColors: [Color] {
        switch colorScheme {
        case .dark:
            return [
                Color(red: 0.11, green: 0.11, blue: 0.118) // #1C1C1E
            ]
        case .light:
            return [
                Color(red: 0.98, green: 0.98, blue: 0.99),
                Color(red: 0.95, green: 0.95, blue: 0.97)
            ]
        @unknown default:
            return [
                Color(red: 0.05, green: 0.05, blue: 0.1),
                Color(red: 0.1, green: 0.1, blue: 0.15)
            ]
        }
    }
}
