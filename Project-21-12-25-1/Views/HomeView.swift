import SwiftUI
import FamilyControls

struct HomeView: View {
    @StateObject private var blockManager = AppBlockManager.shared
    @StateObject private var paywallManager = PaywallManager.shared
    @State private var navigationPath = NavigationPath()
    @State private var currentTime = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingGrayscaleDialog = false
    
    // Таймер для обновления времени
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                ThemeBackgroundView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Плашка сверху
                    TopHeaderView(onPremiumTap: {
                        paywallManager.showPaywall(placementId: PaywallManager.Placement.main.rawValue)
                        FirebaseTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
                        AppsFlyerTracker.trackPaywallView(placementId: PaywallManager.Placement.main.rawValue)
                    })
                    
                    
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            Spacer()
                                .frame(height: 24)
                            TimeDialView(savedTime: blockManager.getCurrentDisplayTime())
                                .padding(.top, 8)
                            
                            if blockManager.schedules.isEmpty {
                                // Пустое состояние
                                EmptyStateView(
                                    onCreateBlock: {
                                        let newSchedule = BlockSchedule()
                                        // Schedule будет добавлен только после сохранения в ScheduleEditorView
                                        navigationPath.append(NavigationDestination.scheduleEditor(newSchedule.id))
                                    }
                                )
                                .padding(.horizontal)
                            } else {
                                // Активная карточка блокировки (если есть)
                                if blockManager.isBlockingActive, let activeSchedule = blockManager.activeBlock {
                                    VStack(spacing: 8) {
                                        ActiveBlockCardView(
                                            schedule: activeSchedule,
                                            selection: blockManager.selectionToRestrict,
                                            isPaused: blockManager.isPaused,
                                            onPause: {
                                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                                impact.impactOccurred()
                                                blockManager.pauseBlock()
                                            },
                                            onScheduleTap: {
                                                navigationPath.append(NavigationDestination.scheduleEditor(activeSchedule.id))
                                            }
                                        )
                                        .padding(.horizontal)
                                        
                                        // Подсказка о свайпе
                                        HStack {
                                            Text("<<<")
                                                .font(.caption)
                                                .foregroundStyle(AppColors.secondaryText.opacity(0.6))
                                            Text("SWIPE TO STOP OR DELETE".localized)
                                                .font(.caption)
                                                .foregroundStyle(AppColors.secondaryText.opacity(0.6))
                                            Spacer()
                                        }
                                        .padding(.horizontal, 32)
                                    }
                                }
                                
                                // Заголовок расписаний
                                if !blockManager.isBlockingActive {
                                    Divider()
                                    
                                    HStack {
                                        Circle()
                                            .foregroundStyle(AppColors.accent)
                                            .frame(height: 8)
                                        
                                        Spacer()
                                            .frame(width: 16)
                                        
                                        Text("Blocking Apps".localized)
                                            .font(.title3)
                                            .foregroundStyle(AppColors.primaryText)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                
                                // Остальные расписания в List для swipe actions
                                let inactiveSchedules = blockManager.schedules.filter { schedule in
                                    !(blockManager.isBlockingActive && blockManager.activeBlock?.id == schedule.id)
                                }
                                
                                if !inactiveSchedules.isEmpty {
                                    List {
                                        ForEach(inactiveSchedules) { schedule in
                                            ScheduleRowView(
                                                schedule: schedule,
                                                selection: blockManager.selectionToRestrict,
                                                onTap: {
                                                    navigationPath.append(NavigationDestination.scheduleEditor(schedule.id))
                                                },
                                                onStart: {
                                                    handleStartBlock(schedule: schedule)
                                                },
                                                onPause: {
                                                    if blockManager.isBlockingActive && blockManager.activeBlock?.id == schedule.id {
                                                        blockManager.pauseBlock()
                                                    }
                                                },
                                                onDelete: {
                                                    blockManager.deleteSchedule(schedule)
                                                }
                                            )
                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                            .listRowSeparator(.hidden)
                                            .listRowBackground(Color.clear)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                                                    impact.impactOccurred()
                                                    blockManager.deleteSchedule(schedule)
                                                } label: {
                                                    Label("Delete".localized, systemImage: "trash")
                                                }
                                                .tint(AppColors.error)
                                            }
                                        }
                                    }
                                    .listStyle(.plain)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(height: CGFloat(inactiveSchedules.count * 220))
                                    .scrollDisabled(true) // Отключаем скролл у List, чтобы скроллился основной ScrollView
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .scheduleEditor(let scheduleId):
                    if let schedule = blockManager.schedules.first(where: { $0.id == scheduleId }) {
                        ScheduleEditorView(schedule: schedule, navigationPath: $navigationPath)
                    } else {
                        // Fallback: создаем новый schedule если не найден
                        let newSchedule = BlockSchedule(id: scheduleId)
                        ScheduleEditorView(schedule: newSchedule, navigationPath: $navigationPath)
                    }
                case .howToSelectApps:
                    HowToSelectAppsView(navigationPath: $navigationPath)
                case .premium:
                    PremiumView(navigationPath: $navigationPath)
                }
            }
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .alert("Attention".localized, isPresented: $showingAlert) {
                Button("OK".localized, role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .alert("Enable Grayscale Mode?".localized, isPresented: $showingGrayscaleDialog) {
                Button("Enable".localized) {
                    blockManager.isGrayscaleModeEnabled = true
                    blockManager.shouldShowGrayscaleDialog = false
                }
                Button("Skip".localized, role: .cancel) {
                    blockManager.shouldShowGrayscaleDialog = false
                }
            } message: {
                Text("Would you like to enable grayscale mode for these apps? This will make them appear in black and white, reducing their visual appeal.".localized)
            }
            .onChange(of: blockManager.shouldShowGrayscaleDialog) { oldValue, newValue in
                if newValue {
                    showingGrayscaleDialog = true
                }
            }
            .sheet(isPresented: $paywallManager.isPresented) {
                if let configuration = paywallManager.paywallConfiguration {
                    PaywallScreen(paywallConfiguration: configuration)
                }
            }
        }
    }
    
    private func handleStartBlock(schedule: BlockSchedule) {
        Task { @MainActor in
            if !blockManager.isAuthorized {
                await blockManager.requestAuthorization()
            }
            
            if blockManager.selectionToRestrict.applicationTokens.isEmpty {
                alertMessage = "You need to select apps for blocking. Go to schedule editor and select apps.".localized
                showingAlert = true
                return
            }
            
            if blockManager.isAuthorized {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                let success = blockManager.startBlock(schedule: schedule)
                if !success {
                    alertMessage = "Failed to start blocking. Check that apps are selected and authorization is provided.".localized
                    showingAlert = true
                }
            } else {
                alertMessage = "You need to provide Screen Time permission to block apps.".localized
                showingAlert = true
            }
        }
    }
}
