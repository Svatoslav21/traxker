
import SwiftUI

@available(iOS 14.0, *)
struct DashboardView: View {
    @StateObject private var dataManager = AppDataManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 6) {
                        Text("📊 Business Dashboard")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary) // ✅ iOS 14 safe
                        
                        Text("Manage clients, projects, tasks & more")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 12)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 22) {
                        
                        dashboardCard(
                            title: "Projects",
                            subtitle: "\(dataManager.projects.count) items",
                            icon: "briefcase.fill",
                            gradient: Gradient(colors: [Color.orange, Color.pink]),
                            destination: ProjectListView(dataManager: dataManager)
                        )
                        
                        dashboardCard(
                            title: "Tasks",
                            subtitle: "\(dataManager.tasks.count) tasks",
                            icon: "checkmark.circle.fill",
                            gradient: Gradient(colors: [Color.green, Color.blue]), // replaced teal → blue
                            destination: TaskListView(store: dataManager)
                        )

                        dashboardCard(
                            title: "Team",
                            subtitle: "\(dataManager.teamMembers.count) members",
                            icon: "person.3.fill",
                            gradient: Gradient(colors: [Color.purple, Color.blue]), // replaced indigo → purple, cyan → blue
                            destination: TeamMemberListView(dataManager: dataManager)
                        )

                        dashboardCard(
                            title: "Notes",
                            subtitle: "\(dataManager.notes.count) notes",
                            icon: "note.text",
                            gradient: Gradient(colors: [Color.pink, Color.purple]),
                            destination: NoteItemListView(data: dataManager)
                        )
                        
                        dashboardCard(
                            title: "Favorites",
                            subtitle: "\(dataManager.favorites.count) items",
                            icon: "star.fill",
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            destination: FavoriteListView(store: dataManager)
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Dashboard")
        }
    }
    
    // MARK: - Dashboard Card
    private func dashboardCard<Destination: View>(
        title: String,
        subtitle: String,
        icon: String,
        gradient: Gradient,
        destination: Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            ZStack {

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .opacity(0.25) // applied to the filled shape instead of the gradient
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)

                
                VStack(alignment: .leading, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
                            .frame(width: 50, height: 50)
                            .shadow(radius: 4)
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary) // ✅ iOS 14 safe
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 160)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6)) // ✅ no `value:` in iOS 14
        }
        .buttonStyle(PlainButtonStyle())
    }
}
