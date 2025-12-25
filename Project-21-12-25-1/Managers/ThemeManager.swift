import SwiftUI

// Менеджер тем приложения
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var colorScheme: ColorScheme? = nil // nil = системная тема
    
    private let themeKey = "appTheme"
    
    init() {
        loadTheme()
    }
    
    // Загрузить сохраненную тему
    private func loadTheme() {
        if let themeString = UserDefaults.standard.string(forKey: themeKey) {
            switch themeString {
            case "light":
                colorScheme = .light
            case "dark":
                colorScheme = .dark
            default:
                colorScheme = nil // Системная тема
            }
        }
    }
    
    // Сохранить тему
    func saveTheme() {
        let themeString: String?
        switch colorScheme {
        case .light:
            themeString = "light"
        case .dark:
            themeString = "dark"
        case nil:
            themeString = "system"
        }
        UserDefaults.standard.set(themeString, forKey: themeKey)
    }
    
    // Установить светлую тему
    func setLightTheme() {
        colorScheme = .light
        saveTheme()
    }
    
    // Установить темную тему
    func setDarkTheme() {
        colorScheme = .dark
        saveTheme()
    }
    
    // Установить системную тему
    func setSystemTheme() {
        colorScheme = nil
        saveTheme()
    }
    
    // Текущая тема (для отображения)
    var currentThemeName: String {
        switch colorScheme {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case nil:
            return "System"
        }
    }
}

