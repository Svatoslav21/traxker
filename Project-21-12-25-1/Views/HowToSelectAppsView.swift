import SwiftUI
import FamilyControls

struct HowToSelectAppsView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            ThemeBackgroundView()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(AppColors.accent)
                        
                        Text("How to select apps for blocking".localized)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.primaryText)
                        
                        Text("Follow these simple steps to set up app blocking".localized)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Шаги
                    VStack(alignment: .leading, spacing: 16) {
                        StepView(
                            number: 1,
                            title: "Create or edit schedule".localized,
                            description: "Press on schedule card or 'Create Block' button".localized,
                            icon: "calendar"
                        )
                        
                        StepView(
                            number: 2,
                            title: "Press 'Select Apps'".localized,
                            description: "In schedule editor find 'Blocked Apps' section and press 'Select Apps' button".localized,
                            icon: "app.badge"
                        )
                        
                        StepView(
                            number: 3,
                            title: "Select applications".localized,
                            description: "In opened window select apps you want to block. You can select multiple apps.".localized,
                            icon: "checkmark.circle.fill"
                        )
                        
                        StepView(
                            number: 4,
                            title: "Save schedule".localized,
                            description: "Press 'Save Schedule' in top right corner to save changes".localized,
                            icon: "square.and.arrow.down"
                        )
                        
                        StepView(
                            number: 5,
                            title: "Start blocking".localized,
                            description: "Now you can press Play button on schedule card to start blocking".localized,
                            icon: "play.circle.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Важная информация
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(AppColors.warning)
                            Text("Important information".localized)
                                .font(.headline)
                                .foregroundStyle(AppColors.primaryText)
                        }
                        
                        InfoBox(
                            icon: "lock.shield.fill",
                            text: "To enable blocking you need to provide Screen Time permission in app settings".localized
                        )
                        
                        InfoBox(
                            icon: "iphone",
                            text: "Blocking works only on real device, not on simulator".localized
                        )
                        
                        InfoBox(
                            icon: "arrow.clockwise",
                            text: "You can change app list anytime by editing schedule".localized
                        )
                    }
                    .padding(20)
                    .cardMaterial()
                    .padding(.horizontal)
                    
                    // Кнопка действия
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        let newSchedule = BlockSchedule()
                        // Schedule будет добавлен только после сохранения в ScheduleEditorView
                        navigationPath.removeLast()
                        navigationPath.append(NavigationDestination.scheduleEditor(newSchedule.id))
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                            Text("Create new schedule".localized)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primaryGradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: AppColors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Instruction".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done".localized) {
                        navigationPath.removeLast()
                    }
                    .foregroundStyle(AppColors.accent)
                }
            }
        }
    }
}

struct StepView: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGradient)
                    .frame(width: 44, height: 44)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundStyle(AppColors.accent)
                        .font(.callout)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryText)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(20)
        .cardMaterial()
    }
}

struct InfoBox: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accent)
                .font(.callout)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
        }
    }
}
