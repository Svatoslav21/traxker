

import Foundation
import Combine

class AppDataManager: ObservableObject {
    @Published var projects: [Project] = []
    @Published var tasks: [TaskModel] = []
    @Published var teamMembers: [TeamMember] = []
    @Published var notes: [NoteItem] = []
    @Published var favorites: [Favorite] = []
    
    private let defaults = UserDefaults.standard
    
    init() {
        loadAll()
        loadDummyData()
        saveAll()
        
    }
    
    // MARK: - Add
    func addProject(_ project: Project) { projects.append(project); save(projects, key: "projects") }
    func addTask(_ task: TaskModel) { tasks.append(task); save(tasks, key: "tasks") }
    func addTeamMember(_ member: TeamMember) { teamMembers.append(member); save(teamMembers, key: "teamMembers") }
    func addNote(_ note: NoteItem) { notes.append(note); save(notes, key: "notes") }
    func addFavorite(_ fav: Favorite) { favorites.append(fav); save(favorites, key: "favorites") }
    
    // MARK: - Delete
    func deleteProject(at indexSet: IndexSet) { projects.remove(atOffsets: indexSet); save(projects, key: "projects") }
    func deleteTask(at indexSet: IndexSet) { tasks.remove(atOffsets: indexSet); save(tasks, key: "tasks") }
    func deleteTeamMember(at indexSet: IndexSet) { teamMembers.remove(atOffsets: indexSet); save(teamMembers, key: "teamMembers") }
    func deleteNote(at indexSet: IndexSet) { notes.remove(atOffsets: indexSet); save(notes, key: "notes") }
    func deleteFavorite(at indexSet: IndexSet) { favorites.remove(atOffsets: indexSet); save(favorites, key: "favorites") }
    
