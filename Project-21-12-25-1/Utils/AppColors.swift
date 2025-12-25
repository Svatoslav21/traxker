import SwiftUI

// Профессиональная цветовая система с поддержкой светлой и темной темы
struct AppColors {
    // Фоновые цвета
    static var background: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1.0) // #1C1C1E
                : UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
        })
    }
    
    static var secondaryBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
                : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        })
    }
    
    static var cardBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
                : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        })
    }
    
    // Текстовые цвета
    static var primaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        })
    }
    
    static var secondaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.7, alpha: 1.0)
                : UIColor(white: 0.4, alpha: 1.0)
        })
    }
    
    static var tertiaryText: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.5, alpha: 1.0)
                : UIColor(white: 0.6, alpha: 1.0)
        })
    }
    
    // Акцентные цвета - зеленый (#00EB3F)
    static var accent: Color {
        Color(red: 0.0, green: 0.92, blue: 0.247) // #00EB3F
    }
    
    static var accentSecondary: Color {
        Color(red: 0.0, green: 0.85, blue: 0.22) // Более темный зеленый для градиента
    }
    
    // Золотой цвет (#FFCA1B)
    static var gold: Color {
        Color(red: 1.0, green: 0.792, blue: 0.106) // #FFCA1B
    }
    
    // Статусные цвета
    static var success: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
                : UIColor(red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0)
        })
    }
    
    static var warning: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0)
                : UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        })
    }
    
    static var error: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
                : UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        })
    }
    
    // Градиенты
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                accent,
                accentSecondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                background,
                secondaryBackground
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// Material эффекты для карточек
struct CardMaterial: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: colorScheme == .dark 
                        ? Color.black.opacity(0.3) 
                        : Color.black.opacity(0.1), 
                        radius: 10, x: 0, y: 5)
            )
    }
}

extension View {
    func cardMaterial() -> some View {
        modifier(CardMaterial())
    }
}

