import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var kindnessService: KindnessService
    @EnvironmentObject var streakTracker: StreakTracker
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var summaryManager: SummaryManager
    
    @State private var showingResetAlert = false
    @State private var showingConfirmation = false
    @State private var showingPastSummaries = false
    
    var body: some View {
        NavigationView {
            ZStack {
                KindlyColors.subtleGradient.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 8) {
                            SettingRow(title: "Daily Notifications") {
                                Toggle("", isOn: $notificationManager.notificationsEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "FACBD6")))
                                    .onChange(of: notificationManager.notificationsEnabled) { _ in
                                        notificationManager.toggleNotifications()
                                    }
                            }
                            
                            Divider()
                            
                            SettingRow(title: "App Version") {
                                Text("1.0.0")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "888888"))
                            }
                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            Text("Reset All Progress")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.red.opacity(0.8))
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Monthly Summaries Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Monthly Summaries")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: "333333"))
                            
                            Button(action: {
                                // Generate current month summary for testing
                                let currentDate = Date()
                                let calendar = Calendar.current
                                let month = calendar.component(.month, from: currentDate)
                                let year = calendar.component(.year, from: currentDate)
                                
                                summaryManager.generateMonthlySummary(month: month, year: year)
                                showingPastSummaries = true
                            }) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.system(size: 18))
                                        .foregroundColor(KindlyColors.primaryPink)
                                    
                                    Text("View Past Monthly Summaries")
                                        .font(.system(size: 17))
                                        .foregroundColor(Color(hex: "333333"))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "AAAAAA"))
                                }
                                .padding()
                                .background(KindlyColors.warmWhite)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            .sheet(isPresented: $showingPastSummaries) {
                                PastSummariesView(summaryManager: summaryManager)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("Kindly")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "FACBD6"))
                            
                            Text("A little kindness goes a long way")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "888888"))
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("Reset Progress"),
                    message: Text("This will reset all your streaks and completed acts. This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        resetAllProgress()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    func resetAllProgress() {
        kindnessService.resetProgress()
        streakTracker.resetStreak()
    }
}

struct SettingRow<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "333333"))
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

// Add this new view for viewing past summaries
struct PastSummariesView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var summaryManager: SummaryManager
    @State private var selectedSummaryId: UUID?
    
    var body: some View {
        NavigationView {
            ZStack {
                KindlyColors.subtleGradient.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if summaryManager.pastSummaries.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 70))
                                .foregroundColor(KindlyColors.secondaryPink)
                                .padding(.bottom, 20)
                            
                            Text("No Summaries Yet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "333333"))
                            
                            Text("Complete daily acts of kindness to generate your first monthly summary!")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "666666"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(summaryManager.pastSummaries.sorted(by: { $0.dateGenerated > $1.dateGenerated })) { summary in
                                Button(action: {
                                    summaryManager.currentMonthlySummary = summary
                                    selectedSummaryId = summary.id
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(summary.monthName) \(summary.year)")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(Color(hex: "333333"))
                                            
                                            Text("\(summary.totalActs) acts · \(summary.longestStreak) day streak")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: "666666"))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "AAAAAA"))
                                    }
                                    .contentShape(Rectangle())
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                }
                .navigationTitle("Past Summaries")
                .navigationBarItems(trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .foregroundColor(KindlyColors.primaryPink)
                })
            }
            .sheet(item: $selectedSummaryId) { _ in
                if let summary = summaryManager.currentMonthlySummary {
                    MonthlySummaryView(summaryManager: summaryManager)
                }
            }
        }
    }
}

// Add this extension to make UUID identifiable for sheet presentation
extension UUID: Identifiable {
    public var id: UUID { self }
}

#Preview {
    SettingsView()
        .environmentObject(KindnessService())
        .environmentObject(StreakTracker())
        .environmentObject(NotificationManager())
        .environmentObject(SummaryManager(kindnessService: KindnessService(), streakTracker: StreakTracker()))
} 
