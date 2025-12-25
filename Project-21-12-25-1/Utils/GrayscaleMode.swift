import SwiftUI

// Упрощенная реализация черно-белого режима
// Применяется только к UI приложения через SwiftUI модификатор
// Для системного применения пользователь должен включить фильтр в настройках iOS

// SwiftUI модификатор для черно-белого режима
struct GrayscaleModifier: ViewModifier {
    let enabled: Bool
    
    func body(content: Content) -> some View {
        content
            .grayscale(enabled ? 1.0 : 0.0)
            .saturation(enabled ? 0.0 : 1.0)
    }
}

extension View {
    func grayscaleMode(_ enabled: Bool) -> some View {
        modifier(GrayscaleModifier(enabled: enabled))
    }
}

