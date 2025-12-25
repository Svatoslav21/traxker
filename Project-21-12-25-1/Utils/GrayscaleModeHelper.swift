import UIKit
import SwiftUI

// Helper для проверки и настройки системного черно-белого фильтра
class GrayscaleModeHelper {
    static let shared = GrayscaleModeHelper()
    
    // Проверка доступности системного фильтра
    var isSystemFilterAvailable: Bool {
        // Проверяем, доступен ли Color Filters в настройках
        // Это всегда доступно в iOS, но может быть не включено
        return true
    }
    
    // Проверка, включен ли системный фильтр
    var isSystemFilterEnabled: Bool {
        // К сожалению, нет прямого API для проверки состояния Color Filters
        // Пользователь должен включить его вручную
        return false
    }
    
    // Открытие настроек для включения фильтра
    func openColorFiltersSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // Получение инструкции для пользователя
    func getInstructions() -> [String] {
        return [
            "1. Go to Settings > Accessibility > Display & Text Size",
            "2. Tap Color Filters",
            "3. Enable Color Filters and select Grayscale",
            "4. Note: This will apply to your entire device, not just blocked apps."
        ]
    }
}

