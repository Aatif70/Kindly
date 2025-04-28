import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var kindnessService: KindnessService
    @EnvironmentObject var streakTracker: StreakTracker
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "333333"))
                        .padding(.top, 20)
                    
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
            }
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

#Preview {
    SettingsView()
        .environmentObject(KindnessService())
        .environmentObject(StreakTracker())
        .environmentObject(NotificationManager())
} 