    // MARK: - Persistence
    private func save<T: Codable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }
    
    private func load<T: Codable>(_ type: T.Type, key: String) -> T? {
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(type, from: data) {
            return decoded
        }
        return nil
    }
    
    func saveAll() {
        save(projects, key: "projects")
        save(tasks, key: "tasks")
        save(teamMembers, key: "teamMembers")
        save(notes, key: "notes")
        save(favorites, key: "favorites")
    }
    
    func loadAll() {
        projects = load([Project].self, key: "projects") ?? []
        tasks = load([TaskModel].self, key: "tasks") ?? []
        teamMembers = load([TeamMember].self, key: "teamMembers") ?? []
        notes = load([NoteItem].self, key: "notes") ?? []
        favorites = load([Favorite].self, key: "favorites") ?? []
    }
    
    // MARK: - Dummy Data
    func loadDummyData() {
        
        let project = Project(
            id: UUID(),
            name: "Mobile App Development",
            clientId: "wertyui",
            description: "iOS and Android application",
            status: "Active",
            startDate: Date(),
            endDate: Date().addingTimeInterval(60*60*24*180),
            budget: 50000,
            spent: 10000,
            currency: "USD",
            tasksCount: 25,
            completedTasks: 5,
            milestone: "Prototype",
            createdAt: Date(),
            updatedAt: Date(),
            manager: "Alice Smith",
            teamSize: 6,
            priority: 1,
            category: "Development",
            riskLevel: "Medium",
            tags: ["SwiftUI", "Firebase"],
            deadlineFlexible: false,
            progressPercent: 20,
            location: "Remote",
            visibility: "Internal",
            isBillable: true,
            approvalRequired: true,
            revisionCount: 0,
            feedbackNotes: "Initial feedback positive",
            archived: false
        )
        
        let task = TaskModel(
            id: UUID(),
            projectId: project.id,
            title: "Design Login Screen",
            description: "Create SwiftUI login view",
            status: "In Progress",
            priority: 2,
            assignee: "Bob Johnson",
            reviewer: "Alice Smith",
            createdAt: Date(),
            updatedAt: Date(),
            dueDate: Date().addingTimeInterval(60*60*24*7),
            completedAt: nil,
            estimatedHours: 12,
            loggedHours: 3,
            tags: ["UI", "design"],
            progress: 25,
            isRecurring: false,
            recurrenceRule: "",
            reminders: [Date().addingTimeInterval(60*60*24*2)],
            checklist: ["Wireframe", "Prototype", "Review"],
            commentsCount: 2,
            attachmentsCount: 1,
            isBillable: true,
            clientVisible: true,
            approvalRequired: true,
            approvalStatus: "Pending",
            riskLevel: "Low",
            blockedBy: nil,
            blocking: [],
            archived: false
        )
        
        let teamMember = TeamMember(
            id: UUID(),
            firstName: "Bob",
            lastName: "Johnson",
            role: "iOS Developer",
            email: "bob@example.com",
            phone: "987-654-3210",
            department: "Engineering",
            skills: ["Swift", "SwiftUI", "Combine"],
            joinedAt: Date().addingTimeInterval(-60*60*24*365),
            updatedAt: Date(),
            status: "Active",
            managerId: nil,
            hourlyRate: 50,
            weeklyHours: 40,
            location: "Remote",
            timezone: "PST",
            language: "English",
            isActive: true,
            isAvailable: true,
            tags: ["iOS", "mobile"],
            projectIds: [project.id],
            taskIds: [task.id],
            lastLogin: Date(),
            loginCount: 120,
            emergencyContact: "Jane Johnson",
            certifications: ["Swift Developer Certified"],
            notes: "Strong SwiftUI skills",
            performanceRating: 4,
            vacationDays: 10,
            sickDays: 5,
            archived: false
        )
        
        let note = NoteItem(
            id: UUID(),
            ownerId: teamMember.id,
            title: "Client Feedback",
            content: "Client liked the design proposal.",
            createdAt: Date(),
            updatedAt: Date(),
            tags: ["feedback"],
            category: "Project Notes",
            priority: 1,
            isPinned: true,
            isArchived: false,
            reminderDate: nil,
            checklist: ["Follow-up", "Send report"],
            references: ["doc123"],
            relatedProjectId: project.id,
            relatedTaskId: task.id,
            author: "Alice Smith",
            lastEditedBy: "Alice Smith",
            wordCount: 50,
            charCount: 200,
            readCount: 5,
            version: 1,
            sharedWith: ["bob@example.com"],
            isEncrypted: false,
            folder: "General",
            theme: "Default",
            customFields: ["important"],
            archivedReason: "",
            deleted: false
        )
        
        let favorite = Favorite(
            id: UUID(),
            ownerId: UUID(),
            itemType: "Project",
            itemId: UUID(),
            createdAt: Date(timeIntervalSinceNow: -86400 * 12), // 12 days ago
            notes: "This project is for a VIP client. Requires weekly updates and design approval.",
            tags: ["Important", "Design", "Deadline", "ClientX", "Confidential"],
            priority: 5,
            isPinned: true,
            orderIndex: 12,
            lastAccessed: Date(timeIntervalSinceNow: -3600 * 3), // 3 hours ago
            timesOpened: 47,
            category: "Client Work",
            folder: "Q4 Deliverables",
            sharedWith: [
                "alice@example.com",
                "mark@example.com",
                "julia@example.com",
                "teamlead@example.com"
            ],
            colorCode: "#34C759",
            isArchived: false,
            visibility: "Public",
            reminderDate: Date(timeIntervalSinceNow: 86400 * 2), // in 2 days
            expirationDate: Date(timeIntervalSinceNow: 86400 * 30), // in 1 month
            referenceLinks: [
                "https://example.com/project-docs",
                "https://figma.com/design123",
                "https://jira.com/task/456"
            ],
            version: 3,
            favoriteGroup: "High Priority",
            isTemporary: false,
            createdBy: "Bob",
            modifiedBy: "Alice",
            deleted: false,
            iconName: "briefcase.fill",
            shortcutKey: "⌘P",
            aliasName: "ClientX Redesign",
            description: """
            This project involves a complete redesign of the ClientX platform. 
            Milestones: UI overhaul, backend migration, API integrations. 
            Deadline is end of this quarter.
            """
        )

        projects = [project]
        tasks = [task]
        teamMembers = [teamMember]
        notes = [note]
        favorites = [favorite]
    }
}


