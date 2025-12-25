import Foundation
import FamilyControls
import ManagedSettings

// Примечание: ApplicationToken не может быть сериализован напрямую
// Используем FamilyActivitySelection для хранения выбранных приложений

// Модель для расписания блокировки
struct BlockSchedule: Identifiable, Codable {
    var id: UUID
    var name: String
    var startTime: Date
    var endTime: Date
    var isRepeating: Bool
    var repeatDays: Set<Int> // 1 = Monday, 7 = Sunday
    var isActive: Bool
    var selectionIdentifier: String? // Идентификатор для ActivitySelection
    
    init(id: UUID = UUID(),
         name: String = "New Block", 
         startTime: Date = Date(),
         endTime: Date = Date().addingTimeInterval(3600),
         isRepeating: Bool = false,
         repeatDays: Set<Int> = [],
         isActive: Bool = true,
         selectionIdentifier: String? = nil) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.isRepeating = isRepeating
        self.repeatDays = repeatDays
        self.isActive = isActive
        self.selectionIdentifier = selectionIdentifier
    }
}

// Модель для сохраненного времени
struct SavedTime: Codable {
    var totalSeconds: TimeInterval
    var lastUpdated: Date
    
    init(totalSeconds: TimeInterval = 0, lastUpdated: Date = Date()) {
        self.totalSeconds = totalSeconds
        self.lastUpdated = lastUpdated
    }
    
    var hours: Int {
        Int(totalSeconds) / 3600
    }
    
    var minutes: Int {
        (Int(totalSeconds) % 3600) / 60
    }
    
    var seconds: Int {
        Int(totalSeconds) % 60
    }
    
    var formattedTime: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