import Foundation


struct Project: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var clientId: String
    var description: String
    var status: String
    var startDate: Date
    var endDate: Date
    var budget: Double
    var spent: Double
    var currency: String
    var tasksCount: Int
    var completedTasks: Int
    var milestone: String
    var createdAt: Date
    var updatedAt: Date
    var manager: String
    var teamSize: Int
    var priority: Int
    var category: String
    var riskLevel: String
    var tags: [String]
    var deadlineFlexible: Bool
    var progressPercent: Double
    var location: String
    var visibility: String
    var isBillable: Bool
    var approvalRequired: Bool
    var revisionCount: Int
    var feedbackNotes: String
    var archived: Bool
}

// MARK: - Task
struct TaskModel: Identifiable, Codable, Hashable {
    let id: UUID
    var projectId: UUID
    var title: String
    var description: String
    var status: String
    var priority: Int
    var assignee: String
    var reviewer: String
    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date
    var completedAt: Date?
    var estimatedHours: Double
    var loggedHours: Double
    var tags: [String]
    var progress: Double
    var isRecurring: Bool
    var recurrenceRule: String
    var reminders: [Date]
    var checklist: [String]
    var commentsCount: Int
    var attachmentsCount: Int
    var isBillable: Bool
    var clientVisible: Bool
    var approvalRequired: Bool
    var approvalStatus: String
    var riskLevel: String
    var blockedBy: UUID?
    var blocking: [UUID]
    var archived: Bool
}

struct TeamMember: Identifiable, Codable, Hashable {
    let id: UUID
    var firstName: String
    var lastName: String
    var role: String
    var email: String
    var phone: String
    var department: String
    var skills: [String]
    var joinedAt: Date
    var updatedAt: Date
    var status: String
    var managerId: UUID?
    var hourlyRate: Double
    var weeklyHours: Int
    var location: String
    var timezone: String
    var language: String
    var isActive: Bool
    var isAvailable: Bool
    var tags: [String]
    var projectIds: [UUID]
    var taskIds: [UUID]
    var lastLogin: Date
    var loginCount: Int
    var emergencyContact: String
    var certifications: [String]
    var notes: String
    var performanceRating: Int
    var vacationDays: Int
    var sickDays: Int
    var archived: Bool
}

// MARK: - NoteItem
struct NoteItem: Identifiable, Codable, Hashable {
    let id: UUID
    var ownerId: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var tags: [String]
    var category: String
    var priority: Int
    var isPinned: Bool
    var isArchived: Bool
    var reminderDate: Date?
    var checklist: [String]
    var references: [String]
    var relatedProjectId: UUID?
    var relatedTaskId: UUID?
    var author: String
    var lastEditedBy: String
    var wordCount: Int
    var charCount: Int
    var readCount: Int
    var version: Int
    var sharedWith: [String]
    var isEncrypted: Bool
    var folder: String
    var theme: String
    var customFields: [String]
    var archivedReason: String
    var deleted: Bool
}

// MARK: - Favorite
struct Favorite: Identifiable, Codable, Hashable {
    let id: UUID
    var ownerId: UUID
    var itemType: String
    var itemId: UUID
    var createdAt: Date
    var notes: String
    var tags: [String]
    var priority: Int
    var isPinned: Bool
    var orderIndex: Int
    var lastAccessed: Date
    var timesOpened: Int
    var category: String
    var folder: String
    var sharedWith: [String]
    var colorCode: String
    var isArchived: Bool
    var visibility: String
    var reminderDate: Date?
    var expirationDate: Date?
    var referenceLinks: [String]
    var version: Int
    var favoriteGroup: String
    var isTemporary: Bool
    var createdBy: String
    var modifiedBy: String
    var deleted: Bool
    var iconName: String
    var shortcutKey: String
    var aliasName: String
    var description: String
}
